let GitHubCI = ./GitHubCI.dhall

let MatrixEntry = GitHubCI.MatrixEntry

let Condition = GitHubCI.Condition

let Step = GitHubCI.Step

let Job = GitHubCI.Job

let CI = GitHubCI.CI

let shared_ci_variables = toMap { CI_JOB_NAME = "\${{ matrix.name }}" }

let public_variables =
      toMap
        { SCCACHE_BUCKET = "rust-lang-gha-caches"
        , TOOLSTATE_REPO = "https://github.com/pietroalbini/rust-toolstate"
        }

let
    -- AWS_SECRET_ACCESS_KEYs are stored in GitHub's secrets storage, named
    -- AWS_SECRET_ACCESS_KEY_<keyid>. Including the key id in the name allows to
    -- rotate them in a single branch while keeping the old key in another
    -- branch, which wouldn't be possible if the key was named with the kind
    -- (caches, artifacts...).
    prod_variables =
      toMap
        { SCCACHE_BUCKET = "rust-lang-gha-caches"
        , DEPLOY_BUCKET = "rust-lang-gha"
        , TOOLSTATE_REPO = "https://github.com/pietroalbini/rust-toolstate"
        , TOOLSTATE_ISSUES_API_URL =
            "https://api.github.com/repos/pietroalbini/rust-toolstate/issues"
        , TOOLSTATE_PUBLISH = "1"
        , CACHES_AWS_ACCESS_KEY_ID = "AKIA46X5W6CZOMUQATD5"
        , ARTIFACTS_AWS_ACCESS_KEY_ID = "AKIA46X5W6CZH5AYXDVF"
        }

let Linux_XL =
      { Type = MatrixEntry.Type
      , default = MatrixEntry.default ⫽ { os = "ubuntu-latest-xl" }
      }

let -- We don't have an XL builder for this
    MacOS_XL =
      { Type = MatrixEntry.Type
      , default = MatrixEntry.default ⫽ { os = "macos-latest" }
      }

let Windows_XL =
      { Type = MatrixEntry.Type
      , default = MatrixEntry.default ⫽ { os = "windows-latest-xl" }
      }

let StepBase =
      { Type = Step.Type
      , default = Step.default ⫽ { if = Some "success() && !env.SKIP_JOB" }
      }

let
    -- While on Linux and macOS builders it just forwards the arguments to the
    -- system bash, this wrapper allows switching from the host's bash.exe to
    -- the one we install along with MSYS2 mid-build on Windows.
    --
    -- Once the step to install MSYS2 is executed, the CI_OVERRIDE_SHELL
    -- environment variable is set pointing to our MSYS2's bash.exe. From that
    -- moment the host's bash.exe will not be called anymore.
    --
    -- This is needed because we can't launch our own bash.exe from the host
    -- bash.exe, as that would load two different cygwin1.dll in memory, causing
    -- "cygwin heap mismatch" errors.
    StepRun =
      { Type = StepBase.Type
      , default =
            StepBase.default
          ⫽ { shell = Some "python src/ci/exec-with-shell.py {0}" }
      }

let checkout_step =
      Step::{
      , name = "checkout the source code"
      , uses = Some "actions/checkout@v1"
      , with = toMap { fetch-depth = "2" }
      }

let base_ci_steps =
      [ Step::{
        , name = "disable git crlf conversion"
        , run = Some "git config --global core.autocrlf false"
        , shell = Some "bash"
        }
      , checkout_step
      , StepBase::{
        , name = "configure GitHub Actions to kill the build when outdated"
        , if = Some
            "success() && !env.SKIP_JOB && github.ref != 'refs/heads/try'"
        , uses = Some
            "rust-lang/simpleinfra/github-actions/cancel-outdated-builds@master"
        , with = toMap { github_token = "\${{ secrets.github_token }}" }
        }
      , StepRun::{
        , name = "add extra environment variables"
        , env =
            let
                -- Since it's not possible to merge `${{ matrix.env }}` with the other
                -- variables in `job.<name>.env`, the variables defined in the matrix
                -- are passed to the `setup-environment.sh` script encoded in JSON,
                -- which then uses log commands to actually set them.
                comment =
                  ""

            in  toMap { EXTRA_VARIABLES = "\${{ toJson(matrix.env) }}" }
        , run = Some "src/ci/scripts/setup-environment.sh"
        }
      , StepRun::{
        , name = "decide whether to skip this job"
        , run = Some "src/ci/scripts/should-skip-this.sh"
        }
      , StepRun::{
        , name = "collect CPU statistics"
        , run = Some "src/ci/scripts/collect-cpu-stats.sh"
        }
      , StepRun::{
        , name = "show the current environment"
        , run = Some "src/ci/scripts/dump-environment.sh"
        }
      , StepRun::{
        , name = "install awscli"
        , run = Some "src/ci/scripts/install-awscli.sh"
        }
      , StepRun::{
        , name = "install sccache"
        , run = Some "src/ci/scripts/install-sccache.sh"
        }
      , StepRun::{
        , name = "install clang"
        , run = Some "src/ci/scripts/install-clang.sh"
        }
      , StepRun::{
        , name = "install WIX"
        , run = Some "src/ci/scripts/install-wix.sh"
        }
      , StepRun::{
        , name = "install InnoSetup"
        , run = Some "src/ci/scripts/install-innosetup.sh"
        }
      , StepRun::{
        , name = "ensure the build happens on a partition with enough space"
        , run = Some "src/ci/scripts/symlink-build-dir.sh"
        }
      , StepRun::{
        , name = "disable git crlf conversion"
        , run =
            let
                -- Disable automatic line ending conversion (again). On Windows, when we're
                -- installing dependencies, something switches the git configuration directory or
                -- re-enables autocrlf. We've not tracked down the exact cause -- and there may
                -- be multiple -- but this should ensure submodules are checked out with the
                -- appropriate line endings.
                comment =
                  ""

            in  Some "src/ci/scripts/disable-git-crlf-conversion.sh"
        }
      , StepRun::{
        , name = "install MSYS2"
        , run = Some "src/ci/scripts/install-msys2.sh"
        }
      , StepRun::{
        , name = "install MSYS2 packages"
        , run = Some "src/ci/scripts/install-msys2-packages.sh"
        }
      , StepRun::{
        , name = "install MinGW"
        , run = Some "src/ci/scripts/install-mingw.sh"
        }
      , StepRun::{
        , name = "install ninja"
        , run = Some "src/ci/scripts/install-ninja.sh"
        }
      , StepRun::{
        , name = "enable ipv6 on Docker"
        , run = Some "src/ci/scripts/enable-docker-ipv6.sh"
        }
      , StepRun::{
        , name = "disable git crlf conversion"
        , run = Some "src/ci/scripts/disable-git-crlf-conversion.sh"
        }
      , StepRun::{
        , name = "checkout submodules"
        , run = Some "src/ci/scripts/checkout-submodules.sh"
        }
      , StepRun::{
        , name = "ensure line endings are correct"
        , run = Some "src/ci/scripts/verify-line-endings.sh"
        }
      , StepRun::{
        , name = "run the build"
        , run = Some "src/ci/scripts/run-build-from-ci.sh"
        , env = toMap
            { TOOLSTATE_REPO_ACCESS_TOKEN =
                "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
            , AWS_ACCESS_KEY_ID = "\${{ env.CACHES_AWS_ACCESS_KEY_ID }}"
            , AWS_SECRET_ACCESS_KEY =
                "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.CACHES_AWS_ACCESS_KEY_ID)] }}"
            }
        }
      , StepRun::{
        , name = "upload artifacts to S3"
        , env = toMap
            { AWS_ACCESS_KEY_ID = "\${{ env.ARTIFACTS_AWS_ACCESS_KEY_ID }}"
            , AWS_SECRET_ACCESS_KEY =
                "\${{ secrets[format('AWS_SECRET_ACCESS_KEY_{0}', env.ARTIFACTS_AWS_ACCESS_KEY_ID)] }}"
            }
        , if =
            let

                -- Adding a condition on DEPLOY=1 or DEPLOY_ALT=1 is not needed as all deploy
                -- builders *should* have the AWS credentials available. Still, explicitly
                -- adding the condition is helpful as this way CI will not silently skip
                -- deploying artifacts from a dist builder if the variables are misconfigured,
                -- erroring about invalid credentials instead.
                comment =
                  ""

            in  Some
                  "success() && !env.SKIP_JOB && (github.event_name == 'push' || env.DEPLOY == '1' || env.DEPLOY_ALT == '1')"
        , run = Some "src/ci/scripts/upload-artifacts.sh"
        }
      ]

let BaseCIJob =
      { Type = Job.Type
      , default =
            Job.default
          ⫽ { timeout-minutes = Some 600
            , runs-on = "\${{ matrix.os }}"
            , env = shared_ci_variables
            , steps = base_ci_steps
            }
      }

let
    -- These jobs don't actually test anything, but they're used to tell bors the
    -- build completed, as there is no practical way to detect when a workflow is
    -- successful listening to webhooks only.
    signal_bors =
        λ(name : Text)
      → λ(success : Bool)
      → Job::{
        , name = "bors build finished"
        , if =
          [ Condition.success success
          , Condition.event_name "push"
          , Condition.ref "refs/heads/${name}"
          , Condition.repository "rust-lang-ci/rust"
          ]
        , needs = [ name ]
        , runs-on = "ubuntu-latest"
        , steps =
          [ Step::{
            , name =
                "mark the job as a ${if success then "success" else "failure"}"
            , run = Some "exit ${if success then "0" else "1"}"
            }
          ]
        }

let basic_linux_xl = λ(name : Text) → Linux_XL::{ name }

let pr_strategy =
      [ basic_linux_xl "mingw-check"
      , basic_linux_xl "x86_64-gnu-llvm-7"
      , Linux_XL::{
        , name = "x86_64-gnu-tools"
        , env = toMap { CI_ONLY_WHEN_SUBMODULES_CHANGED = "1" }
        }
      ]

let try_strategy =
      [ basic_linux_xl "dist-x86_64-linux"
      , Linux_XL::{
        , name = "dist-x86_64-linux-alt"
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
            , Linux_XL::{
              , name = "dist-x86_64-linux-alt"
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
            , Linux_XL::{
              , name = "x86_64-gnu-llvm-7"
              , env = toMap { RUST_BACKTRACE = "1" }
              }
            , basic_linux_xl "x86_64-gnu-nopt"
            , Linux_XL::{
              , name = "x86_64-gnu-tools"
              , env = toMap { DEPLOY_TOOLSTATES_JSON = "toolstates-linux.json" }
              }
            ]

      let macos =
            [ MacOS_XL::{
              , name = "dist-x86_64-apple"
              , env = toMap
                  { SCRIPT = "./x.py dist"
                  , RUST_CONFIGURE_ARGS =
                      "--target=aarch64-apple-ios,x86_64-apple-ios --enable-full-tools --enable-sanitizers --enable-profiler --set rust.jemalloc"
                  , DIST_REQUIRE_ALL_TOOLS = "1"
                  , MACOSX_DEPLOYMENT_TARGET = "10.7"
                  , RUSTC_RETRY_LINKER_ON_SEGFAULT = "1"
                  , NO_LLVM_ASSERTIONS = "1"
                  , NO_DEBUG_ASSERTIONS = "1"
                  }
              }
            , MacOS_XL::{
              , name = "dist-x86_64-apple-alt"
              , env = toMap
                  { SCRIPT = "./x.py dist"
                  , RUST_CONFIGURE_ARGS =
                      "--enable-extended --enable-profiler --set rust.jemalloc"
                  , MACOSX_DEPLOYMENT_TARGET = "10.7"
                  , RUSTC_RETRY_LINKER_ON_SEGFAULT = "1"
                  , NO_LLVM_ASSERTIONS = "1"
                  , NO_DEBUG_ASSERTIONS = "1"
                  }
              }
            , MacOS_XL::{
              , name = "x86_64-apple"
              , env = toMap
                  { SCRIPT = "./x.py test"
                  , RUST_CONFIGURE_ARGS =
                      "--build=x86_64-apple-darwin --enable-sanitizers --enable-profiler --set rust.jemalloc"
                  , MACOSX_DEPLOYMENT_TARGET = "10.8"
                  , MACOSX_STD_DEPLOYMENT_TARGET = "10.7"
                  , RUSTC_RETRY_LINKER_ON_SEGFAULT = "1"
                  , NO_LLVM_ASSERTIONS = "1"
                  , NO_DEBUG_ASSERTIONS = "1"
                  }
              }
            ]

      let -- FIXME(#59637)
          fixme_no_assertions =
            toMap { NO_DEBUG_ASSERTIONS = "1", NO_LLVM_ASSERTIONS = "1" }

      let windows =
            [ Windows_XL::{
              , name = "x86_64-msvc-1"
              , env =
                    fixme_no_assertions
                  # toMap
                      { SCRIPT = "make ci-subset-1"
                      , RUST_CONFIGURE_ARGS =
                          "--build=x86_64-pc-windows-msvc --enable-profiler"
                      }
              }
            , Windows_XL::{
              , name = "x86_64-msvc-2"
              , env = toMap
                  { SCRIPT = "make ci-subset-2"
                  , RUST_CONFIGURE_ARGS =
                      "--build=x86_64-pc-windows-msvc --enable-profiler"
                  }
              }
            , Windows_XL::{
              , name = "i686-msvc-1"
              , env =
                    fixme_no_assertions
                  # toMap
                      { SCRIPT = "make ci-subset-1"
                      , RUST_CONFIGURE_ARGS = "--build=i686-pc-windows-msvc"
                      }
              }
            , Windows_XL::{
              , name = "i686-msvc-2"
              , env =
                    fixme_no_assertions
                  # toMap
                      { SCRIPT = "make ci-subset-2"
                      , RUST_CONFIGURE_ARGS = "--build=i686-pc-windows-msvc"
                      }
              }
            , Windows_XL::{
              , name = "x86_64-msvc-aux"
              , env = toMap
                  { RUST_CHECK_TARGET = "check-aux EXCLUDE_CARGO=1"
                  , RUST_CONFIGURE_ARGS = "--build=x86_64-pc-windows-msvc"
                  }
              }
            , Windows_XL::{
              , name = "x86_64-msvc-cargo"
              , env =
                    fixme_no_assertions
                  # toMap
                      { SCRIPT =
                          "python x.py test src/tools/cargotest src/tools/cargo"
                      , RUST_CONFIGURE_ARGS = "--build=x86_64-pc-windows-msvc"
                      , VCVARS_BAT = "vcvars64.bat"
                      }
              }
            , Windows_XL::{
              , name = "x86_64-msvc-tools"
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
            [ Windows_XL::{
              , name = "i686-mingw-1"
              , env =
                    fixme_no_assertions
                  # toMap
                      { CUSTOM_MINGW = "1"
                      , RUST_CONFIGURE_ARGS = "--build=i686-pc-windows-gnu"
                      , SCRIPT = "make ci-mingw-subset-1"
                      }
              }
            , Windows_XL::{
              , name = "i686-mingw-2"
              , env = toMap
                  { CUSTOM_MINGW = "1"
                  , RUST_CONFIGURE_ARGS = "--build=i686-pc-windows-gnu"
                  , SCRIPT = "make ci-mingw-subset-2"
                  }
              }
            , Windows_XL::{
              , name = "x86_64-mingw-1"
              , env =
                    fixme_no_assertions
                  # toMap
                      { CUSTOM_MINGW = "1"
                      , RUST_CONFIGURE_ARGS = "--build=x86_64-pc-windows-gnu"
                      , SCRIPT = "make ci-mingw-subset-1"
                      }
              }
            , Windows_XL::{
              , name = "x86_64-mingw-2"
              , env = toMap
                  { CUSTOM_MINGW = "1"
                  , RUST_CONFIGURE_ARGS = "--build=x86_64-pc-windows-gnu"
                  , SCRIPT = "make ci-mingw-subset-2"
                  }
              }
            , Windows_XL::{
              , name = "dist-x86_64-msvc"
              , env = toMap
                  { DIST_REQUIRE_ALL_TOOLS = "1"
                  , RUST_CONFIGURE_ARGS =
                      "--build=x86_64-pc-windows-msvc --target=x86_64-pc-windows-msvc,aarch64-pc-windows-msvc --enable-full-tools --enable-profiler"
                  , SCRIPT = "python x.py dist"
                  }
              }
            , Windows_XL::{
              , name = "dist-i686-msvc"
              , env = toMap
                  { DIST_REQUIRE_ALL_TOOLS = "1"
                  , RUST_CONFIGURE_ARGS =
                      "--build=i686-pc-windows-msvc --target=i586-pc-windows-msvc --enable-full-tools --enable-profiler"
                  , SCRIPT = "python x.py dist"
                  }
              }
            , Windows_XL::{
              , name = "dist-i686-mingw"
              , env = toMap
                  { CUSTOM_MINGW = "1"
                  , DIST_REQUIRE_ALL_TOOLS = "1"
                  , RUST_CONFIGURE_ARGS =
                      "--build=i686-pc-windows-gnu --enable-full-tools --enable-profiler"
                  , SCRIPT = "python x.py dist"
                  }
              }
            , Windows_XL::{
              , name = "dist-x86_64-mingw"
              , env = toMap
                  { CUSTOM_MINGW = "1"
                  , DIST_REQUIRE_ALL_TOOLS = "1"
                  , RUST_CONFIGURE_ARGS =
                      "--build=x86_64-pc-windows-gnu --enable-full-tools --enable-profiler"
                  , SCRIPT = "python x.py dist"
                  }
              }
            , Windows_XL::{
              , name = "dist-x86_64-msvc-alt"
              , env = toMap
                  { RUST_CONFIGURE_ARGS =
                      "--build=x86_64-pc-windows-msvc --enable-extended --enable-profiler"
                  , SCRIPT = "python x.py dist"
                  }
              }
            ]

      in  linux_and_docker # macos # windows # mingw

let jobs =
      toMap
        { pr = BaseCIJob::{
          , name = "PR"
          , if = [ Condition.event_name "pull_request" ]
          , env = BaseCIJob.default.env # public_variables
          , strategy = pr_strategy
          }
        , try = BaseCIJob::{
          , name = "try"
          , env = BaseCIJob.default.env # prod_variables
          , if =
            [ Condition.event_name "push"
            , Condition.ref "refs/heads/try"
            , Condition.repository "rust-lang-ci/rust"
            ]
          , strategy = try_strategy
          }
        , try-success = signal_bors "try" True
        , try-failure = signal_bors "try" False
        , auto = BaseCIJob::{
          , name = "auto"
          , if =
            [ Condition.event_name "push"
            , Condition.ref "refs/heads/auto"
            , Condition.repository "rust-lang-ci/rust"
            ]
          , env = BaseCIJob.default.env # prod_variables
          , strategy = auto_strategy
          }
        , auto-success = signal_bors "auto" True
        , auto-failure = signal_bors "auto" False
        , master = Job::{
          , name = "master"
          , if =
            [ Condition.event_name "push"
            , Condition.ref "refs/heads/master"
            , Condition.repository "rust-lang-ci/rust"
            ]
          , env = prod_variables
          , runs-on = "ubuntu-latest"
          , steps =
            [ checkout_step
            , StepRun::{
              , name = "publish toolstate"
              , run = Some "src/ci/publish_toolstate.sh"
              , env = toMap
                  { TOOLSTATE_REPO_ACCESS_TOKEN =
                      "\${{ secrets.TOOLSTATE_REPO_ACCESS_TOKEN }}"
                  }
              }
            ]
          }
        }

in  GitHubCI.make_ci
      CI::{
      , name = "CI"
      , on = toMap
          { push.branches = [ "auto", "try", "master" ]
          , pull_request.branches = [ "**" ]
          }
      , jobs
      }
