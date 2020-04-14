let List/map =
          \(a : Type)
      ->  \(b : Type)
      ->  \(f : a -> b)
      ->  \(xs : List a)
      ->  List/build
            b
            (     \(list : Type)
              ->  \(cons : b -> list -> list)
              ->  List/fold a xs list (\(x : a) -> cons (f x))
            )

let Entry = \(k : Type) -> \(v : Type) -> { mapKey : k, mapValue : v }

let Map = \(k : Type) -> \(v : Type) -> List (Entry k v)

in  { List =
      { map = List/map
      , null =
          \(a : Type) -> \(xs : List a) -> Natural/isZero (List/length a xs)
      }
    , Map =
      { Entry
      , Type = Map
      , empty = \(k : Type) -> \(v : Type) -> [] : Map k v
      , map =
              \(k : Type)
          ->  \(a : Type)
          ->  \(b : Type)
          ->  \(f : a -> b)
          ->  \(m : Map k a)
          ->  List/map
                (Entry k a)
                (Entry k b)
                (     \(before : Entry k a)
                  ->  { mapKey = before.mapKey, mapValue = f before.mapValue }
                )
                m
      }
    , Text.concatMapSep =
            \(separator : Text)
        ->  \(a : Type)
        ->  \(f : a -> Text)
        ->  \(elements : List a)
        ->  let Status = < Empty | NonEmpty : Text >

            let status =
                  List/fold
                    a
                    elements
                    Status
                    (     \(x : a)
                      ->  \(status : Status)
                      ->  merge
                            { Empty = Status.NonEmpty (f x)
                            , NonEmpty =
                                    \(result : Text)
                                ->  Status.NonEmpty (f x ++ separator ++ result)
                            }
                            status
                    )
                    Status.Empty

            in  merge
                  { Empty = "", NonEmpty = \(result : Text) -> result }
                  status
    }
