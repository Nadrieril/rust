let Prelude = ./Prelude.dhall

let Map = Prelude.Map.Type

let MatrixEntry =
      { Type = { name : Text, env : Map Text Text, os : Text }
      , default.env = Prelude.Map.empty Text Text
      }

let Strategy = List MatrixEntry.Type

let StrategyOutput =
      Optional { matrix : { include : Strategy, name : List Text } }

let make_strategy =
        λ(entries : Strategy)
      →       if Prelude.List.null MatrixEntry.Type entries

        then  None { matrix : { include : Strategy, name : List Text } }

        else  Some
                { matrix =
                  { include = entries
                  , name =
                      Prelude.List.map
                        MatrixEntry.Type
                        Text
                        (λ(entry : MatrixEntry.Type) → entry.name)
                        entries
                  }
                }

let Condition =
      < event_name : Text | ref : Text | repository : Text | success : Bool >

let make_condition =
        λ(conditions : List Condition)
      → Prelude.Text.concatMapSep
          " && "
          Condition
          (   λ(condition : Condition)
            → merge
                { event_name = λ(x : Text) → "github.event_name == '${x}'"
                , ref = λ(x : Text) → "github.ref == '${x}'"
                , repository = λ(x : Text) → "github.repository == '${x}'"
                , success = λ(x : Bool) → "${if x then "" else "!"}success()"
                }
                condition
          )
          conditions

let Step =
      { Type =
          { name : Text
          , run : Optional Text
          , env : Map Text Text
          , with : Map Text Text
          , if : Optional Text
          , uses : Optional Text
          , shell : Optional Text
          }
      , default =
        { env = Prelude.Map.empty Text Text
        , if = None Text
        , run = None Text
        , shell = None Text
        , uses = None Text
        , with = Prelude.Map.empty Text Text
        }
      }

let StepOutput =
      { name : Text
      , run : Optional Text
      , env : Optional (Map Text Text)
      , with : Optional (Map Text Text)
      , if : Optional Text
      , uses : Optional Text
      , shell : Optional Text
      }

let make_step =
        λ(x : Step.Type)
      →   x
        ⫽ { env =
                    if Prelude.List.null (Prelude.Map.Entry Text Text) x.env

              then  None (Map Text Text)

              else  Some x.env
          , with =
                    if Prelude.List.null (Prelude.Map.Entry Text Text) x.with

              then  None (Map Text Text)

              else  Some x.with
          }

let Job =
      { Type =
          { name : Text
          , env : Map Text Text
          , if : List Condition
          , strategy : Strategy
          , steps : List Step.Type
          , timeout-minutes : Optional Natural
          , runs-on : Text
          , needs : List Text
          }
      , default =
        { strategy = [] : Strategy
        , timeout-minutes = None Natural
        , needs = [] : List Text
        , env = Prelude.Map.empty Text Text
        }
      }

let JobOutput =
      { name : Text
      , env : Map Text Text
      , if : Text
      , strategy : StrategyOutput
      , steps : List StepOutput
      , timeout-minutes : Optional Natural
      , runs-on : Text
      , needs : List Text
      }

let make_job =
        λ(job : Job.Type)
      →   job
        ⫽ { strategy = make_strategy job.strategy
          , if = make_condition job.if
          , steps = Prelude.List.map Step.Type StepOutput make_step job.steps
          }

let make_jobs = Prelude.Map.map Text Job.Type JobOutput make_job

let CI =
      { Type =
          { name : Text
          , on : Map Text { branches : List Text }
          , jobs : Map Text Job.Type
          }
      , default = {=}
      }

let make_ci = λ(ci : CI.Type) → ci ⫽ { jobs = make_jobs ci.jobs }

in  { Step, Condition, Job, MatrixEntry, Strategy, CI, make_ci }
