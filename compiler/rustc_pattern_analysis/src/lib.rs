//! Analysis of patterns, notably match exhaustiveness checking.

pub mod constructor;
#[cfg(feature = "rustc")]
pub mod errors;
#[cfg(feature = "rustc")]
pub(crate) mod lints;
pub mod pat;
#[cfg(feature = "rustc")]
pub mod rustc;
pub mod usefulness;

#[macro_use]
extern crate tracing;
#[cfg(feature = "rustc")]
#[macro_use]
extern crate rustc_middle;

#[cfg(feature = "rustc")]
rustc_fluent_macro::fluent_messages! { "../messages.ftl" }

use std::fmt;

use rustc_index::Idx;
#[cfg(feature = "rustc")]
use rustc_middle::ty::Ty;

use crate::constructor::{Constructor, ConstructorSet};
use crate::pat::DeconstructedPat;

// It's not possible to only enable the `typed_arena` dependency when the `rustc` feature is off, so
// we use another feature instead. The crate won't compile if one of these isn't enabled.
#[cfg(feature = "rustc")]
pub(crate) use rustc_arena::TypedArena;
#[cfg(feature = "stable")]
pub(crate) use typed_arena::Arena as TypedArena;

pub trait Captures<'a> {}
impl<'a, T: ?Sized> Captures<'a> for T {}

/// Context that provides type information about constructors.
///
/// Most of the crate is parameterized on a type that implements this trait.
pub trait TypeCx: Sized + Clone + fmt::Debug {
    /// The type of a pattern.
    type Ty: Copy + Clone + fmt::Debug; // FIXME: remove Copy
    /// The index of an enum variant.
    type VariantIdx: Clone + Idx;
    /// A string literal
    type StrLit: Clone + PartialEq + fmt::Debug;
    /// Extra data to store in a match arm.
    type ArmData: Copy + Clone + fmt::Debug;
    /// Extra data to store in a pattern. `Default` needed when we create fictitious wildcard
    /// patterns during analysis.
    type PatData: Clone + Default;

    fn is_opaque_ty(ty: Self::Ty) -> bool;
    fn is_exhaustive_patterns_feature_on(&self) -> bool;
    fn is_min_exhaustive_patterns_feature_on(&self) -> bool;

    /// The number of fields for this constructor.
    fn ctor_arity(&self, ctor: &Constructor<Self>, ty: Self::Ty) -> usize;

    /// The types of the fields for this constructor. The result must have a length of
    /// `ctor_arity()`.
    fn ctor_sub_tys(&self, ctor: &Constructor<Self>, ty: Self::Ty) -> &[Self::Ty];

    /// The set of all the constructors for `ty`.
    ///
    /// This must follow the invariants of `ConstructorSet`
    fn ctors_for_ty(&self, ty: Self::Ty) -> ConstructorSet<Self>;

    /// Best-effort `Debug` implementation.
    fn debug_pat(f: &mut fmt::Formatter<'_>, pat: &DeconstructedPat<'_, Self>) -> fmt::Result;

    /// Raise a bug.
    fn bug(&self, fmt: fmt::Arguments<'_>) -> !;
}

/// Context that provides information global to a match.
#[derive(Clone)]
pub struct MatchCtxt<'a, 'p, Cx: TypeCx> {
    /// The context for type information.
    pub tycx: &'a Cx,
    /// An arena to store the wildcards we produce during analysis.
    pub wildcard_arena: &'a TypedArena<DeconstructedPat<'p, Cx>>,
}

impl<'a, 'p, Cx: TypeCx> Copy for MatchCtxt<'a, 'p, Cx> {}

/// The arm of a match expression.
#[derive(Clone, Debug)]
pub struct MatchArm<'p, Cx: TypeCx> {
    pub pat: &'p DeconstructedPat<'p, Cx>,
    pub has_guard: bool,
    pub arm_data: Cx::ArmData,
}

impl<'p, Cx: TypeCx> Copy for MatchArm<'p, Cx> {}

/// The entrypoint for this crate. Computes whether a match is exhaustive and which of its arms are
/// useful, and runs some lints.
#[cfg(feature = "rustc")]
pub fn analyze_match<'p, 'tcx>(
    tycx: &rustc::RustcMatchCheckCtxt<'p, 'tcx>,
    arms: &[rustc::MatchArm<'p, 'tcx>],
    scrut_ty: Ty<'tcx>,
) -> rustc::UsefulnessReport<'p, 'tcx> {
    use rustc_middle::ty;
    use rustc_session::lint;

    // Arena to store the extra wildcards we construct during analysis.
    let wildcard_arena = tycx.pattern_arena;
    let scrut_validity = usefulness::ValidityConstraint::from_bool(tycx.known_valid_scrutinee);
    let cx = MatchCtxt { tycx, wildcard_arena };

    if !tycx.known_valid_scrutinee && arms.iter().all(|arm| arm.has_guard) {
        let is_directly_empty = match scrut_ty.kind() {
            ty::Adt(def, ..) => {
                def.is_enum()
                    && def.variants().is_empty()
                    && !tycx.is_foreign_non_exhaustive_enum(scrut_ty)
            }
            ty::Never => true,
            _ => false,
        };
        if is_directly_empty {
            if tycx.tcx.features().min_exhaustive_patterns {
                tycx.tcx.emit_spanned_lint(
                    lint::builtin::EMPTY_MATCH_ON_UNSAFE_PLACE,
                    tycx.match_lint_level,
                    tycx.whole_match_span.unwrap_or(tycx.scrut_span),
                    errors::EmptyMatchOnUnsafePlace {
                        scrut_span: tycx.scrut_span,
                        suggestion: errors::EmptyMatchOnUnsafePlaceWrapSuggestion {
                            scrut_start: tycx.scrut_span.shrink_to_lo(),
                            scrut_end: tycx.scrut_span.shrink_to_hi(),
                        },
                    },
                );
            }

            // For backwards compability we allow an empty match in this case.
            return rustc::UsefulnessReport {
                arm_usefulness: Vec::new(),
                non_exhaustiveness_witnesses: Vec::new(),
            };
        }
    }

    let report = usefulness::compute_match_usefulness(cx, arms, scrut_ty, scrut_validity);

    let pat_column = lints::PatternColumn::new(arms);

    // Lint on ranges that overlap on their endpoints, which is likely a mistake.
    lints::lint_overlapping_range_endpoints(cx, &pat_column);

    // Run the non_exhaustive_omitted_patterns lint. Only run on refutable patterns to avoid hitting
    // `if let`s. Only run if the match is exhaustive otherwise the error is redundant.
    if tycx.refutable && report.non_exhaustiveness_witnesses.is_empty() {
        lints::lint_nonexhaustive_missing_variants(cx, arms, &pat_column, scrut_ty)
    }

    report
}
