  λ(JSON : Type)
→ λ ( json
    : { array : List JSON → JSON
      , bool : Bool → JSON
      , double : Double → JSON
      , integer : Integer → JSON
      , null : JSON
      , object : List { mapKey : Text, mapValue : JSON } → JSON
      , string : Text → JSON
      }
    )
→ json.object
    [ { mapKey = "jobs"
      , mapValue =
          json.object
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
                                      json.string
                                        "src/ci/scripts/install-wix.sh"
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
                                  , mapValue =
                                      json.string "enable ipv6 on Docker"
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
                                        , { mapKey =
                                              "TOOLSTATE_REPO_ACCESS_TOKEN"
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
                      , mapValue =
                          json.object
                            [ { mapKey = "matrix"
                              , mapValue =
                                  json.object
                                    [ { mapKey = "include"
                                      , mapValue =
                                          json.array
                                            [ json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "arm-android"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "armhf-gnu"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-aarch64-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "dist-android"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-arm-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-armhf-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-armv7-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-i586-gnu-i586-i686-musl"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-i686-freebsd"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-i686-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-mips-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-mips64-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-mips64el-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-mipsel-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-powerpc-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-powerpc64-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-powerpc64le-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-s390x-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-various-1"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-various-2"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-freebsd"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey = "IMAGE"
                                                          , mapValue =
                                                              json.string
                                                                "dist-x86_64-linux"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-linux-alt"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-musl"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-netbsd"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "i686-gnu"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "i686-gnu-nopt"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "mingw-check"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "test-various"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "wasm32"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "x86_64-gnu"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-aux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-debug"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-distcheck"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-full-bootstrap"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "RUST_BACKTRACE"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-llvm-7"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-nopt"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "DEPLOY_TOOLSTATES_JSON"
                                                          , mapValue =
                                                              json.string
                                                                "toolstates-linux.json"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-tools"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "DIST_REQUIRE_ALL_TOOLS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "MACOSX_DEPLOYMENT_TARGET"
                                                          , mapValue =
                                                              json.double 10.7
                                                          }
                                                        , { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUSTC_RETRY_LINKER_ON_SEGFAULT"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--target=aarch64-apple-ios,x86_64-apple-ios --enable-full-tools --enable-sanitizers --enable-profiler --set rust.jemalloc"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "./x.py dist"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-apple"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string "macos-latest"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "MACOSX_DEPLOYMENT_TARGET"
                                                          , mapValue =
                                                              json.double 10.7
                                                          }
                                                        , { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUSTC_RETRY_LINKER_ON_SEGFAULT"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--enable-extended --enable-profiler --set rust.jemalloc"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "./x.py dist"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-apple-alt"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string "macos-latest"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "MACOSX_DEPLOYMENT_TARGET"
                                                          , mapValue =
                                                              json.double 10.8
                                                          }
                                                        , { mapKey =
                                                              "MACOSX_STD_DEPLOYMENT_TARGET"
                                                          , mapValue =
                                                              json.double 10.7
                                                          }
                                                        , { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUSTC_RETRY_LINKER_ON_SEGFAULT"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-apple-darwin --enable-sanitizers --enable-profiler --set rust.jemalloc"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "./x.py test"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "x86_64-apple"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string "macos-latest"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-msvc --enable-profiler"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "make ci-subset-1"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-msvc-1"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-msvc --enable-profiler"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "make ci-subset-2"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-msvc-2"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=i686-pc-windows-msvc"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "make ci-subset-1"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "i686-msvc-1"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=i686-pc-windows-msvc"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "make ci-subset-2"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "i686-msvc-2"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "RUST_CHECK_TARGET"
                                                          , mapValue =
                                                              json.string
                                                                "check-aux EXCLUDE_CARGO=1"
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-msvc"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-msvc-aux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-msvc"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "python x.py test src/tools/cargotest src/tools/cargo"
                                                          }
                                                        , { mapKey =
                                                              "VCVARS_BAT"
                                                          , mapValue =
                                                              json.string
                                                                "vcvars64.bat"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-msvc-cargo"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-msvc --save-toolstates=/tmp/toolstate/toolstates.json"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "src/ci/docker/x86_64-gnu-tools/checktools.sh x.py /tmp/toolstate/toolstates.json windows"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-msvc-tools"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "CUSTOM_MINGW"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=i686-pc-windows-gnu"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "make ci-mingw-subset-1"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "i686-mingw-1"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "CUSTOM_MINGW"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=i686-pc-windows-gnu"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "make ci-mingw-subset-2"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "i686-mingw-2"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "CUSTOM_MINGW"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_DEBUG_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "NO_LLVM_ASSERTIONS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-gnu"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "make ci-mingw-subset-1"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-mingw-1"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "CUSTOM_MINGW"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-gnu"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "make ci-mingw-subset-2"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-mingw-2"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "DIST_REQUIRE_ALL_TOOLS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-msvc --target=x86_64-pc-windows-msvc,aarch64-pc-windows-msvc --enable-full-tools --enable-profiler"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "python x.py dist"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-msvc"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "DIST_REQUIRE_ALL_TOOLS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=i686-pc-windows-msvc --target=i586-pc-windows-msvc --enable-full-tools --enable-profiler"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "python x.py dist"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-i686-msvc"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "CUSTOM_MINGW"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "DIST_REQUIRE_ALL_TOOLS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=i686-pc-windows-gnu --enable-full-tools --enable-profiler"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "python x.py dist"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-i686-mingw"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "CUSTOM_MINGW"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "DIST_REQUIRE_ALL_TOOLS"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        , { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-gnu --enable-full-tools --enable-profiler"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "python x.py dist"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-mingw"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "RUST_CONFIGURE_ARGS"
                                                          , mapValue =
                                                              json.string
                                                                "--build=x86_64-pc-windows-msvc --enable-extended --enable-profiler"
                                                          }
                                                        , { mapKey = "SCRIPT"
                                                          , mapValue =
                                                              json.string
                                                                "python x.py dist"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-msvc-alt"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "windows-latest-xl"
                                                  }
                                                ]
                                            ]
                                      }
                                    , { mapKey = "name"
                                      , mapValue =
                                          json.array
                                            [ json.string "arm-android"
                                            , json.string "armhf-gnu"
                                            , json.string "dist-aarch64-linux"
                                            , json.string "dist-android"
                                            , json.string "dist-arm-linux"
                                            , json.string "dist-armhf-linux"
                                            , json.string "dist-armv7-linux"
                                            , json.string
                                                "dist-i586-gnu-i586-i686-musl"
                                            , json.string "dist-i686-freebsd"
                                            , json.string "dist-i686-linux"
                                            , json.string "dist-i686-mingw"
                                            , json.string "dist-i686-msvc"
                                            , json.string "dist-mips-linux"
                                            , json.string "dist-mips64-linux"
                                            , json.string "dist-mips64el-linux"
                                            , json.string "dist-mipsel-linux"
                                            , json.string "dist-powerpc-linux"
                                            , json.string "dist-powerpc64-linux"
                                            , json.string
                                                "dist-powerpc64le-linux"
                                            , json.string "dist-s390x-linux"
                                            , json.string "dist-various-1"
                                            , json.string "dist-various-2"
                                            , json.string "dist-x86_64-apple"
                                            , json.string
                                                "dist-x86_64-apple-alt"
                                            , json.string "dist-x86_64-freebsd"
                                            , json.string "dist-x86_64-linux"
                                            , json.string
                                                "dist-x86_64-linux-alt"
                                            , json.string "dist-x86_64-mingw"
                                            , json.string "dist-x86_64-msvc"
                                            , json.string "dist-x86_64-msvc-alt"
                                            , json.string "dist-x86_64-musl"
                                            , json.string "dist-x86_64-netbsd"
                                            , json.string "i686-gnu"
                                            , json.string "i686-gnu-nopt"
                                            , json.string "i686-mingw-1"
                                            , json.string "i686-mingw-2"
                                            , json.string "i686-msvc-1"
                                            , json.string "i686-msvc-2"
                                            , json.string "mingw-check"
                                            , json.string "test-various"
                                            , json.string "wasm32"
                                            , json.string "x86_64-apple"
                                            , json.string "x86_64-gnu"
                                            , json.string "x86_64-gnu-aux"
                                            , json.string "x86_64-gnu-debug"
                                            , json.string "x86_64-gnu-distcheck"
                                            , json.string
                                                "x86_64-gnu-full-bootstrap"
                                            , json.string "x86_64-gnu-llvm-7"
                                            , json.string "x86_64-gnu-nopt"
                                            , json.string "x86_64-gnu-tools"
                                            , json.string "x86_64-mingw-1"
                                            , json.string "x86_64-mingw-2"
                                            , json.string "x86_64-msvc-1"
                                            , json.string "x86_64-msvc-2"
                                            , json.string "x86_64-msvc-aux"
                                            , json.string "x86_64-msvc-cargo"
                                            , json.string "x86_64-msvc-tools"
                                            ]
                                      }
                                    ]
                              }
                            ]
                      }
                    , { mapKey = "timeout-minutes"
                      , mapValue = json.integer +600
                      }
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
                                        [ { mapKey =
                                              "TOOLSTATE_REPO_ACCESS_TOKEN"
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
                                      json.string
                                        "src/ci/scripts/install-wix.sh"
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
                                  , mapValue =
                                      json.string "enable ipv6 on Docker"
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
                                        , { mapKey =
                                              "TOOLSTATE_REPO_ACCESS_TOKEN"
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
                      , mapValue =
                          json.object
                            [ { mapKey = "matrix"
                              , mapValue =
                                  json.object
                                    [ { mapKey = "include"
                                      , mapValue =
                                          json.array
                                            [ json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string "mingw-check"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-llvm-7"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey =
                                                              "CI_ONLY_WHEN_SUBMODULES_CHANGED"
                                                          , mapValue =
                                                              json.integer +1
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "x86_64-gnu-tools"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            ]
                                      }
                                    , { mapKey = "name"
                                      , mapValue =
                                          json.array
                                            [ json.string "mingw-check"
                                            , json.string "x86_64-gnu-llvm-7"
                                            , json.string "x86_64-gnu-tools"
                                            ]
                                      }
                                    ]
                              }
                            ]
                      }
                    , { mapKey = "timeout-minutes"
                      , mapValue = json.integer +600
                      }
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
                                      json.string
                                        "src/ci/scripts/install-wix.sh"
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
                                  , mapValue =
                                      json.string "enable ipv6 on Docker"
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
                                        , { mapKey =
                                              "TOOLSTATE_REPO_ACCESS_TOKEN"
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
                      , mapValue =
                          json.object
                            [ { mapKey = "matrix"
                              , mapValue =
                                  json.object
                                    [ { mapKey = "include"
                                      , mapValue =
                                          json.array
                                            [ json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        ( [] : List
                                                                 { mapKey : Text
                                                                 , mapValue :
                                                                     JSON
                                                                 }
                                                        )
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-linux"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            , json.object
                                                [ { mapKey = "env"
                                                  , mapValue =
                                                      json.object
                                                        [ { mapKey = "IMAGE"
                                                          , mapValue =
                                                              json.string
                                                                "dist-x86_64-linux"
                                                          }
                                                        ]
                                                  }
                                                , { mapKey = "name"
                                                  , mapValue =
                                                      json.string
                                                        "dist-x86_64-linux-alt"
                                                  }
                                                , { mapKey = "os"
                                                  , mapValue =
                                                      json.string
                                                        "ubuntu-latest-xl"
                                                  }
                                                ]
                                            ]
                                      }
                                    , { mapKey = "name"
                                      , mapValue =
                                          json.array
                                            [ json.string "dist-x86_64-linux"
                                            , json.string
                                                "dist-x86_64-linux-alt"
                                            ]
                                      }
                                    ]
                              }
                            ]
                      }
                    , { mapKey = "timeout-minutes"
                      , mapValue = json.integer +600
                      }
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
      }
    , { mapKey = "name", mapValue = json.string "CI" }
    , { mapKey = "on"
      , mapValue =
          json.object
            [ { mapKey = "pull_request"
              , mapValue =
                  json.object
                    [ { mapKey = "branches"
                      , mapValue = json.array [ json.string "**" ]
                      }
                    ]
              }
            , { mapKey = "push"
              , mapValue =
                  json.object
                    [ { mapKey = "branches"
                      , mapValue =
                          json.array
                            [ json.string "auto"
                            , json.string "try"
                            , json.string "master"
                            ]
                      }
                    ]
              }
            ]
      }
    ]
