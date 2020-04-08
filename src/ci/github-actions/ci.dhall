let Prelude =
      https://prelude.dhall-lang.org/v15.0.0/package.dhall sha256:6b90326dc39ab738d7ed87b970ba675c496bed0194071b332840a87261649dcd

let Map = Prelude.Map.Type

let JSONF =
        λ(JSON : Type)
      → { array : List JSON → JSON
        , bool : Bool → JSON
        , double : Double → JSON
        , integer : Integer → JSON
        , null : JSON
        , object : Map Text JSON → JSON
        , string : Text → JSON
        }

let JSON = Prelude.JSON.Type

let json = Prelude.JSON.(JSONF JSON)

let toplevel_json = json

let MatrixEntry =
      { Type = { name : Text, env : Map Text Text, os : Text }
      , default.env = Prelude.Map.empty Text Text
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
                        { env =
                            json.object
                              ( Prelude.Map.map
                                  Text
                                  Text
                                  JSON
                                  json.string
                                  entry.env
                              )
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
          ( toMap
              { matrix =
                  json.object
                    ( toMap
                        { include = make_include entries
                        , name = make_name entries
                        }
                    )
              }
          )

let BaseJob = MatrixEntry.default

let LinuxXL = BaseJob ⫽ { os = "ubuntu-latest-xl" }

let -- We don't have an XL builder for this
    MacOS_XL =
      BaseJob ⫽ { os = "macos-latest" }

let Windows_XL = BaseJob ⫽ { os = "windows-latest-xl" }

let basic_linux_xl = λ(name : Text) → LinuxXL ⫽ { name }

let pr_strategy =
      [ basic_linux_xl "mingw-check"
      , basic_linux_xl "x86_64-gnu-llvm-7"
      ,   LinuxXL
        ⫽ { name = "x86_64-gnu-tools"
          , env = toMap { CI_ONLY_WHEN_SUBMODULES_CHANGED = "1" }
          }
      ]

let try_strategy =
      [ basic_linux_xl "dist-x86_64-linux"
      ,   LinuxXL
        ⫽ { name = "dist-x86_64-linux-alt"
          , env = toMap { IMAGE = "dist-x86_64-linux" }
          }
      ]

let auto_strategy =
      let linux_and_docker =
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
            ,   LinuxXL
              ⫽ { name = "dist-x86_64-linux-alt"
                , env = toMap { IMAGE = "dist-x86_64-linux" }
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
            ,   LinuxXL
              ⫽ { name = "x86_64-gnu-llvm-7"
                , env = toMap { RUST_BACKTRACE = "1" }
                }
            , basic_linux_xl "x86_64-gnu-nopt"
            ,   LinuxXL
              ⫽ { name = "x86_64-gnu-tools"
                , env = toMap
                    { DEPLOY_TOOLSTATES_JSON = "toolstates-linux.json" }
                }
            ]

      let macos =
            [   MacOS_XL
              ⫽ { name = "dist-x86_64-apple"
                , env = toMap
                    { SCRIPT = "./x.py dist"
                    , RUST_CONFIGURE_ARGS =
                        "--target=aarch64-apple-ios,x86_64-apple-ios --enable-full-tools --enable-sanitizers --enable-profiler --set rust.jemalloc"
                    , RUSTC_RETRY_LINKER_ON_SEGFAULT = "1"
                    , MACOSX_DEPLOYMENT_TARGET = "10.7"
                    , NO_LLVM_ASSERTIONS = "1"
                    , NO_DEBUG_ASSERTIONS = "1"
                    , DIST_REQUIRE_ALL_TOOLS = "1"
                    }
                }
            ,   MacOS_XL
              ⫽ { name = "dist-x86_64-apple-alt"
                , env = toMap
                    { SCRIPT = "./x.py dist"
                    , RUST_CONFIGURE_ARGS =
                        "--enable-extended --enable-profiler --set rust.jemalloc"
                    , RUSTC_RETRY_LINKER_ON_SEGFAULT = "1"
                    , MACOSX_DEPLOYMENT_TARGET = "10.7"
                    , NO_LLVM_ASSERTIONS = "1"
                    , NO_DEBUG_ASSERTIONS = "1"
                    }
                }
            ,   MacOS_XL
              ⫽ { name = "x86_64-apple"
                , env = toMap
                    { SCRIPT = "./x.py test"
                    , RUST_CONFIGURE_ARGS =
                        "--build=x86_64-apple-darwin --enable-sanitizers --enable-profiler --set rust.jemalloc"
                    , RUSTC_RETRY_LINKER_ON_SEGFAULT = "1"
                    , MACOSX_DEPLOYMENT_TARGET = "10.8"
                    , MACOSX_STD_DEPLOYMENT_TARGET = "10.7"
                    , NO_LLVM_ASSERTIONS = "1"
                    , NO_DEBUG_ASSERTIONS = "1"
                    }
                }
            ]

      let -- FIXME(#59637)
          no_assertions =
            toMap
              { NO_DEBUG_ASSERTIONS = let comment = "FIXME(#59637)" in "1"
              , NO_LLVM_ASSERTIONS = "1"
              }

      let windows =
            [   Windows_XL
              ⫽ { name = "x86_64-msvc-1"
                , env =
                      no_assertions
                    # toMap
                        { SCRIPT = "make ci-subset-1"
                        , RUST_CONFIGURE_ARGS =
                            "--build=x86_64-pc-windows-msvc --enable-profiler"
                        }
                }
            ,   Windows_XL
              ⫽ { name = "x86_64-msvc-2"
                , env = toMap
                    { SCRIPT = "make ci-subset-2"
                    , RUST_CONFIGURE_ARGS =
                        "--build=x86_64-pc-windows-msvc --enable-profiler"
                    }
                }
            ,   Windows_XL
              ⫽ { name = "i686-msvc-1"
                , env =
                      no_assertions
                    # toMap
                        { SCRIPT = "make ci-subset-1"
                        , RUST_CONFIGURE_ARGS = "--build=i686-pc-windows-msvc"
                        }
                }
            ,   Windows_XL
              ⫽ { name = "i686-msvc-2"
                , env =
                      no_assertions
                    # toMap
                        { SCRIPT = "make ci-subset-2"
                        , RUST_CONFIGURE_ARGS = "--build=i686-pc-windows-msvc"
                        }
                }
            ,   Windows_XL
              ⫽ { name = "x86_64-msvc-aux"
                , env = toMap
                    { RUST_CHECK_TARGET = "check-aux EXCLUDE_CARGO=1"
                    , RUST_CONFIGURE_ARGS = "--build=x86_64-pc-windows-msvc"
                    }
                }
            ,   Windows_XL
              ⫽ { name = "x86_64-msvc-cargo"
                , env =
                      no_assertions
                    # toMap
                        { SCRIPT =
                            "python x.py test src/tools/cargotest src/tools/cargo"
                        , RUST_CONFIGURE_ARGS = "--build=x86_64-pc-windows-msvc"
                        , VCVARS_BAT = "vcvars64.bat"
                        }
                }
            ,   Windows_XL
              ⫽ { name = "x86_64-msvc-tools"
                , env = toMap
                    { SCRIPT =
                        "src/ci/docker/x86_64-gnu-tools/checktools.sh x.py /tmp/toolstate/toolstates.json windows"
                    , RUST_CONFIGURE_ARGS =
                        "--build=x86_64-pc-windows-msvc --save-toolstates=/tmp/toolstate/toolstates.json"
                    }
                }
            ]

      let mingw
                -- 32/64-bit MinGW builds.
                --
                -- We are using MinGW with posix threads since LLVM does not compile with
                -- the win32 threads version due to missing support for C++'s std::thread.
                --
                -- Instead of relying on the MinGW version installed on appveryor we download
                -- and install one ourselves so we won't be surprised by changes to appveyor's
                -- build image.
                --
                -- Finally, note that the downloads below are all in the `rust-lang-ci` S3
                -- bucket, but they cleraly didn't originate there! The downloads originally
                -- came from the mingw-w64 SourceForge download site. Unfortunately
                -- SourceForge is notoriously flaky, so we mirror it on our own infrastructure.
                =
            [   Windows_XL
              ⫽ { name = "i686-mingw-1"
                , env =
                      no_assertions
                    # toMap
                        { CUSTOM_MINGW = "1"
                        , RUST_CONFIGURE_ARGS = "--build=i686-pc-windows-gnu"
                        , SCRIPT = "make ci-mingw-subset-1"
                        }
                }
            ,   Windows_XL
              ⫽ { name = "i686-mingw-2"
                , env = toMap
                    { CUSTOM_MINGW = "1"
                    , RUST_CONFIGURE_ARGS = "--build=i686-pc-windows-gnu"
                    , SCRIPT = "make ci-mingw-subset-2"
                    }
                }
            ,   Windows_XL
              ⫽ { name = "x86_64-mingw-1"
                , env =
                      no_assertions
                    # toMap
                        { CUSTOM_MINGW = "1"
                        , RUST_CONFIGURE_ARGS = "--build=x86_64-pc-windows-gnu"
                        , SCRIPT = "make ci-mingw-subset-1"
                        }
                }
            ,   Windows_XL
              ⫽ { name = "x86_64-mingw-2"
                , env = toMap
                    { CUSTOM_MINGW = "1"
                    , RUST_CONFIGURE_ARGS = "--build=x86_64-pc-windows-gnu"
                    , SCRIPT = "make ci-mingw-subset-2"
                    }
                }
            ,   Windows_XL
              ⫽ { name = "dist-x86_64-msvc"
                , env = toMap
                    { DIST_REQUIRE_ALL_TOOLS = "1"
                    , RUST_CONFIGURE_ARGS =
                        "--build=x86_64-pc-windows-msvc --target=x86_64-pc-windows-msvc,aarch64-pc-windows-msvc --enable-full-tools --enable-profiler"
                    , SCRIPT = "python x.py dist"
                    }
                }
            ,   Windows_XL
              ⫽ { name = "dist-i686-msvc"
                , env = toMap
                    { DIST_REQUIRE_ALL_TOOLS = "1"
                    , RUST_CONFIGURE_ARGS =
                        "--build=i686-pc-windows-msvc --target=i586-pc-windows-msvc --enable-full-tools --enable-profiler"
                    , SCRIPT = "python x.py dist"
                    }
                }
            ,   Windows_XL
              ⫽ { name = "dist-i686-mingw"
                , env = toMap
                    { CUSTOM_MINGW = "1"
                    , DIST_REQUIRE_ALL_TOOLS = "1"
                    , RUST_CONFIGURE_ARGS =
                        "--build=i686-pc-windows-gnu --enable-full-tools --enable-profiler"
                    , SCRIPT = "python x.py dist"
                    }
                }
            ,   Windows_XL
              ⫽ { name = "dist-x86_64-mingw"
                , env = toMap
                    { CUSTOM_MINGW = "1"
                    , DIST_REQUIRE_ALL_TOOLS = "1"
                    , RUST_CONFIGURE_ARGS =
                        "--build=x86_64-pc-windows-gnu --enable-full-tools --enable-profiler"
                    , SCRIPT = "python x.py dist"
                    }
                }
            ,   Windows_XL
              ⫽ { name = "dist-x86_64-msvc-alt"
                , env = toMap
                    { RUST_CONFIGURE_ARGS =
                        "--build=x86_64-pc-windows-msvc --enable-extended --enable-profiler"
                    , SCRIPT = "python x.py dist"
                    }
                }
            ]

      in  linux_and_docker # macos # windows # mingw

let jobs =
      { auto =
        { env =
            json.object
              ( toMap
                  { ARTIFACTS_AWS_ACCESS_KEY_ID =
                      json.string "AKIA46X5W6CZH5AYXDVF"
                  , CACHES_AWS_ACCESS_KEY_ID =
                      json.string "AKIA46X5W6CZOMUQATD5"
                  , CI_JOB_NAME = json.string "\${{ matrix.name }}"
                  , DEPLOY_BUCKET = json.string "rust-lang-gha"
                  , SCCACHE_BUCKET = json.string "rust-lang-gha-caches"
                  , TOOLSTATE_ISSUES_API_URL =
                      json.string
                        "https://api.github.com/repos/pietroalbini/rust-toolstate/issues"
                  , TOOLSTATE_PUBLISH = json.integer +1
                  , TOOLSTATE_REPO =
                      json.string
                        "https://github.com/pietroalbini/rust-toolstate"
                  }
              )
        , if =
            json.string
              "github.event_name == 'push' && github.ref == 'refs/heads/auto' && github.repository == 'rust-lang-ci/rust'"
        , name = json.string "auto"
        , runs-on = json.string "\${{ matrix.os }}"
        , steps =
            json.array
              [ json.object
                  ( toMap
                      { name = json.string "disable git crlf conversion"
                      , run =
                          json.string "git config --global core.autocrlf false"
                      , shell = json.string "bash"
                      }
                  )
              , json.object
                  ( toMap
                      { name = json.string "checkout the source code"
                      , uses = json.string "actions/checkout@v1"
                      , with =
                          json.object (toMap { fetch-depth = json.integer +2 })
                      }
                  )
              , json.object
                  ( toMap
                      { if =
                          json.string
                            "success() && !env.SKIP_JOB && github.ref != 'refs/heads/try'"
                      , name =
                          json.string
                            "configure GitHub Actions to kill the build when outdated"
                      , uses =
                          json.string
                            "rust-lang/simpleinfra/github-actions/cancel-outdated-builds@master"
                      , with =
                          json.object
                            ( toMap
                                { github_token =
                                    json.string "\${{ secrets.github_token }}"
                                }
                            )
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { EXTRA_VARIABLES =
                                    json.string "\${{ toJson(matrix.env) }}"
                                }
                            )
                      , if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "add extra environment variables"
                      , run = json.string "src/ci/scripts/setup-environment.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "decide whether to skip this job"
                      , run = json.string "src/ci/scripts/should-skip-this.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "collect CPU statistics"
                      , run = json.string "src/ci/scripts/collect-cpu-stats.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "show the current environment"
                      , run = json.string "src/ci/scripts/dump-environment.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install awscli"
                      , run = json.string "src/ci/scripts/install-awscli.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install sccache"
                      , run = json.string "src/ci/scripts/install-sccache.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install clang"
                      , run = json.string "src/ci/scripts/install-clang.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install WIX"
                      , run = json.string "src/ci/scripts/install-wix.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install InnoSetup"
                      , run = json.string "src/ci/scripts/install-innosetup.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name =
                          json.string
                            "ensure the build happens on a partition with enough space"
                      , run = json.string "src/ci/scripts/symlink-build-dir.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "disable git crlf conversion"
                      , run =
                          json.string
                            "src/ci/scripts/disable-git-crlf-conversion.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MSYS2"
                      , run = json.string "src/ci/scripts/install-msys2.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MSYS2 packages"
                      , run =
                          json.string "src/ci/scripts/install-msys2-packages.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MinGW"
                      , run = json.string "src/ci/scripts/install-mingw.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install ninja"
                      , run = json.string "src/ci/scripts/install-ninja.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "enable ipv6 on Docker"
                      , run = json.string "src/ci/scripts/enable-docker-ipv6.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "disable git crlf conversion"
                      , run =
                          json.string
                            "src/ci/scripts/disable-git-crlf-conversion.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "checkout submodules"
                      , run =
                          json.string "src/ci/scripts/checkout-submodules.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "ensure line endings are correct"
                      , run =
                          json.string "src/ci/scripts/verify-line-endings.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { AWS_ACCESS_KEY_ID =
                                    json.string
                                      "\${{ env.CACHES_AWS_ACCESS_KEY_ID }}"
                                , AWS_SECRET_ACCESS_KEY =
                                    json.string
                                      "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.CACHES_AWS_ACCESS_KEY_ID)] }}"
                                , TOOLSTATE_REPO_ACCESS_TOKEN =
                                    json.string
                                      "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                                }
                            )
                      , if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "run the build"
                      , run = json.string "src/ci/scripts/run-build-from-ci.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { AWS_ACCESS_KEY_ID =
                                    json.string
                                      "\${{ env.ARTIFACTS_AWS_ACCESS_KEY_ID }}"
                                , AWS_SECRET_ACCESS_KEY =
                                    json.string
                                      "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.ARTIFACTS_AWS_ACCESS_KEY_ID)] }}"
                                }
                            )
                      , if =
                          json.string
                            "success() && !env.SKIP_JOB && (github.event_name == 'push' || env.DEPLOY == '1' || env.DEPLOY_ALT == '1')"
                      , name = json.string "upload artifacts to S3"
                      , run = json.string "src/ci/scripts/upload-artifacts.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              ]
        , strategy = make_strategy auto_strategy
        , timeout-minutes = json.integer +600
        }
      , auto-failure =
        { if =
            json.string
              "!success() && github.event_name == 'push' && github.ref == 'refs/heads/auto' && github.repository == 'rust-lang-ci/rust'"
        , name = json.string "bors build finished"
        , needs = json.array [ json.string "auto" ]
        , runs-on = json.string "ubuntu-latest"
        , steps =
            json.array
              [ json.object
                  ( toMap
                      { name = json.string "mark the job as a failure"
                      , run = json.string "exit 1"
                      }
                  )
              ]
        }
      , auto-success =
        { if =
            json.string
              "success() && github.event_name == 'push' && github.ref == 'refs/heads/auto' && github.repository == 'rust-lang-ci/rust'"
        , name = json.string "bors build finished"
        , needs = json.array [ json.string "auto" ]
        , runs-on = json.string "ubuntu-latest"
        , steps =
            json.array
              [ json.object
                  ( toMap
                      { name = json.string "mark the job as a success"
                      , run = json.string "exit 0"
                      }
                  )
              ]
        }
      , master =
        { env =
            json.object
              ( toMap
                  { ARTIFACTS_AWS_ACCESS_KEY_ID =
                      json.string "AKIA46X5W6CZH5AYXDVF"
                  , CACHES_AWS_ACCESS_KEY_ID =
                      json.string "AKIA46X5W6CZOMUQATD5"
                  , DEPLOY_BUCKET = json.string "rust-lang-gha"
                  , SCCACHE_BUCKET = json.string "rust-lang-gha-caches"
                  , TOOLSTATE_ISSUES_API_URL =
                      json.string
                        "https://api.github.com/repos/pietroalbini/rust-toolstate/issues"
                  , TOOLSTATE_PUBLISH = json.integer +1
                  , TOOLSTATE_REPO =
                      json.string
                        "https://github.com/pietroalbini/rust-toolstate"
                  }
              )
        , if =
            json.string
              "github.event_name == 'push' && github.ref == 'refs/heads/master' && github.repository == 'rust-lang-ci/rust'"
        , name = json.string "master"
        , runs-on = json.string "ubuntu-latest"
        , steps =
            json.array
              [ json.object
                  ( toMap
                      { name = json.string "checkout the source code"
                      , uses = json.string "actions/checkout@v1"
                      , with =
                          json.object (toMap { fetch-depth = json.integer +2 })
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { TOOLSTATE_REPO_ACCESS_TOKEN =
                                    json.string
                                      "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                                }
                            )
                      , if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "publish toolstate"
                      , run = json.string "src/ci/publish_toolstate.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              ]
        }
      , pr =
        { env =
            json.object
              ( toMap
                  { CI_JOB_NAME = json.string "\${{ matrix.name }}"
                  , SCCACHE_BUCKET = json.string "rust-lang-gha-caches"
                  , TOOLSTATE_REPO =
                      json.string
                        "https://github.com/pietroalbini/rust-toolstate"
                  }
              )
        , if = json.string "github.event_name == 'pull_request'"
        , name = json.string "PR"
        , runs-on = json.string "\${{ matrix.os }}"
        , steps =
            json.array
              [ json.object
                  ( toMap
                      { name = json.string "disable git crlf conversion"
                      , run =
                          json.string "git config --global core.autocrlf false"
                      , shell = json.string "bash"
                      }
                  )
              , json.object
                  ( toMap
                      { name = json.string "checkout the source code"
                      , uses = json.string "actions/checkout@v1"
                      , with =
                          json.object (toMap { fetch-depth = json.integer +2 })
                      }
                  )
              , json.object
                  ( toMap
                      { if =
                          json.string
                            "success() && !env.SKIP_JOB && github.ref != 'refs/heads/try'"
                      , name =
                          json.string
                            "configure GitHub Actions to kill the build when outdated"
                      , uses =
                          json.string
                            "rust-lang/simpleinfra/github-actions/cancel-outdated-builds@master"
                      , with =
                          json.object
                            ( toMap
                                { github_token =
                                    json.string "\${{ secrets.github_token }}"
                                }
                            )
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { EXTRA_VARIABLES =
                                    json.string "\${{ toJson(matrix.env) }}"
                                }
                            )
                      , if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "add extra environment variables"
                      , run = json.string "src/ci/scripts/setup-environment.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "decide whether to skip this job"
                      , run = json.string "src/ci/scripts/should-skip-this.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "collect CPU statistics"
                      , run = json.string "src/ci/scripts/collect-cpu-stats.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "show the current environment"
                      , run = json.string "src/ci/scripts/dump-environment.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install awscli"
                      , run = json.string "src/ci/scripts/install-awscli.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install sccache"
                      , run = json.string "src/ci/scripts/install-sccache.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install clang"
                      , run = json.string "src/ci/scripts/install-clang.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install WIX"
                      , run = json.string "src/ci/scripts/install-wix.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install InnoSetup"
                      , run = json.string "src/ci/scripts/install-innosetup.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name =
                          json.string
                            "ensure the build happens on a partition with enough space"
                      , run = json.string "src/ci/scripts/symlink-build-dir.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "disable git crlf conversion"
                      , run =
                          json.string
                            "src/ci/scripts/disable-git-crlf-conversion.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MSYS2"
                      , run = json.string "src/ci/scripts/install-msys2.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MSYS2 packages"
                      , run =
                          json.string "src/ci/scripts/install-msys2-packages.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MinGW"
                      , run = json.string "src/ci/scripts/install-mingw.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install ninja"
                      , run = json.string "src/ci/scripts/install-ninja.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "enable ipv6 on Docker"
                      , run = json.string "src/ci/scripts/enable-docker-ipv6.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "disable git crlf conversion"
                      , run =
                          json.string
                            "src/ci/scripts/disable-git-crlf-conversion.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "checkout submodules"
                      , run =
                          json.string "src/ci/scripts/checkout-submodules.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "ensure line endings are correct"
                      , run =
                          json.string "src/ci/scripts/verify-line-endings.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { AWS_ACCESS_KEY_ID =
                                    json.string
                                      "\${{ env.CACHES_AWS_ACCESS_KEY_ID }}"
                                , AWS_SECRET_ACCESS_KEY =
                                    json.string
                                      "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.CACHES_AWS_ACCESS_KEY_ID)] }}"
                                , TOOLSTATE_REPO_ACCESS_TOKEN =
                                    json.string
                                      "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                                }
                            )
                      , if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "run the build"
                      , run = json.string "src/ci/scripts/run-build-from-ci.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { AWS_ACCESS_KEY_ID =
                                    json.string
                                      "\${{ env.ARTIFACTS_AWS_ACCESS_KEY_ID }}"
                                , AWS_SECRET_ACCESS_KEY =
                                    json.string
                                      "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.ARTIFACTS_AWS_ACCESS_KEY_ID)] }}"
                                }
                            )
                      , if =
                          json.string
                            "success() && !env.SKIP_JOB && (github.event_name == 'push' || env.DEPLOY == '1' || env.DEPLOY_ALT == '1')"
                      , name = json.string "upload artifacts to S3"
                      , run = json.string "src/ci/scripts/upload-artifacts.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              ]
        , strategy = make_strategy pr_strategy
        , timeout-minutes = json.integer +600
        }
      , try =
        { env =
            json.object
              ( toMap
                  { ARTIFACTS_AWS_ACCESS_KEY_ID =
                      json.string "AKIA46X5W6CZH5AYXDVF"
                  , CACHES_AWS_ACCESS_KEY_ID =
                      json.string "AKIA46X5W6CZOMUQATD5"
                  , CI_JOB_NAME = json.string "\${{ matrix.name }}"
                  , DEPLOY_BUCKET = json.string "rust-lang-gha"
                  , SCCACHE_BUCKET = json.string "rust-lang-gha-caches"
                  , TOOLSTATE_ISSUES_API_URL =
                      json.string
                        "https://api.github.com/repos/pietroalbini/rust-toolstate/issues"
                  , TOOLSTATE_PUBLISH = json.integer +1
                  , TOOLSTATE_REPO =
                      json.string
                        "https://github.com/pietroalbini/rust-toolstate"
                  }
              )
        , if =
            json.string
              "github.event_name == 'push' && github.ref == 'refs/heads/try' && github.repository == 'rust-lang-ci/rust'"
        , name = json.string "try"
        , runs-on = json.string "\${{ matrix.os }}"
        , steps =
            json.array
              [ json.object
                  ( toMap
                      { name = json.string "disable git crlf conversion"
                      , run =
                          json.string "git config --global core.autocrlf false"
                      , shell = json.string "bash"
                      }
                  )
              , json.object
                  ( toMap
                      { name = json.string "checkout the source code"
                      , uses = json.string "actions/checkout@v1"
                      , with =
                          json.object (toMap { fetch-depth = json.integer +2 })
                      }
                  )
              , json.object
                  ( toMap
                      { if =
                          json.string
                            "success() && !env.SKIP_JOB && github.ref != 'refs/heads/try'"
                      , name =
                          json.string
                            "configure GitHub Actions to kill the build when outdated"
                      , uses =
                          json.string
                            "rust-lang/simpleinfra/github-actions/cancel-outdated-builds@master"
                      , with =
                          json.object
                            ( toMap
                                { github_token =
                                    json.string "\${{ secrets.github_token }}"
                                }
                            )
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { EXTRA_VARIABLES =
                                    json.string "\${{ toJson(matrix.env) }}"
                                }
                            )
                      , if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "add extra environment variables"
                      , run = json.string "src/ci/scripts/setup-environment.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "decide whether to skip this job"
                      , run = json.string "src/ci/scripts/should-skip-this.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "collect CPU statistics"
                      , run = json.string "src/ci/scripts/collect-cpu-stats.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "show the current environment"
                      , run = json.string "src/ci/scripts/dump-environment.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install awscli"
                      , run = json.string "src/ci/scripts/install-awscli.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install sccache"
                      , run = json.string "src/ci/scripts/install-sccache.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install clang"
                      , run = json.string "src/ci/scripts/install-clang.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install WIX"
                      , run = json.string "src/ci/scripts/install-wix.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install InnoSetup"
                      , run = json.string "src/ci/scripts/install-innosetup.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name =
                          json.string
                            "ensure the build happens on a partition with enough space"
                      , run = json.string "src/ci/scripts/symlink-build-dir.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "disable git crlf conversion"
                      , run =
                          json.string
                            "src/ci/scripts/disable-git-crlf-conversion.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MSYS2"
                      , run = json.string "src/ci/scripts/install-msys2.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MSYS2 packages"
                      , run =
                          json.string "src/ci/scripts/install-msys2-packages.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install MinGW"
                      , run = json.string "src/ci/scripts/install-mingw.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "install ninja"
                      , run = json.string "src/ci/scripts/install-ninja.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "enable ipv6 on Docker"
                      , run = json.string "src/ci/scripts/enable-docker-ipv6.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "disable git crlf conversion"
                      , run =
                          json.string
                            "src/ci/scripts/disable-git-crlf-conversion.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "checkout submodules"
                      , run =
                          json.string "src/ci/scripts/checkout-submodules.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "ensure line endings are correct"
                      , run =
                          json.string "src/ci/scripts/verify-line-endings.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { AWS_ACCESS_KEY_ID =
                                    json.string
                                      "\${{ env.CACHES_AWS_ACCESS_KEY_ID }}"
                                , AWS_SECRET_ACCESS_KEY =
                                    json.string
                                      "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.CACHES_AWS_ACCESS_KEY_ID)] }}"
                                , TOOLSTATE_REPO_ACCESS_TOKEN =
                                    json.string
                                      "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                                }
                            )
                      , if = json.string "success() && !env.SKIP_JOB"
                      , name = json.string "run the build"
                      , run = json.string "src/ci/scripts/run-build-from-ci.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              , json.object
                  ( toMap
                      { env =
                          json.object
                            ( toMap
                                { AWS_ACCESS_KEY_ID =
                                    json.string
                                      "\${{ env.ARTIFACTS_AWS_ACCESS_KEY_ID }}"
                                , AWS_SECRET_ACCESS_KEY =
                                    json.string
                                      "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.ARTIFACTS_AWS_ACCESS_KEY_ID)] }}"
                                }
                            )
                      , if =
                          json.string
                            "success() && !env.SKIP_JOB && (github.event_name == 'push' || env.DEPLOY == '1' || env.DEPLOY_ALT == '1')"
                      , name = json.string "upload artifacts to S3"
                      , run = json.string "src/ci/scripts/upload-artifacts.sh"
                      , shell =
                          json.string "python src/ci/exec-with-shell.py {0}"
                      }
                  )
              ]
        , strategy = make_strategy try_strategy
        , timeout-minutes = json.integer +600
        }
      , try-failure =
        { if =
            json.string
              "!success() && github.event_name == 'push' && github.ref == 'refs/heads/try' && github.repository == 'rust-lang-ci/rust'"
        , name = json.string "bors build finished"
        , needs = json.array [ json.string "try" ]
        , runs-on = json.string "ubuntu-latest"
        , steps =
            json.array
              [ json.object
                  ( toMap
                      { name = json.string "mark the job as a failure"
                      , run = json.string "exit 1"
                      }
                  )
              ]
        }
      , try-success =
        { if =
            json.string
              "success() && github.event_name == 'push' && github.ref == 'refs/heads/try' && github.repository == 'rust-lang-ci/rust'"
        , name = json.string "bors build finished"
        , needs = json.array [ json.string "try" ]
        , runs-on = json.string "ubuntu-latest"
        , steps =
            json.array
              [ json.object
                  ( toMap
                      { name = json.string "mark the job as a success"
                      , run = json.string "exit 0"
                      }
                  )
              ]
        }
      }

in  { name = "CI"
    , on =
      { push.branches = [ "auto", "try", "master" ]
      , pull_request.branches = [ "**" ]
      }
    , jobs
    }
