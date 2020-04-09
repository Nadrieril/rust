let List/map =
        λ(a : Type)
      → λ(b : Type)
      → λ(f : a → b)
      → λ(xs : List a)
      → List/build
          b
          (   λ(list : Type)
            → λ(cons : b → list → list)
            → List/fold a xs list (λ(x : a) → cons (f x))
          )

let Entry = λ(k : Type) → λ(v : Type) → { mapKey : k, mapValue : v }

let Map = λ(k : Type) → λ(v : Type) → List (Entry k v)

in  { List =
      { map = List/map
      , null = λ(a : Type) → λ(xs : List a) → Natural/isZero (List/length a xs)
      }
    , Map =
      { Entry
      , Type = Map
      , empty = λ(k : Type) → λ(v : Type) → [] : Map k v
      , map =
            λ(k : Type)
          → λ(a : Type)
          → λ(b : Type)
          → λ(f : a → b)
          → λ(m : Map k a)
          → List/map
              (Entry k a)
              (Entry k b)
              (   λ(before : Entry k a)
                → { mapKey = before.mapKey, mapValue = f before.mapValue }
              )
              m
      }
    , Text.concatMapSep =
          λ(separator : Text)
        → λ(a : Type)
        → λ(f : a → Text)
        → λ(elements : List a)
        → let Status = < Empty | NonEmpty : Text >

          let status =
                List/fold
                  a
                  elements
                  Status
                  (   λ(x : a)
                    → λ(status : Status)
                    → merge
                        { Empty = Status.NonEmpty (f x)
                        , NonEmpty =
                              λ(result : Text)
                            → Status.NonEmpty (f x ++ separator ++ result)
                        }
                        status
                  )
                  Status.Empty

          in  merge { Empty = "", NonEmpty = λ(result : Text) → result } status
    }
