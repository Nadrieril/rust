//! Note: tests specific to this file can be found in:
//!
//!   - `ui/pattern/usefulness`
//!   - `ui/or-patterns`
//!   - `ui/consts/const_in_pattern`
//!   - `ui/rfc-2008-non-exhaustive`
//!   - `ui/half-open-range-patterns`
//!   - probably many others
//!
//! I (Nadrieril) prefer to put new tests in `ui/pattern/usefulness` unless there's a specific
//! reason not to, for example if they depend on a particular feature like `or_patterns`.
//!
//! -----
//!
//! This file contains the logic for exhaustiveness and reachability checking for pattern-matching.
//! Specifically, given a list of patterns in a match, we can tell whether:
//! (a) a given pattern is reachable (reachability)
//! (b) the patterns cover every possible value for the type (exhaustiveness)
//!
//! The algorithm implemented here is a modified version of the one described in [this
//! paper](http://moscova.inria.fr/~maranget/papers/warn/index.html). We have however generalized it
//! to accommodate the variety of patterns that Rust supports. We thus explain our version here,
//! without being as precise.
//!
//!
//! # Summary
//!
//! The algorithm is given as input a list of patterns, one for each match arm, and computes the
//! following:
//! - a (hopefully empty) set of values that match none of the patterns,
//! - for each subpattern (taking into account or-patterns), whether it's matched by any value that
//!     isn't caught by a pattern before it, i.e. whether it is reachable.
//!
//! To a first approximation, the algorithm works by trying all possible values for the type being
//! matched on, and determining which arm(s) match which value. To make this tractable we cleverly
//! group together values that would match the same set of arms.
//!
//! The entrypoint of this file is the [`compute_match_usefulness`] function, which computes
//! reachability for each subpattern and exhaustiveness for the whole match.
//!
//! In this page we explain the necessary concepts to understand how the algorithm works.
//!
//!
//! # Constructors and fields
//!
//! In the value `Pair(Some(0), true)`, `Pair` is called the constructor of the value, and `Some(0)`
//! and `true` are its fields. Every matcheable value can be decomposed in this way. Examples of
//! constructors are: `Some`, `None`, `(,)` (the 2-tuple constructor), `Foo {..}` (the constructor
//! for a struct `Foo`), and `2` (the constructor for the number `2`).
//!
//! Each constructor takes a fixed number of fields; this is called its arity. `Pair` and `(,)`
//! have arity 2, `Some` has arity 1, `None` and `42` have arity 0. Each type has a known set of
//! constructors. Some have many (like `u64`) or even an infinity (like `&str` or `&[]`).
//!
//! Patterns are similar: `Pair(Some(_), _)` has constructor `Pair` and two fields. The difference
//! is that we get some extra pattern-only constructors, namely: the wildcard `_`, integer ranges
//! like `0..=10`, and variable-length slices like `[_, ..]`.
//!
//! Now to check if a value `v` matches a pattern `p`, we check if `v`'s constructor matches `p`'s
//! constructor, then recursively compare their fields if necessary. A few representative examples:
//!
//! - `matches!(v, _) := true`
//! - `matches!((v0,  v1), (p0,  p1)) := matches!(v0, p0) && matches!(v1, p1)`
//! - `matches!(Foo { bar: v0, baz: v1 }, Foo { bar: p0, baz: p1 }) := matches!(v0, p0) && matches!(v1, p1)`
//! - `matches!(Ok(v0), Ok(p0)) := matches!(v0, p0)`
//! - `matches!(Ok(v0), Err(p0)) := false` (incompatible variants)
//! - `matches!(v, 1..=100) := matches!(v, 1) || ... || matches!(v, 100)`
//! - `matches!([v0], [p0, .., p1]) := false` (incompatible lengths)
//! - `matches!([v0, v1, v2], [p0, .., p1]) := matches!(v0, p0) && matches!(v2, p1)`
//! - `matches!(v, p0 | p1) := matches!(v, p0) || matches!(v, p1)`
//!
//! Constructors, fields and relevant operations are defined in the [`super::deconstruct_pat`]
//! module. The question of whether a constructor is matched by another one is answered by
//! [`Constructor::is_covered_by`].
//!
//! Note 1: or-patterns are slightly different, we treat them separately.
//! Note 2: variables (like in `Some(x)`) match anything, so we treat them as wildcards.
//! Note 3: this only applies to matcheable values. For example a value of type `Rc<u64>` can't be
//! deconstructed that way.
//!
//!
//! # Specialization
//!
//! Recall that we need to try all possible values to see if the match is exhaustive. We do it
//! constructor-by-constructor, e.g. for the type `Option<T>`, "these patterns match all values" is
//! equivalent to "these patterns match all values with constructor `Some` as well as all values
//! with constructor `None`".
//!
//! Now observe that "the following matches all values that look like `(Some(_), _)`"
//! ```rust,ignore(example)
//! match x {
//!     (Some(0), _) => 1,
//!     (_, false) => 2,
//!     (Some(0), false) => 3,
//! }
//! ```
//!
//! is equivalent to "the following matches all values"
//! ```rust,ignore(example)
//! match x {
//!     (0, _) => 1,
//!     (_, false) => 2,
//!     (0, false) => 3,
//! }
//! ```
//!
//! and "the following matches all values that look like `(None, _)`"
//! ```rust,ignore(example)
//! match x {
//!     (Some(0), _) => 1,
//!     (_, false) => 2,
//!     (Some(0), false) => 3,
//! }
//! ```
//!
//! is equivalent to "the following matches all values"
//! ```rust,ignore(example)
//! match x {
//!     false => 2,
//! }
//! ```
//!
//! In other words, this is exhaustive:
//! ```rust,ignore(example)
//! match x {
//!     (Some(0), _) => 1,
//!     (_, false) => 2,
//!     (Some(0), false) => 3,
//! }
//! ```
//!
//! if and only if these two are exhaustive:
//! ```rust,ignore(example)
//! match x {
//!     (0, _) => 1,
//!     (_, false) => 2,
//!     (0, false) => 3,
//! }
//! match x {
//!     false => 2,
//! }
//! ```
//!
//! This is how the algorithm works: we recursively peel off one constructor at a time until we have
//! tried them all. This "peeling off" step is called "specialization".
//!
//! TODO: we operate on rows
//! TODO: define and illustrate specialize
//! TODO: unspecialization to reconstruct witnesses
//!
//! Note: we will sometimes abbreviate "constructor" as "ctor".
//!
//! Recall that we wish to compute `usefulness(p_1 .. p_n, q)`: given a list of patterns `p_1 ..
//! p_n` and a pattern `q`, all of the same type, we want to find a list of values (called
//! "witnesses") that are matched by `q` and by none of the `p_i`. We obviously don't just
//! enumerate all possible values. From the discussion above we see that we can proceed
//! ctor-by-ctor: for each value ctor of the given type, we ask "is there a value that starts with
//! this constructor and matches `q` and none of the `p_i`?". As we saw above, there's a lot we can
//! say from knowing only the first constructor of our candidate value.
//!
//! Let's take the following example:
//! ```compile_fail,E0004
//! # enum Enum { Variant1(()), Variant2(Option<bool>, u32)}
//! # fn foo(x: Enum) {
//! match x {
//!     Enum::Variant1(_) => {} // `p1`
//!     Enum::Variant2(None, 0) => {} // `p2`
//!     Enum::Variant2(Some(_), 0) => {} // `q`
//! }
//! # }
//! ```
//!
//! We can easily see that if our candidate value `v` starts with `Variant1` it will not match `q`.
//! If `v = Variant2(v0, v1)` however, whether or not it matches `p2` and `q` will depend on `v0`
//! and `v1`. In fact, such a `v` will be a witness of usefulness of `q` exactly when the tuple
//! `(v0, v1)` is a witness of usefulness of `q'` in the following reduced match:
//!
//! ```compile_fail,E0004
//! # fn foo(x: (Option<bool>, u32)) {
//! match x {
//!     (None, 0) => {} // `p2'`
//!     (Some(_), 0) => {} // `q'`
//! }
//! # }
//! ```
//!
//! This motivates a new step in computing usefulness, that we call _specialization_.
//! Specialization consist of filtering a list of patterns for those that match a constructor, and
//! then looking into the constructor's fields. This enables usefulness to be computed recursively.
//!
//! Instead of acting on a single pattern in each row, we will consider a list of patterns for each
//! row, and we call such a list a _pattern-stack_. The idea is that we will specialize the
//! leftmost pattern, which amounts to popping the constructor and pushing its fields, which feels
//! like a stack. We note a pattern-stack simply with `[p_1 ... p_n]`.
//! Here's a sequence of specializations of a list of pattern-stacks, to illustrate what's
//! happening:
//! ```ignore (illustrative)
//! [Enum::Variant1(_)]
//! [Enum::Variant2(None, 0)]
//! [Enum::Variant2(Some(_), 0)]
//! //==>> specialize with `Variant2`
//! [None, 0]
//! [Some(_), 0]
//! //==>> specialize with `Some`
//! [_, 0]
//! //==>> specialize with `true` (say the type was `bool`)
//! [0]
//! //==>> specialize with `0`
//! []
//! ```
//!
//! The function `specialize(c, p)` takes a value constructor `c` and a pattern `p`, and returns 0
//! or more pattern-stacks. If `c` does not match the head constructor of `p`, it returns nothing;
//! otherwise if returns the fields of the constructor. This only returns more than one
//! pattern-stack if `p` has a pattern-only constructor.
//!
//! - Specializing for the wrong constructor returns nothing
//!
//!   `specialize(None, Some(p0)) := []`
//!
//! - Specializing for the correct constructor returns a single row with the fields
//!
//!   `specialize(Variant1, Variant1(p0, p1, p2)) := [[p0, p1, p2]]`
//!
//!   `specialize(Foo{..}, Foo { bar: p0, baz: p1 }) := [[p0, p1]]`
//!
//! - For or-patterns, we specialize each branch and concatenate the results
//!
//!   `specialize(c, p0 | p1) := specialize(c, p0) ++ specialize(c, p1)`
//!
//! - We treat the other pattern constructors as if they were a large or-pattern of all the
//!   possibilities:
//!
//!   `specialize(c, _) := specialize(c, Variant1(_) | Variant2(_, _) | ...)`
//!
//!   `specialize(c, 1..=100) := specialize(c, 1 | ... | 100)`
//!
//!   `specialize(c, [p0, .., p1]) := specialize(c, [p0, p1] | [p0, _, p1] | [p0, _, _, p1] | ...)`
//!
//! - If `c` is a pattern-only constructor, `specialize` is defined on a case-by-case basis. See
//!   the discussion about constructor splitting in [`super::deconstruct_pat`].
//!
//!
//! We then extend this function to work with pattern-stacks as input, by acting on the first
//! column and keeping the other columns untouched.
//!
//! Specialization for the whole matrix is done in [`Matrix::specialize_constructor`]. Note that
//! or-patterns in the first column are expanded before being stored in the matrix. Specialization
//! for a single patstack is done from a combination of [`Constructor::is_covered_by`] and
//! [`PatStack::pop_head_constructor`]. The internals of how it's done mostly live in the
//! [`super::deconstruct_pat::Fields`] struct.
//!
//!
//! # Computing usefulness
//!
//! We now have all we need to compute usefulness. The inputs to usefulness are a list of
//! pattern-stacks `p_1 ... p_n` (one per row), and a new pattern_stack `q`. The paper and this
//! file calls the list of patstacks a _matrix_. They must all have the same number of columns and
//! the patterns in a given column must all have the same type. `usefulness` returns a (possibly
//! empty) list of witnesses of usefulness. These witnesses will also be pattern-stacks.
//!
//! - base case: `n_columns == 0`.
//!     Since a pattern-stack functions like a tuple of patterns, an empty one functions like the
//!     unit type. Thus `q` is useful iff there are no rows above it, i.e. if `n == 0`.
//!
//! - inductive case: `n_columns > 0`.
//!     We need a way to list the constructors we want to try. We will be more clever in the next
//!     section but for now assume we list all value constructors for the type of the first column.
//!
//!     - for each such ctor `c`:
//!
//!         - for each `q'` returned by `specialize(c, q)`:
//!
//!             - we compute `usefulness(specialize(c, p_1) ... specialize(c, p_n), q')`
//!
//!         - for each witness found, we revert specialization by pushing the constructor `c` on top.
//!
//!     - We return the concatenation of all the witnesses found, if any.
//!
//! Example:
//! ```ignore (illustrative)
//! [Some(true)] // p_1
//! [None] // p_2
//! [Some(_)] // q
//! //==>> try `None`: `specialize(None, q)` returns nothing
//! //==>> try `Some`: `specialize(Some, q)` returns a single row
//! [true] // p_1'
//! [_] // q'
//! //==>> try `true`: `specialize(true, q')` returns a single row
//! [] // p_1''
//! [] // q''
//! //==>> base case; `n != 0` so `q''` is not useful.
//! //==>> go back up a step
//! [true] // p_1'
//! [_] // q'
//! //==>> try `false`: `specialize(false, q')` returns a single row
//! [] // q''
//! //==>> base case; `n == 0` so `q''` is useful. We return the single witness `[]`
//! witnesses:
//! []
//! //==>> undo the specialization with `false`
//! witnesses:
//! [false]
//! //==>> undo the specialization with `Some`
//! witnesses:
//! [Some(false)]
//! //==>> we have tried all the constructors. The output is the single witness `[Some(false)]`.
//! ```
//!
//! This computation is done in `is_useful`. In practice we don't care about the list of
//! witnesses when computing reachability; we only need to know whether any exist. We do keep the
//! witnesses when computing exhaustiveness to report them to the user.
//!
//!
//! # Making usefulness tractable: constructor splitting
//!
//! We're missing one last detail: which constructors do we list? Naively listing all value
//! constructors cannot work for types like `u64` or `&str`, so we need to be more clever. The
//! first obvious insight is that we only want to list constructors that are covered by the head
//! constructor of `q`. If it's a value constructor, we only try that one. If it's a pattern-only
//! constructor, we use the final clever idea for this algorithm: _constructor splitting_, where we
//! group together constructors that behave the same.
//!
//! The details are not necessary to understand this file, so we explain them in
//! [`super::deconstruct_pat`]. Splitting is done by the `Constructor::split` function.
//!
//! # Constants in patterns
//!
//! There are two kinds of constants in patterns:
//!
//! * literals (`1`, `true`, `"foo"`)
//! * named or inline consts (`FOO`, `const { 5 + 6 }`)
//!
//! The latter are converted into other patterns with literals at the leaves. For example
//! `const_to_pat(const { [1, 2, 3] })` becomes an `Array(vec![Const(1), Const(2), Const(3)])`
//! pattern. This gets problematic when comparing the constant via `==` would behave differently
//! from matching on the constant converted to a pattern. Situations like that can occur, when
//! the user implements `PartialEq` manually, and thus could make `==` behave arbitrarily different.
//! In order to honor the `==` implementation, constants of types that implement `PartialEq` manually
//! stay as a full constant and become an `Opaque` pattern. These `Opaque` patterns do not participate
//! in exhaustiveness, specialization or overlap checking.
//!
//!
//! # Example
//!
//! A picture is worth a thousand words.
//!
//! ```rust,ignore(example)
//! match x {
//!     Pair(Some(0), _) => 1,
//!     Pair(_, false) => 2,
//!     Pair(Some(0), false) => 3,
//! }
//! ```
//!
//! We start:
//!  ┐ Patterns:
//!  │   1. `[Pair(Some(0), _)]`
//!  │   2. `[Pair(_, false)]`
//!  │   3. `[Pair(Some(0), false)]`
//!  │
//!  │ Dig into `Pair`:
//!  ├─┐ Patterns:
//!  │ │   1. `[Some(0), _]`
//!  │ │   2. `[_, false]`
//!  │ │   3. `[Some(0), false]`
//!  │ │
//!  │ │ Dig into `Some`:
//!  │ ├─┐ Patterns:
//!  │ │ │   1. `[0, _]`
//!  │ │ │   2. `[_, false]`
//!  │ │ │   3. `[0, false]`
//!  │ │ │
//!  │ │ │ Dig into `0`:
//!  │ │ ├─┐ Patterns:
//!  │ │ │ │   1. `[_]`
//!  │ │ │ │   3. `[false]`
//!  │ │ │ │
//!  │ │ │ │ Dig into `true`:
//!  │ │ │ ├─┐ Patterns:
//!  │ │ │ │ │   1. `[]`
//!  │ │ │ │ │
//!  │ │ │ │ │ We note arm 1 is reachable (by `Pair(Some(0), true)`).
//!  │ │ │ ├─┘
//!  │ │ │ │
//!  │ │ │ │ Dig into `false`:
//!  │ │ │ ├─┐ Patterns:
//!  │ │ │ │ │   1. `[]`
//!  │ │ │ │ │   3. `[]`
//!  │ │ │ │ │
//!  │ │ │ │ │ We note arm 1 is reachable (by `Pair(Some(0), false)`).
//!  │ │ │ ├─┘
//!  │ │ ├─┘
//!  │ │ │
//!  │ │ │ Dig into `1..`:
//!  │ │ ├─┐ Patterns:
//!  │ │ │ │   2. `[false]`
//!  │ │ │ │
//!  │ │ │ │ Dig into `true`:
//!  │ │ │ ├─┐ Patterns:
//!  │ │ │ │ │   // no rows left
//!  │ │ │ │ │
//!  │ │ │ │ │ We have found an unmatched value! This gives us a witness.
//!  │ │ │ │ │ New witnesses:
//!  │ │ │ │ │   `[]`
//!  │ │ │ ├─┘
//!  │ │ │ │ New witnesses from `true`:
//!  │ │ │ │   `[true]`
//!  │ │ │ │
//!  │ │ │ │ Dig into `false`:
//!  │ │ │ ├─┐ Patterns:
//!  │ │ │ │ │   2. `[]`
//!  │ │ │ │ │
//!  │ │ │ │ │ We note arm 2 is reachable (by `Pair(Some(1..), false)`).
//!  │ │ │ ├─┘
//!  │ │ │ │
//!  │ │ │ │ Total witnesses for `1..`:
//!  │ │ │ │   `[true]`
//!  │ │ ├─┘
//!  │ │ │ New witnesses from `1..`:
//!  │ │ │   `[1.., true]`
//!  │ │ │
//!  │ │ │ Total witnesses for `Some`:
//!  │ │ │   `[1.., true]`
//!  │ ├─┘
//!  │ │ New witnesses from `Some`:
//!  │ │   `[Some(1..), true]`
//!  │ │
//!  │ │ Dig into `None`:
//!  │ ├─┐ Patterns:
//!  │ │ │   2. `[false]`
//!  │ │ │
//!  │ │ │ Dig into `true`:
//!  │ │ ├─┐ Patterns:
//!  │ │ │ │   // no rows left
//!  │ │ │ │
//!  │ │ │ │ We have found an unmatched value! This gives us a witness.
//!  │ │ │ │ New witnesses:
//!  │ │ │ │   `[]`
//!  │ │ ├─┘
//!  │ │ │ New witnesses from `true`:
//!  │ │ │   `[true]`
//!  │ │ │
//!  │ │ │ Dig into `false`:
//!  │ │ ├─┐ Patterns:
//!  │ │ │ │   2. `[]`
//!  │ │ │ │
//!  │ │ │ │ We note arm 2 is reachable (by `Pair(None, false)`).
//!  │ │ ├─┘
//!  │ │ │
//!  │ │ │ Total witnesses for `None`:
//!  │ │ │   `[true]`
//!  │ ├─┘
//!  │ │ New witnesses from `None`:
//!  │ │   `[None, true]`
//!  │ │
//!  │ │ Total witnesses for `Pair`:
//!  │ │   `[Some(1..), true]`
//!  │ │   `[None, true]`
//!  ├─┘
//!  │ New witnesses from `Pair`:
//!  │   `[Pair(Some(1..), true)]`
//!  │   `[Pair(None, true)]`
//!  │
//!  │ Final witnesses:
//!  │   `[Pair(Some(1..), true)]`
//!  │   `[Pair(None, true)]`
//!  ┘
//!
//! We conclude:
//! - Arm 3 is unreachable (it was never marked as reachable);
//! - The match is not exhaustive;
//! - Adding `Pair(Some(1..), true)` and `Pair(None, true)` would make the match exhaustive.

use super::deconstruct_pat::{
    Constructor, ConstructorSet, DeconstructedPat, IntRange, SplitConstructorSet, WitnessPat,
};
use crate::errors::{NonExhaustiveOmittedPattern, Overlap, OverlappingRangeEndpoints, Uncovered};

use rustc_data_structures::captures::Captures;

use rustc_arena::TypedArena;
use rustc_data_structures::stack::ensure_sufficient_stack;
use rustc_hir::def_id::DefId;
use rustc_hir::HirId;
use rustc_middle::ty::{self, Ty, TyCtxt};
use rustc_session::lint;
use rustc_session::lint::builtin::NON_EXHAUSTIVE_OMITTED_PATTERNS;
use rustc_span::{Span, DUMMY_SP};

use smallvec::{smallvec, SmallVec};
use std::fmt;

pub(crate) struct MatchCheckCtxt<'p, 'tcx> {
    pub(crate) tcx: TyCtxt<'tcx>,
    pub(crate) typeck_results: &'tcx ty::TypeckResults<'tcx>,
    /// The module in which the match occurs. This is necessary for
    /// checking inhabited-ness of types because whether a type is (visibly)
    /// inhabited can depend on whether it was defined in the current module or
    /// not. E.g., `struct Foo { _private: ! }` cannot be seen to be empty
    /// outside its module and should not be matchable with an empty match statement.
    pub(crate) module: DefId,
    pub(crate) param_env: ty::ParamEnv<'tcx>,
    pub(crate) pattern_arena: &'p TypedArena<DeconstructedPat<'p, 'tcx>>,
    /// Only produce `NON_EXHAUSTIVE_OMITTED_PATTERNS` lint on refutable patterns.
    pub(crate) refutable: bool,
}

impl<'a, 'tcx> MatchCheckCtxt<'a, 'tcx> {
    pub(super) fn is_uninhabited(&self, ty: Ty<'tcx>) -> bool {
        if self.tcx.features().exhaustive_patterns {
            !ty.is_inhabited_from(self.tcx, self.module, self.param_env)
        } else {
            false
        }
    }

    /// Returns whether the given type is an enum from another crate declared `#[non_exhaustive]`.
    pub(super) fn is_foreign_non_exhaustive_enum(&self, ty: Ty<'tcx>) -> bool {
        match ty.kind() {
            ty::Adt(def, ..) => {
                def.is_enum() && def.is_variant_list_non_exhaustive() && !def.did().is_local()
            }
            _ => false,
        }
    }

    /// Type inference occasionally gives us opaque types in places where corresponding patterns
    /// have more specific types. To avoid inconsistencies, we use the corresponding concrete type
    /// if possible.
    fn reveal_opaque_ty(&self, ty: Ty<'tcx>) -> Ty<'tcx> {
        if let ty::Alias(ty::Opaque, alias_ty) = ty.kind() {
            if let Some(local_def_id) = alias_ty.def_id.as_local() {
                let key = ty::OpaqueTypeKey { def_id: local_def_id, args: alias_ty.args };
                if let Some(hidden_ty) = self.typeck_results.concrete_opaque_types.get(&key) {
                    return hidden_ty.ty;
                }
            }
        }
        ty
    }
}

#[derive(Copy, Clone)]
pub(super) struct PatCtxt<'a, 'p, 'tcx> {
    pub(super) cx: &'a MatchCheckCtxt<'p, 'tcx>,
    /// Type of the current column under investigation.
    pub(super) ty: Ty<'tcx>,
    /// Span of the current pattern under investigation.
    pub(super) span: Span,
    /// Whether the current pattern is the whole pattern as found in a match arm, or if it's a
    /// subpattern.
    pub(super) is_top_level: bool,
}

impl<'a, 'p, 'tcx> fmt::Debug for PatCtxt<'a, 'p, 'tcx> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("PatCtxt").field("ty", &self.ty).finish()
    }
}

/// A row of a matrix. Rows of len 1 are very common, which is why `SmallVec[_; 2]`
/// works well.
#[derive(Clone)]
pub(crate) struct PatStack<'p, 'tcx> {
    pats: SmallVec<[&'p DeconstructedPat<'p, 'tcx>; 2]>,
    is_under_guard: bool,
    /// The row (in the matrix) of the `PatStack` from which this one is derived. When there is
    /// none, this is the id of the arm.
    parent_row: usize,
    is_useful: bool,
}

impl<'p, 'tcx> PatStack<'p, 'tcx> {
    fn from_pattern(
        pat: &'p DeconstructedPat<'p, 'tcx>,
        parent_row: usize,
        is_under_guard: bool,
    ) -> Self {
        PatStack { pats: smallvec![pat], parent_row, is_under_guard, is_useful: false }
    }

    fn from_vec(
        vec: SmallVec<[&'p DeconstructedPat<'p, 'tcx>; 2]>,
        parent_row: usize,
        is_under_guard: bool,
    ) -> Self {
        PatStack { pats: vec, parent_row, is_under_guard, is_useful: false }
    }

    fn is_empty(&self) -> bool {
        self.pats.is_empty()
    }

    fn len(&self) -> usize {
        self.pats.len()
    }

    fn head(&self) -> &'p DeconstructedPat<'p, 'tcx> {
        self.pats[0]
    }

    fn iter(&self) -> impl Iterator<Item = &DeconstructedPat<'p, 'tcx>> {
        self.pats.iter().copied()
    }

    // Expand the first pattern into its subpatterns. Only useful if the pattern is an
    // or-pattern. Panics if `self` is empty.
    fn expand_or_pat<'a>(&'a self) -> impl Iterator<Item = PatStack<'p, 'tcx>> + Captures<'a> {
        self.head().iter_fields().map(move |pat| {
            let mut new_patstack =
                PatStack::from_pattern(pat, self.parent_row, self.is_under_guard);
            new_patstack.pats.extend_from_slice(&self.pats[1..]);
            new_patstack
        })
    }

    /// This computes `S(self.head().ctor(), self)`. See top of the file for explanations.
    ///
    /// Structure patterns with a partial wild pattern (Foo { a: 42, .. }) have their missing
    /// fields filled with wild patterns.
    ///
    /// This is roughly the inverse of `Constructor::apply`.
    fn pop_head_constructor(
        &self,
        pcx: &PatCtxt<'_, 'p, 'tcx>,
        ctor: &Constructor<'tcx>,
        parent_row: usize,
    ) -> PatStack<'p, 'tcx> {
        // We pop the head pattern and push the new fields extracted from the arguments of
        // `self.head()`.
        let mut new_fields: SmallVec<[_; 2]> = self.head().specialize(pcx, ctor);
        new_fields.extend_from_slice(&self.pats[1..]);
        PatStack::from_vec(new_fields, parent_row, self.is_under_guard)
    }
}

/// Pretty-printing for matrix row.
impl<'p, 'tcx> fmt::Debug for PatStack<'p, 'tcx> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "+")?;
        for pat in self.iter() {
            write!(f, " {pat:?} +")?;
        }
        Ok(())
    }
}

/// A 2D matrix.
#[derive(Clone)]
struct Matrix<'p, 'tcx> {
    rows: Vec<PatStack<'p, 'tcx>>,
}

impl<'p, 'tcx> Matrix<'p, 'tcx> {
    fn empty() -> Self {
        Matrix { rows: vec![] }
    }

    /// Pushes a new row to the matrix. If the row starts with an or-pattern, this recursively
    /// expands it.
    fn push(&mut self, row: PatStack<'p, 'tcx>) {
        if !row.is_empty() && row.head().is_or_pat() {
            for new_row in row.expand_or_pat() {
                self.push(new_row);
            }
        } else {
            self.rows.push(row);
        }
    }

    fn rows<'a>(
        &'a self,
    ) -> impl Iterator<Item = &'a PatStack<'p, 'tcx>> + Clone + DoubleEndedIterator + ExactSizeIterator
    {
        self.rows.iter()
    }
    fn rows_mut<'a>(
        &'a mut self,
    ) -> impl Iterator<Item = &'a mut PatStack<'p, 'tcx>> + DoubleEndedIterator + ExactSizeIterator
    {
        self.rows.iter_mut()
    }

    /// Iterate over the first component of each row
    fn heads<'a>(
        &'a self,
    ) -> impl Iterator<Item = &'p DeconstructedPat<'p, 'tcx>> + Clone + Captures<'a> {
        self.rows().map(|r| r.head())
    }

    /// This computes `S(constructor, self)`. See top of the file for explanations.
    fn specialize_constructor(
        &self,
        pcx: &PatCtxt<'_, 'p, 'tcx>,
        ctor: &Constructor<'tcx>,
    ) -> Matrix<'p, 'tcx> {
        let mut matrix = Matrix::empty();
        for (i, row) in self.rows().enumerate() {
            if ctor.is_covered_by(pcx, row.head().ctor()) {
                let new_row = row.pop_head_constructor(pcx, ctor, i);
                matrix.push(new_row);
            }
        }
        matrix
    }
}

/// Pretty-printer for matrices of patterns, example:
///
/// ```text
/// + _     + []                +
/// + true  + [First]           +
/// + true  + [Second(true)]    +
/// + false + [_]               +
/// + _     + [_, _, tail @ ..] +
/// ```
impl<'p, 'tcx> fmt::Debug for Matrix<'p, 'tcx> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "\n")?;

        let Matrix { rows, .. } = self;
        let pretty_printed_matrix: Vec<Vec<String>> =
            rows.iter().map(|row| row.iter().map(|pat| format!("{pat:?}")).collect()).collect();

        let column_count = rows.iter().map(|row| row.len()).next().unwrap_or(0);
        assert!(rows.iter().all(|row| row.len() == column_count));
        let column_widths: Vec<usize> = (0..column_count)
            .map(|col| pretty_printed_matrix.iter().map(|row| row[col].len()).max().unwrap_or(0))
            .collect();

        for row in pretty_printed_matrix {
            write!(f, "+")?;
            for (column, pat_str) in row.into_iter().enumerate() {
                write!(f, " ")?;
                write!(f, "{:1$}", pat_str, column_widths[column])?;
                write!(f, " +")?;
            }
            write!(f, "\n")?;
        }
        Ok(())
    }
}

/// A partially-constructed witness of non-exhaustiveness for error reporting, represented as a list
/// of patterns (in reverse order of construction) with wildcards inside to represent elements that
/// can take any inhabitant of the type as a value.
///
/// This mirrors `PatStack`: they function similarly, except `PatStack` contains user patterns we
/// are inspecting, and `WitnessStack` contains witnesses we are constructing.
/// FIXME(Nadrieril): use the same order of patterns for both
///
/// A `WitnessStack` should have the same types and length as the `PatStacks` we are inspecting
/// (except we store the patterns in reverse order). Because Rust `match` is always against a single
/// pattern, at the end the stack will have length 1. In the middle of the algorithm, it can contain
/// multiple patterns.
///
/// For example, if we are constructing a witness for the match against
///
/// ```compile_fail,E0004
/// struct Pair(Option<(u32, u32)>, bool);
/// # fn foo(p: Pair) {
/// match p {
///    Pair(None, _) => {}
///    Pair(_, false) => {}
/// }
/// # }
/// ```
///
/// We'll perform the following steps (among others):
/// - Start with a matrix representing the match
///     `PatStack(vec![Pair(None, _)])`
///     `PatStack(vec![Pair(_, false)])`
/// - Specialize with `Pair`
///     `PatStack(vec![None, _])`
///     `PatStack(vec![_, false])`
/// - Specialize with `Some`
///     `PatStack(vec![_, false])`
/// - Specialize with `_`
///     `PatStack(vec![false])`
/// - Specialize with `true`
///     // no patstacks left
/// - This is a non-exhaustive match: we have the empty witness stack as a witness.
///     `WitnessStack(vec![])`
/// - Apply `true`
///     `WitnessStack(vec![true])`
/// - Apply `_`
///     `WitnessStack(vec![true, _])`
/// - Apply `Some`
///     `WitnessStack(vec![true, Some(_)])`
/// - Apply `Pair`
///     `WitnessStack(vec![Pair(Some(_), true)])`
///
/// The final `Pair(Some(_), true)` is then the resulting witness.
#[derive(Debug, Clone)]
pub(crate) struct WitnessStack<'tcx>(Vec<WitnessPat<'tcx>>);

impl<'tcx> WitnessStack<'tcx> {
    /// Asserts that the witness contains a single pattern, and returns it.
    fn single_pattern(self) -> WitnessPat<'tcx> {
        assert_eq!(self.0.len(), 1);
        self.0.into_iter().next().unwrap()
    }

    /// Reverses specialization by the `Missing` constructor by pushing a whole new pattern.
    fn push_pattern(&mut self, pat: WitnessPat<'tcx>) {
        self.0.push(pat);
    }

    /// Reverses specialization. Given a witness obtained after specialization, this constructs a
    /// new witness valid for before specialization. Examples:
    ///
    /// ctor: tuple of 2 elements
    /// pats: [false, "foo", _, true]
    /// result: [(false, "foo"), _, true]
    ///
    /// ctor: Enum::Variant { a: (bool, &'static str), b: usize}
    /// pats: [(false, "foo"), _, true]
    /// result: [Enum::Variant { a: (false, "foo"), b: _ }, true]
    fn apply_constructor(&mut self, pcx: &PatCtxt<'_, '_, 'tcx>, ctor: &Constructor<'tcx>) {
        let len = self.0.len();
        let arity = ctor.arity(pcx);
        let fields = self.0.drain((len - arity)..).rev().collect();
        let pat = WitnessPat::new(ctor.clone(), fields, pcx.ty);
        self.0.push(pat);
    }
}

/// Represents a set of partially-constructed witnesses of non-exhaustiveness for error reporting.
/// This has similar invariants as `Matrix` does.
/// Throughout the exhaustiveness phase of the algorithm, `is_useful` maintains the invariant that
/// the union of the `Matrix` and the `WitnessMatrix` together matches the type exhaustively. By the
/// end of the algorithm, this has a single column, which contains the patterns that are missing for
/// the match to be exhaustive.
#[derive(Debug, Clone)]
pub struct WitnessMatrix<'tcx>(Vec<WitnessStack<'tcx>>);

impl<'tcx> WitnessMatrix<'tcx> {
    /// New matrix with no rows.
    fn new_empty() -> Self {
        WitnessMatrix(vec![])
    }
    /// New matrix with one row and no columns.
    fn new_unit() -> Self {
        WitnessMatrix(vec![WitnessStack(vec![])])
    }

    /// Whether this has any rows.
    fn is_empty(&self) -> bool {
        self.0.is_empty()
    }
    /// Asserts that there is a single column and returns the patterns in it.
    fn single_column(self) -> Vec<WitnessPat<'tcx>> {
        self.0.into_iter().map(|w| w.single_pattern()).collect()
    }

    /// Reverses specialization by the `Missing` constructor by pushing a whole new pattern.
    fn push_pattern(&mut self, pat: &WitnessPat<'tcx>) {
        for witness in self.0.iter_mut() {
            witness.push_pattern(pat.clone())
        }
    }

    /// Reverses specialization by `ctor`.
    fn apply_constructor(
        &mut self,
        pcx: &PatCtxt<'_, '_, 'tcx>,
        missing_ctors: &[Constructor<'tcx>],
        ctor: &Constructor<'tcx>,
    ) {
        if self.is_empty() {
            return;
        }
        if matches!(ctor, Constructor::Wildcard) {
            let pat = WitnessPat::wild_from_ctor(pcx, Constructor::Wildcard);
            self.push_pattern(&pat);
        } else if matches!(ctor, Constructor::Missing) {
            // We got the special `Missing` constructor, so each of the missing constructors gives a
            // new pattern that is not caught by the match. We list those patterns and push them
            // onto our current witnesses.
            if missing_ctors.iter().any(|c| c.is_non_exhaustive()) {
                // We only report `_` here; listing other constructors would be redundant.
                let pat = WitnessPat::wild_from_ctor(pcx, Constructor::NonExhaustive);
                self.push_pattern(&pat);
            } else {
                let old_witnesses = std::mem::replace(self, Self::new_empty());
                for ctor in missing_ctors {
                    let pat = WitnessPat::wild_from_ctor(pcx, ctor.clone());
                    let mut witnesses_with_missing_ctor = old_witnesses.clone();
                    witnesses_with_missing_ctor.push_pattern(&pat);
                    self.extend(witnesses_with_missing_ctor)
                }
            }
        } else if !missing_ctors.is_empty() {
            // `ctor` isn't `Wildcard` or `Missing` and some ctors are missing, so we know
            // `split_ctors` will contain `Wildcard` or `Missing`.
            // For diagnostic purposes we choose to discard witnesses we got under `ctor`, which
            // will let only the `Wildcard` or `Missing` be reported.
            self.0.clear();
        } else {
            for witness in self.0.iter_mut() {
                witness.apply_constructor(pcx, ctor)
            }
        }
    }

    /// Merges the rows of two witness matrices. Their column types must match.
    fn extend(&mut self, other: Self) {
        self.0.extend(other.0)
    }
}

/// This computes witnesses of the non-exhaustiveness of `matrix` (if any). We track usefulness of
/// each row in the matrix (in `row.is_useful`). We track reachability of each subpattern
/// using interior mutability in `DeconstructedPat`.
///
/// The key steps are:
/// - specialization, where we dig into the rows that have a specific constructor and call ourselves
///     recursively;
/// - unspecialization, where we lift the results from the previous step into results for this step
///     (using `apply_constructor` and by updating `is_useful` for each parent row).
/// This is all explained at the top of the file.
///
/// `wildcard_row` is a fictitious matrix row that has only wildcards, with the appropriate types to
/// match what's in the columns of `matrix`.
#[instrument(level = "debug", skip(cx, is_top_level), ret)]
fn compute_usefulness<'p, 'tcx>(
    cx: &MatchCheckCtxt<'p, 'tcx>,
    matrix: &mut Matrix<'p, 'tcx>,
    wildcard_row: &PatStack<'p, 'tcx>,
    is_top_level: bool,
) -> WitnessMatrix<'tcx> {
    debug_assert!(matrix.rows().all(|r| r.len() == wildcard_row.len()));

    if wildcard_row.is_empty() {
        // The base case. We are morally pattern-matching on (). An arm is reachable iff it has no
        // arms above it (and we don't count arms with guards).
        let mut useful = true;
        for row in matrix.rows_mut() {
            row.is_useful = useful;
            useful = useful && row.is_under_guard;
            if !useful {
                break;
            }
        }
        if useful {
            return WitnessMatrix::new_unit();
        } else {
            return WitnessMatrix::new_empty();
        }
    }

    let ty = cx.reveal_opaque_ty(wildcard_row.head().ty());
    debug!("ty: {ty:?}");
    let pcx = &PatCtxt { cx, ty, span: DUMMY_SP, is_top_level };

    // Analyze the constructors present in this column.
    let ctors = matrix.heads().map(|p| p.ctor());
    let split_set = ConstructorSet::for_ty(pcx.cx, pcx.ty).split(pcx, ctors);
    let mut split_ctors = split_set.present;
    // We want to iterate over a full set of constructors, so if any is missing we add a wildcard.
    if !split_set.missing.is_empty() {
        let all_missing = split_ctors.is_empty();
        let report_when_all_missing =
            pcx.is_top_level && !super::deconstruct_pat::IntRange::is_integral(pcx.ty);
        let ctor = if all_missing && !report_when_all_missing {
            Constructor::Wildcard
        } else {
            // Like `Wildcard`, except if it doesn't match a row this will report all the missing
            // constructors instead of just `_`.
            Constructor::Missing
        };
        split_ctors.push(ctor);
    }

    let mut ret = WitnessMatrix::new_empty();
    for ctor in split_ctors {
        debug!("specialize({:?})", ctor);
        // Dig into rows that match `ctor`.
        let mut spec_matrix = matrix.specialize_constructor(pcx, &ctor);
        let wildcard_row = wildcard_row.pop_head_constructor(pcx, &ctor, usize::MAX);
        let mut witnesses = ensure_sufficient_stack(|| {
            compute_usefulness(cx, &mut spec_matrix, &wildcard_row, false)
        });
        // Transform witnesses for `spec_matrix` into witnesses for `matrix`.
        witnesses.apply_constructor(pcx, &split_set.missing, &ctor);
        ret.extend(witnesses);

        // A parent row is useful if any of its children is.
        for child_row in spec_matrix.rows() {
            let parent_row = &mut matrix.rows[child_row.parent_row];
            parent_row.is_useful = parent_row.is_useful || child_row.is_useful;
        }
    }

    // Map usefulness of each row onto reachability of the subpattern.
    for row in matrix.rows() {
        if row.is_useful {
            row.head().set_reachable();
        }
    }
    ret
}

/// A column of patterns in the matrix, where a column is the intuitive notion of "subpatterns that
/// inspect the same subvalue".
/// This is used to traverse patterns column-by-column for lints. Despite similarities with
/// `is_useful`, this is a different traversal. Notably this is linear in the depth of patterns,
/// whereas `is_useful` is worst-case exponential (exhaustiveness is NP-complete).
#[derive(Debug)]
struct PatternColumn<'p, 'tcx> {
    patterns: Vec<&'p DeconstructedPat<'p, 'tcx>>,
}

impl<'p, 'tcx> PatternColumn<'p, 'tcx> {
    fn new(patterns: Vec<&'p DeconstructedPat<'p, 'tcx>>) -> Self {
        Self { patterns }
    }

    fn is_empty(&self) -> bool {
        self.patterns.is_empty()
    }
    fn head_ty(&self, cx: &MatchCheckCtxt<'p, 'tcx>) -> Ty<'tcx> {
        cx.reveal_opaque_ty(self.patterns[0].ty())
    }

    fn analyze_ctors(&self, pcx: &PatCtxt<'_, 'p, 'tcx>) -> SplitConstructorSet<'tcx> {
        let column_ctors = self.patterns.iter().map(|p| p.ctor());
        ConstructorSet::for_ty(pcx.cx, pcx.ty).split(pcx, column_ctors)
    }
    fn iter<'a>(&'a self) -> impl Iterator<Item = &'p DeconstructedPat<'p, 'tcx>> + Captures<'a> {
        self.patterns.iter().copied()
    }

    fn specialize(&self, pcx: &PatCtxt<'_, 'p, 'tcx>, ctor: &Constructor<'tcx>) -> Vec<Self> {
        let arity = ctor.arity(pcx);
        if arity == 0 {
            return Vec::new();
        }

        // We specialize the column by `ctor`. This gives us `arity`-many columns of patterns. These
        // columns may have different lengths in the presence of or-patterns (this is why we can't
        // reuse `Matrix`).
        let mut specialized_columns: Vec<_> =
            (0..arity).map(|_| Self { patterns: Vec::new() }).collect();
        let relevant_patterns =
            self.patterns.iter().filter(|pat| ctor.is_covered_by(pcx, pat.ctor()));
        for pat in relevant_patterns {
            let specialized = pat.specialize(pcx, &ctor);
            for (subpat, column) in specialized.iter().zip(&mut specialized_columns) {
                if subpat.is_or_pat() {
                    column.patterns.extend(subpat.iter_fields())
                } else {
                    column.patterns.push(subpat)
                }
            }
        }
        specialized_columns
    }
}

/// Traverse the patterns to collect any variants of a non_exhaustive enum that fail to be mentioned
/// in a given column.
#[instrument(level = "debug", skip(cx), ret)]
fn collect_nonexhaustive_missing_variants<'p, 'tcx>(
    cx: &MatchCheckCtxt<'p, 'tcx>,
    column: &PatternColumn<'p, 'tcx>,
) -> Vec<WitnessPat<'tcx>> {
    if column.is_empty() {
        return Vec::new();
    }
    let ty = column.head_ty(cx);
    let pcx = &PatCtxt { cx, ty, span: DUMMY_SP, is_top_level: false };

    let set = column.analyze_ctors(pcx);
    if set.present.is_empty() {
        // We can't consistently handle the case where no constructors are present (since this would
        // require digging deep through any type in case there's a non_exhaustive enum somewhere),
        // so for consistency we refuse to handle the top-level case, where we could handle it.
        return vec![];
    }

    let mut witnesses = Vec::new();
    if cx.is_foreign_non_exhaustive_enum(ty) {
        witnesses.extend(
            set.missing
                .into_iter()
                // This will list missing visible variants.
                .filter(|c| !matches!(c, Constructor::Hidden | Constructor::NonExhaustive))
                .map(|missing_ctor| WitnessPat::wild_from_ctor(pcx, missing_ctor)),
        )
    }

    // Recurse into the fields.
    for ctor in set.present {
        let specialized_columns = column.specialize(pcx, &ctor);
        let wild_pat = WitnessPat::wild_from_ctor(pcx, ctor);
        for (i, col_i) in specialized_columns.iter().enumerate() {
            // Compute witnesses for each column.
            let wits_for_col_i = collect_nonexhaustive_missing_variants(cx, col_i);
            // For each witness, we build a new pattern in the shape of `ctor(_, _, wit, _, _)`,
            // adding enough wildcards to match `arity`.
            for wit in wits_for_col_i {
                let mut pat = wild_pat.clone();
                pat.fields[i] = wit;
                witnesses.push(pat);
            }
        }
    }
    witnesses
}

/// Traverse the patterns to warn the user about ranges that overlap on their endpoints.
#[instrument(level = "debug", skip(cx, lint_root))]
fn lint_overlapping_range_endpoints<'p, 'tcx>(
    cx: &MatchCheckCtxt<'p, 'tcx>,
    column: &PatternColumn<'p, 'tcx>,
    lint_root: HirId,
) {
    if column.is_empty() {
        return;
    }
    let ty = column.head_ty(cx);
    let pcx = &PatCtxt { cx, ty, span: DUMMY_SP, is_top_level: false };

    let set = column.analyze_ctors(pcx);

    if IntRange::is_integral(ty) {
        // If two ranges overlapped, the split set will contain their intersection as a singleton.
        let split_int_ranges = set.present.iter().filter_map(|c| c.as_int_range());
        for overlap_range in split_int_ranges.clone() {
            if overlap_range.is_singleton() {
                let overlap: u128 = overlap_range.boundaries().0;
                // Spans of ranges that start or end with the overlap.
                let mut prefixes: SmallVec<[_; 1]> = Default::default();
                let mut suffixes: SmallVec<[_; 1]> = Default::default();
                // Iterate on patterns that contained `overlap`.
                for pat in column.iter() {
                    let this_span = pat.span();
                    let Constructor::IntRange(this_range) = pat.ctor() else { continue };
                    if this_range.is_singleton() {
                        // Don't lint when one of the ranges is a singleton.
                        continue;
                    }
                    let mut this_overlaps: SmallVec<[_; 1]> = Default::default();
                    let (start, end) = this_range.boundaries();
                    if start == overlap {
                        if !prefixes.is_empty() {
                            this_overlaps = prefixes.clone();
                        }
                        suffixes.push(this_span)
                    } else if end == overlap {
                        if !suffixes.is_empty() {
                            this_overlaps = suffixes.clone();
                        }
                        prefixes.push(this_span)
                    }
                    if !this_overlaps.is_empty() {
                        let overlap_as_pat = overlap_range.to_pat(pcx.cx.tcx, pcx.ty);
                        let overlaps: Vec<_> = this_overlaps
                            .into_iter()
                            .map(|span| Overlap { range: overlap_as_pat.clone(), span })
                            .collect();
                        pcx.cx.tcx.emit_spanned_lint(
                            lint::builtin::OVERLAPPING_RANGE_ENDPOINTS,
                            lint_root,
                            this_span,
                            OverlappingRangeEndpoints { overlap: overlaps, range: this_span },
                        );
                    }
                }
            }
        }
    }

    // Recurse into the fields.
    for ctor in set.present {
        for col in column.specialize(pcx, &ctor) {
            lint_overlapping_range_endpoints(cx, &col, lint_root);
        }
    }
}

/// The arm of a match expression.
#[derive(Clone, Copy, Debug)]
pub(crate) struct MatchArm<'p, 'tcx> {
    /// The pattern must have been lowered through `check_match::MatchVisitor::lower_pattern`.
    pub(crate) pat: &'p DeconstructedPat<'p, 'tcx>,
    pub(crate) hir_id: HirId,
    pub(crate) has_guard: bool,
}

/// Indicates whether or not a given arm is reachable.
#[derive(Clone, Debug)]
pub(crate) enum Reachability {
    /// The arm is reachable. This additionally carries a set of or-pattern branches that have been
    /// found to be unreachable despite the overall arm being reachable. Used only in the presence
    /// of or-patterns, otherwise it stays empty.
    Reachable(Vec<Span>),
    /// The arm is unreachable.
    Unreachable,
}

/// The output of checking a match for exhaustiveness and arm reachability.
pub(crate) struct UsefulnessReport<'p, 'tcx> {
    /// For each arm of the input, whether that arm is reachable after the arms above it.
    pub(crate) arm_usefulness: Vec<(MatchArm<'p, 'tcx>, Reachability)>,
    /// If the match is exhaustive, this is empty. If not, this contains witnesses for the lack of
    /// exhaustiveness.
    pub(crate) non_exhaustiveness_witnesses: Vec<WitnessPat<'tcx>>,
}

/// The entrypoint for the usefulness algorithm. Computes whether a match is exhaustive and which
/// of its arms are reachable.
///
/// Note: the input patterns must have been lowered through
/// `check_match::MatchVisitor::lower_pattern`.
#[instrument(skip(cx, arms), level = "debug")]
pub(crate) fn compute_match_usefulness<'p, 'tcx>(
    cx: &MatchCheckCtxt<'p, 'tcx>,
    arms: &[MatchArm<'p, 'tcx>],
    lint_root: HirId,
    scrut_ty: Ty<'tcx>,
    scrut_span: Span,
) -> UsefulnessReport<'p, 'tcx> {
    let mut matrix = Matrix::empty();
    for (row_id, arm) in arms.iter().enumerate() {
        let v = PatStack::from_pattern(arm.pat, row_id, arm.has_guard);
        matrix.push(v);
    }

    let wild_pattern = cx.pattern_arena.alloc(DeconstructedPat::wildcard(scrut_ty, DUMMY_SP));
    let wildcard_row = PatStack::from_pattern(wild_pattern, usize::MAX, false);
    let non_exhaustiveness_witnesses = compute_usefulness(cx, &mut matrix, &wildcard_row, true);
    let non_exhaustiveness_witnesses: Vec<_> = non_exhaustiveness_witnesses.single_column();
    let arm_usefulness: Vec<_> = arms
        .iter()
        .copied()
        .map(|arm| {
            debug!(?arm);
            let reachability = if arm.pat.is_reachable() {
                Reachability::Reachable(arm.pat.unreachable_spans())
            } else {
                Reachability::Unreachable
            };
            (arm, reachability)
        })
        .collect();

    let pat_column = PatternColumn::new(matrix.heads().collect());
    lint_overlapping_range_endpoints(cx, &pat_column, lint_root);

    // Run the non_exhaustive_omitted_patterns lint. Only run on refutable patterns to avoid hitting
    // `if let`s. Only run if the match is exhaustive otherwise the error is redundant.
    if cx.refutable
        && non_exhaustiveness_witnesses.is_empty()
        && !matches!(
            cx.tcx.lint_level_at_node(NON_EXHAUSTIVE_OMITTED_PATTERNS, lint_root).0,
            rustc_session::lint::Level::Allow
        )
    {
        let witnesses = collect_nonexhaustive_missing_variants(cx, &pat_column);
        if !witnesses.is_empty() {
            // Report that a match of a `non_exhaustive` enum marked with `non_exhaustive_omitted_patterns`
            // is not exhaustive enough.
            //
            // NB: The partner lint for structs lives in `compiler/rustc_hir_analysis/src/check/pat.rs`.
            cx.tcx.emit_spanned_lint(
                NON_EXHAUSTIVE_OMITTED_PATTERNS,
                lint_root,
                scrut_span,
                NonExhaustiveOmittedPattern {
                    scrut_ty,
                    uncovered: Uncovered::new(scrut_span, cx, witnesses),
                },
            );
        }
    }

    UsefulnessReport { arm_usefulness, non_exhaustiveness_witnesses }
}
