let Prelude =
      https://prelude.dhall-lang.org/v15.0.0/package.dhall sha256:6b90326dc39ab738d7ed87b970ba675c496bed0194071b332840a87261649dcd

let JSONF =
        λ(JSON : Type)
      → { array : List JSON → JSON
        , bool : Bool → JSON
        , double : Double → JSON
        , integer : Integer → JSON
        , null : JSON
        , object : List { mapKey : Text, mapValue : JSON } → JSON
        , string : Text → JSON
        }

let JSON = Prelude.JSON.Type

let json = Prelude.JSON.(JSONF JSON)

let toplevel_json = json

let MatrixEntry =
      { Type =
          { name : Text
          , env : List { mapKey : Text, mapValue : JSON }
          , os : Text
          }
      , default.env = [] : List { mapKey : Text, mapValue : JSON }
      }

let make_name =
        λ(entries : List MatrixEntry.Type)
      → json.array
          ( Prelude.List.map
              MatrixEntry.Type
              JSON
              (λ(entry : MatrixEntry.Type) → json.string entry.name)
              entries
          )

let make_include =
        λ(entries : List MatrixEntry.Type)
      → json.array
          ( Prelude.List.map
              MatrixEntry.Type
              JSON
              (   λ(entry : MatrixEntry.Type)
                → json.object
                    ( toMap
                        { env = json.object entry.env
                        , name = json.string entry.name
                        , os = json.string entry.os
                        }
                    )
              )
              entries
          )

let make_strategy =
        λ(entries : List MatrixEntry.Type)
      → json.object
          [ { mapKey = "matrix"
            , mapValue =
                json.object
                  ( toMap
                      { include = make_include entries
                      , name = make_name entries
                      }
                  )
            }
          ]

let LinuxXL =
      { Type = MatrixEntry.Type
      , default = MatrixEntry.default ⫽ { os = "ubuntu-latest-xl" }
      }

let basic_linux_xl = λ(name : Text) → LinuxXL::{ name }

let pr_strategy =
      [ basic_linux_xl "mingw-check"
      , basic_linux_xl "x86_64-gnu-llvm-7"
      , LinuxXL::{
        , env = toMap
            { CI_ONLY_WHEN_SUBMODULES_CHANGED = json.integer +1 }
        , name = "x86_64-gnu-tools"
        }
      ]

let try_strategy =
      [ basic_linux_xl "dist-x86_64-linux"
      , LinuxXL::{
        , env = toMap { IMAGE = json.string "dist-x86_64-linux" }
        , name = "dist-x86_64-linux-alt"
        }
      ]

let auto_strategy =
      [ basic_linux_xl "arm-android"
      , basic_linux_xl "armhf-gnu"
      , basic_linux_xl "dist-aarch64-linux"
      , basic_linux_xl "dist-android"
      , basic_linux_xl "dist-arm-linux"
      , basic_linux_xl "dist-armhf-linux"
      , basic_linux_xl "dist-armv7-linux"
      , basic_linux_xl "dist-i586-gnu-i586-i686-musl"
      , basic_linux_xl "dist-i686-freebsd"
      , basic_linux_xl "dist-i686-linux"
      , basic_linux_xl "dist-mips-linux"
      , basic_linux_xl "dist-mips64-linux"
      , basic_linux_xl "dist-mips64el-linux"
      , basic_linux_xl "dist-mipsel-linux"
      , basic_linux_xl "dist-powerpc-linux"
      , basic_linux_xl "dist-powerpc64-linux"
      , basic_linux_xl "dist-powerpc64le-linux"
      , basic_linux_xl "dist-s390x-linux"
      , basic_linux_xl "dist-various-1"
      , basic_linux_xl "dist-various-2"
      , basic_linux_xl "dist-x86_64-freebsd"
      , basic_linux_xl "dist-x86_64-linux"
      , LinuxXL::{
        , env = toMap { IMAGE = json.string "dist-x86_64-linux" }
        , name = "dist-x86_64-linux-alt"
        }
      , basic_linux_xl "dist-x86_64-musl"
      , basic_linux_xl "dist-x86_64-netbsd"
      , basic_linux_xl "i686-gnu"
      , basic_linux_xl "i686-gnu-nopt"
      , basic_linux_xl "mingw-check"
      , basic_linux_xl "test-various"
      , basic_linux_xl "wasm32"
      , basic_linux_xl "x86_64-gnu"
      , basic_linux_xl "x86_64-gnu-aux"
      , basic_linux_xl "x86_64-gnu-debug"
      , basic_linux_xl "x86_64-gnu-distcheck"
      , basic_linux_xl "x86_64-gnu-full-bootstrap"
      , LinuxXL::{
        , env = toMap { RUST_BACKTRACE = json.integer +1 }
        , name = "x86_64-gnu-llvm-7"
        }
      , basic_linux_xl "x86_64-gnu-nopt"
      , LinuxXL::{
        , env = toMap { DEPLOY_TOOLSTATES_JSON = json.string "toolstates-linux.json" }
        , name = "x86_64-gnu-tools"
        }
      ]

let jobs =
        λ(JSON : Type)
      → λ(json : JSONF JSON)
      → json.object
          [ { mapKey = "auto"
            , mapValue =
                json.object
                  [ { mapKey = "env"
                    , mapValue =
                        json.object
                          [ { mapKey = "ARTIFACTS_AWS_ACCESS_KEY_ID"
                            , mapValue = json.string "AKIA46X5W6CZH5AYXDVF"
                            }
                          , { mapKey = "CACHES_AWS_ACCESS_KEY_ID"
                            , mapValue = json.string "AKIA46X5W6CZOMUQATD5"
                            }
                          , { mapKey = "CI_JOB_NAME"
                            , mapValue = json.string "\${{ matrix.name }}"
                            }
                          , { mapKey = "DEPLOY_BUCKET"
                            , mapValue = json.string "rust-lang-gha"
                            }
                          , { mapKey = "SCCACHE_BUCKET"
                            , mapValue = json.string "rust-lang-gha-caches"
                            }
                          , { mapKey = "TOOLSTATE_ISSUES_API_URL"
                            , mapValue =
                                json.string
                                  "https://api.github.com/repos/pietroalbini/rust-toolstate/issues"
                            }
                          , { mapKey = "TOOLSTATE_PUBLISH"
                            , mapValue = json.integer +1
                            }
                          , { mapKey = "TOOLSTATE_REPO"
                            , mapValue =
                                json.string
                                  "https://github.com/pietroalbini/rust-toolstate"
                            }
                          ]
                    }
                  , { mapKey = "if"
                    , mapValue =
                        json.string
                          "github.event_name == 'push' && github.ref == 'refs/heads/auto' && github.repository == 'rust-lang-ci/rust'"
                    }
                  , { mapKey = "name", mapValue = json.string "auto" }
                  , { mapKey = "runs-on"
                    , mapValue = json.string "\${{ matrix.os }}"
                    }
                  , { mapKey = "steps"
                    , mapValue =
                        json.array
                          [ json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "git config --global core.autocrlf false"
                                }
                              , { mapKey = "shell"
                                , mapValue = json.string "bash"
                                }
                              ]
                          , json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "checkout the source code"
                                }
                              , { mapKey = "uses"
                                , mapValue = json.string "actions/checkout@v1"
                                }
                              , { mapKey = "with"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "fetch-depth"
                                        , mapValue = json.integer +2
                                        }
                                      ]
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string
                                      "success() && !env.SKIP_JOB && github.ref != 'refs/heads/try'"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "configure GitHub Actions to kill the build when outdated"
                                }
                              , { mapKey = "uses"
                                , mapValue =
                                    json.string
                                      "rust-lang/simpleinfra/github-actions/cancel-outdated-builds@master"
                                }
                              , { mapKey = "with"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "github_token"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets.github_token }}"
                                        }
                                      ]
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "EXTRA_VARIABLES"
                                        , mapValue =
                                            json.string
                                              "\${{ toJson(matrix.env) }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "add extra environment variables"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/setup-environment.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "decide whether to skip this job"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/should-skip-this.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "collect CPU statistics"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/collect-cpu-stats.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "show the current environment"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/dump-environment.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install awscli"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-awscli.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install sccache"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-sccache.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install clang"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-clang.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install WIX"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string "src/ci/scripts/install-wix.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install InnoSetup"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-innosetup.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "ensure the build happens on a partition with enough space"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/symlink-build-dir.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/disable-git-crlf-conversion.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install MSYS2"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-msys2.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "install MSYS2 packages"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-msys2-packages.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install MinGW"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-mingw.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install ninja"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-ninja.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "enable ipv6 on Docker"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/enable-docker-ipv6.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/disable-git-crlf-conversion.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "checkout submodules"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/checkout-submodules.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "ensure line endings are correct"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/verify-line-endings.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "AWS_ACCESS_KEY_ID"
                                        , mapValue =
                                            json.string
                                              "\${{ env.CACHES_AWS_ACCESS_KEY_ID }}"
                                        }
                                      , { mapKey = "AWS_SECRET_ACCESS_KEY"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.CACHES_AWS_ACCESS_KEY_ID)] }}"
                                        }
                                      , { mapKey = "TOOLSTATE_REPO_ACCESS_TOKEN"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "run the build"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/run-build-from-ci.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "AWS_ACCESS_KEY_ID"
                                        , mapValue =
                                            json.string
                                              "\${{ env.ARTIFACTS_AWS_ACCESS_KEY_ID }}"
                                        }
                                      , { mapKey = "AWS_SECRET_ACCESS_KEY"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.ARTIFACTS_AWS_ACCESS_KEY_ID)] }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string
                                      "success() && !env.SKIP_JOB && (github.event_name == 'push' || env.DEPLOY == '1' || env.DEPLOY_ALT == '1')"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "upload artifacts to S3"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/upload-artifacts.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          ]
                    }
                  , { mapKey = "strategy"
                    , mapValue = make_strategy auto_strategy JSON json
                    }
                  , { mapKey = "timeout-minutes", mapValue = json.integer +600 }
                  ]
            }
          , { mapKey = "auto-failure"
            , mapValue =
                json.object
                  [ { mapKey = "if"
                    , mapValue =
                        json.string
                          "!success() && github.event_name == 'push' && github.ref == 'refs/heads/auto' && github.repository == 'rust-lang-ci/rust'"
                    }
                  , { mapKey = "name"
                    , mapValue = json.string "bors build finished"
                    }
                  , { mapKey = "needs"
                    , mapValue = json.array [ json.string "auto" ]
                    }
                  , { mapKey = "runs-on"
                    , mapValue = json.string "ubuntu-latest"
                    }
                  , { mapKey = "steps"
                    , mapValue =
                        json.array
                          [ json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "mark the job as a failure"
                                }
                              , { mapKey = "run"
                                , mapValue = json.string "exit 1"
                                }
                              ]
                          ]
                    }
                  ]
            }
          , { mapKey = "auto-success"
            , mapValue =
                json.object
                  [ { mapKey = "if"
                    , mapValue =
                        json.string
                          "success() && github.event_name == 'push' && github.ref == 'refs/heads/auto' && github.repository == 'rust-lang-ci/rust'"
                    }
                  , { mapKey = "name"
                    , mapValue = json.string "bors build finished"
                    }
                  , { mapKey = "needs"
                    , mapValue = json.array [ json.string "auto" ]
                    }
                  , { mapKey = "runs-on"
                    , mapValue = json.string "ubuntu-latest"
                    }
                  , { mapKey = "steps"
                    , mapValue =
                        json.array
                          [ json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "mark the job as a success"
                                }
                              , { mapKey = "run"
                                , mapValue = json.string "exit 0"
                                }
                              ]
                          ]
                    }
                  ]
            }
          , { mapKey = "master"
            , mapValue =
                json.object
                  [ { mapKey = "env"
                    , mapValue =
                        json.object
                          [ { mapKey = "ARTIFACTS_AWS_ACCESS_KEY_ID"
                            , mapValue = json.string "AKIA46X5W6CZH5AYXDVF"
                            }
                          , { mapKey = "CACHES_AWS_ACCESS_KEY_ID"
                            , mapValue = json.string "AKIA46X5W6CZOMUQATD5"
                            }
                          , { mapKey = "DEPLOY_BUCKET"
                            , mapValue = json.string "rust-lang-gha"
                            }
                          , { mapKey = "SCCACHE_BUCKET"
                            , mapValue = json.string "rust-lang-gha-caches"
                            }
                          , { mapKey = "TOOLSTATE_ISSUES_API_URL"
                            , mapValue =
                                json.string
                                  "https://api.github.com/repos/pietroalbini/rust-toolstate/issues"
                            }
                          , { mapKey = "TOOLSTATE_PUBLISH"
                            , mapValue = json.integer +1
                            }
                          , { mapKey = "TOOLSTATE_REPO"
                            , mapValue =
                                json.string
                                  "https://github.com/pietroalbini/rust-toolstate"
                            }
                          ]
                    }
                  , { mapKey = "if"
                    , mapValue =
                        json.string
                          "github.event_name == 'push' && github.ref == 'refs/heads/master' && github.repository == 'rust-lang-ci/rust'"
                    }
                  , { mapKey = "name", mapValue = json.string "master" }
                  , { mapKey = "runs-on"
                    , mapValue = json.string "ubuntu-latest"
                    }
                  , { mapKey = "steps"
                    , mapValue =
                        json.array
                          [ json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "checkout the source code"
                                }
                              , { mapKey = "uses"
                                , mapValue = json.string "actions/checkout@v1"
                                }
                              , { mapKey = "with"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "fetch-depth"
                                        , mapValue = json.integer +2
                                        }
                                      ]
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "TOOLSTATE_REPO_ACCESS_TOKEN"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "publish toolstate"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string "src/ci/publish_toolstate.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          ]
                    }
                  ]
            }
          , { mapKey = "pr"
            , mapValue =
                json.object
                  [ { mapKey = "env"
                    , mapValue =
                        json.object
                          [ { mapKey = "CI_JOB_NAME"
                            , mapValue = json.string "\${{ matrix.name }}"
                            }
                          , { mapKey = "SCCACHE_BUCKET"
                            , mapValue = json.string "rust-lang-gha-caches"
                            }
                          , { mapKey = "TOOLSTATE_REPO"
                            , mapValue =
                                json.string
                                  "https://github.com/pietroalbini/rust-toolstate"
                            }
                          ]
                    }
                  , { mapKey = "if"
                    , mapValue =
                        json.string "github.event_name == 'pull_request'"
                    }
                  , { mapKey = "name", mapValue = json.string "PR" }
                  , { mapKey = "runs-on"
                    , mapValue = json.string "\${{ matrix.os }}"
                    }
                  , { mapKey = "steps"
                    , mapValue =
                        json.array
                          [ json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "git config --global core.autocrlf false"
                                }
                              , { mapKey = "shell"
                                , mapValue = json.string "bash"
                                }
                              ]
                          , json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "checkout the source code"
                                }
                              , { mapKey = "uses"
                                , mapValue = json.string "actions/checkout@v1"
                                }
                              , { mapKey = "with"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "fetch-depth"
                                        , mapValue = json.integer +2
                                        }
                                      ]
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string
                                      "success() && !env.SKIP_JOB && github.ref != 'refs/heads/try'"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "configure GitHub Actions to kill the build when outdated"
                                }
                              , { mapKey = "uses"
                                , mapValue =
                                    json.string
                                      "rust-lang/simpleinfra/github-actions/cancel-outdated-builds@master"
                                }
                              , { mapKey = "with"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "github_token"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets.github_token }}"
                                        }
                                      ]
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "EXTRA_VARIABLES"
                                        , mapValue =
                                            json.string
                                              "\${{ toJson(matrix.env) }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "add extra environment variables"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/setup-environment.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "decide whether to skip this job"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/should-skip-this.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "collect CPU statistics"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/collect-cpu-stats.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "show the current environment"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/dump-environment.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install awscli"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-awscli.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install sccache"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-sccache.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install clang"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-clang.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install WIX"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string "src/ci/scripts/install-wix.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install InnoSetup"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-innosetup.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "ensure the build happens on a partition with enough space"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/symlink-build-dir.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/disable-git-crlf-conversion.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install MSYS2"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-msys2.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "install MSYS2 packages"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-msys2-packages.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install MinGW"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-mingw.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install ninja"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-ninja.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "enable ipv6 on Docker"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/enable-docker-ipv6.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/disable-git-crlf-conversion.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "checkout submodules"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/checkout-submodules.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "ensure line endings are correct"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/verify-line-endings.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "AWS_ACCESS_KEY_ID"
                                        , mapValue =
                                            json.string
                                              "\${{ env.CACHES_AWS_ACCESS_KEY_ID }}"
                                        }
                                      , { mapKey = "AWS_SECRET_ACCESS_KEY"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.CACHES_AWS_ACCESS_KEY_ID)] }}"
                                        }
                                      , { mapKey = "TOOLSTATE_REPO_ACCESS_TOKEN"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "run the build"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/run-build-from-ci.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "AWS_ACCESS_KEY_ID"
                                        , mapValue =
                                            json.string
                                              "\${{ env.ARTIFACTS_AWS_ACCESS_KEY_ID }}"
                                        }
                                      , { mapKey = "AWS_SECRET_ACCESS_KEY"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.ARTIFACTS_AWS_ACCESS_KEY_ID)] }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string
                                      "success() && !env.SKIP_JOB && (github.event_name == 'push' || env.DEPLOY == '1' || env.DEPLOY_ALT == '1')"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "upload artifacts to S3"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/upload-artifacts.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          ]
                    }
                  , { mapKey = "strategy"
                    , mapValue = make_strategy pr_strategy JSON json
                    }
                  , { mapKey = "timeout-minutes", mapValue = json.integer +600 }
                  ]
            }
          , { mapKey = "try"
            , mapValue =
                json.object
                  [ { mapKey = "env"
                    , mapValue =
                        json.object
                          [ { mapKey = "ARTIFACTS_AWS_ACCESS_KEY_ID"
                            , mapValue = json.string "AKIA46X5W6CZH5AYXDVF"
                            }
                          , { mapKey = "CACHES_AWS_ACCESS_KEY_ID"
                            , mapValue = json.string "AKIA46X5W6CZOMUQATD5"
                            }
                          , { mapKey = "CI_JOB_NAME"
                            , mapValue = json.string "\${{ matrix.name }}"
                            }
                          , { mapKey = "DEPLOY_BUCKET"
                            , mapValue = json.string "rust-lang-gha"
                            }
                          , { mapKey = "SCCACHE_BUCKET"
                            , mapValue = json.string "rust-lang-gha-caches"
                            }
                          , { mapKey = "TOOLSTATE_ISSUES_API_URL"
                            , mapValue =
                                json.string
                                  "https://api.github.com/repos/pietroalbini/rust-toolstate/issues"
                            }
                          , { mapKey = "TOOLSTATE_PUBLISH"
                            , mapValue = json.integer +1
                            }
                          , { mapKey = "TOOLSTATE_REPO"
                            , mapValue =
                                json.string
                                  "https://github.com/pietroalbini/rust-toolstate"
                            }
                          ]
                    }
                  , { mapKey = "if"
                    , mapValue =
                        json.string
                          "github.event_name == 'push' && github.ref == 'refs/heads/try' && github.repository == 'rust-lang-ci/rust'"
                    }
                  , { mapKey = "name", mapValue = json.string "try" }
                  , { mapKey = "runs-on"
                    , mapValue = json.string "\${{ matrix.os }}"
                    }
                  , { mapKey = "steps"
                    , mapValue =
                        json.array
                          [ json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "git config --global core.autocrlf false"
                                }
                              , { mapKey = "shell"
                                , mapValue = json.string "bash"
                                }
                              ]
                          , json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "checkout the source code"
                                }
                              , { mapKey = "uses"
                                , mapValue = json.string "actions/checkout@v1"
                                }
                              , { mapKey = "with"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "fetch-depth"
                                        , mapValue = json.integer +2
                                        }
                                      ]
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string
                                      "success() && !env.SKIP_JOB && github.ref != 'refs/heads/try'"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "configure GitHub Actions to kill the build when outdated"
                                }
                              , { mapKey = "uses"
                                , mapValue =
                                    json.string
                                      "rust-lang/simpleinfra/github-actions/cancel-outdated-builds@master"
                                }
                              , { mapKey = "with"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "github_token"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets.github_token }}"
                                        }
                                      ]
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "EXTRA_VARIABLES"
                                        , mapValue =
                                            json.string
                                              "\${{ toJson(matrix.env) }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "add extra environment variables"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/setup-environment.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "decide whether to skip this job"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/should-skip-this.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "collect CPU statistics"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/collect-cpu-stats.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "show the current environment"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/dump-environment.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install awscli"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-awscli.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install sccache"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-sccache.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install clang"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-clang.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install WIX"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string "src/ci/scripts/install-wix.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install InnoSetup"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-innosetup.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "ensure the build happens on a partition with enough space"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/symlink-build-dir.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/disable-git-crlf-conversion.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install MSYS2"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-msys2.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "install MSYS2 packages"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-msys2-packages.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install MinGW"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-mingw.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "install ninja"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/install-ninja.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "enable ipv6 on Docker"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/enable-docker-ipv6.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "disable git crlf conversion"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/disable-git-crlf-conversion.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "checkout submodules"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/checkout-submodules.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string
                                      "ensure line endings are correct"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/verify-line-endings.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "AWS_ACCESS_KEY_ID"
                                        , mapValue =
                                            json.string
                                              "\${{ env.CACHES_AWS_ACCESS_KEY_ID }}"
                                        }
                                      , { mapKey = "AWS_SECRET_ACCESS_KEY"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.CACHES_AWS_ACCESS_KEY_ID)] }}"
                                        }
                                      , { mapKey = "TOOLSTATE_REPO_ACCESS_TOKEN"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string "success() && !env.SKIP_JOB"
                                }
                              , { mapKey = "name"
                                , mapValue = json.string "run the build"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/run-build-from-ci.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          , json.object
                              [ { mapKey = "env"
                                , mapValue =
                                    json.object
                                      [ { mapKey = "AWS_ACCESS_KEY_ID"
                                        , mapValue =
                                            json.string
                                              "\${{ env.ARTIFACTS_AWS_ACCESS_KEY_ID }}"
                                        }
                                      , { mapKey = "AWS_SECRET_ACCESS_KEY"
                                        , mapValue =
                                            json.string
                                              "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.ARTIFACTS_AWS_ACCESS_KEY_ID)] }}"
                                        }
                                      ]
                                }
                              , { mapKey = "if"
                                , mapValue =
                                    json.string
                                      "success() && !env.SKIP_JOB && (github.event_name == 'push' || env.DEPLOY == '1' || env.DEPLOY_ALT == '1')"
                                }
                              , { mapKey = "name"
                                , mapValue =
                                    json.string "upload artifacts to S3"
                                }
                              , { mapKey = "run"
                                , mapValue =
                                    json.string
                                      "src/ci/scripts/upload-artifacts.sh"
                                }
                              , { mapKey = "shell"
                                , mapValue =
                                    json.string
                                      "python src/ci/exec-with-shell.py {0}"
                                }
                              ]
                          ]
                    }
                  , { mapKey = "strategy"
                    , mapValue = make_strategy try_strategy JSON json
                    }
                  , { mapKey = "timeout-minutes", mapValue = json.integer +600 }
                  ]
            }
          , { mapKey = "try-failure"
            , mapValue =
                json.object
                  [ { mapKey = "if"
                    , mapValue =
                        json.string
                          "!success() && github.event_name == 'push' && github.ref == 'refs/heads/try' && github.repository == 'rust-lang-ci/rust'"
                    }
                  , { mapKey = "name"
                    , mapValue = json.string "bors build finished"
                    }
                  , { mapKey = "needs"
                    , mapValue = json.array [ json.string "try" ]
                    }
                  , { mapKey = "runs-on"
                    , mapValue = json.string "ubuntu-latest"
                    }
                  , { mapKey = "steps"
                    , mapValue =
                        json.array
                          [ json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "mark the job as a failure"
                                }
                              , { mapKey = "run"
                                , mapValue = json.string "exit 1"
                                }
                              ]
                          ]
                    }
                  ]
            }
          , { mapKey = "try-success"
            , mapValue =
                json.object
                  [ { mapKey = "if"
                    , mapValue =
                        json.string
                          "success() && github.event_name == 'push' && github.ref == 'refs/heads/try' && github.repository == 'rust-lang-ci/rust'"
                    }
                  , { mapKey = "name"
                    , mapValue = json.string "bors build finished"
                    }
                  , { mapKey = "needs"
                    , mapValue = json.array [ json.string "try" ]
                    }
                  , { mapKey = "runs-on"
                    , mapValue = json.string "ubuntu-latest"
                    }
                  , { mapKey = "steps"
                    , mapValue =
                        json.array
                          [ json.object
                              [ { mapKey = "name"
                                , mapValue =
                                    json.string "mark the job as a success"
                                }
                              , { mapKey = "run"
                                , mapValue = json.string "exit 0"
                                }
                              ]
                          ]
                    }
                  ]
            }
          ]

in  { name = "CI"
    , on =
      { push.branches = [ "auto", "try", "master" ]
      , pull_request.branches = [ "**" ]
      }
    , jobs
    }
