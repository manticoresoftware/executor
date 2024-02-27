# Manticore Executor

## What is it?

Manticore Executor is a custom built PHP binary which:

* includes everything needed for Manticore supplementary tools (e.g. [backup](https://github.com/manticoresoftware/manticoresearch-backup)) to run successfully
* doesn't include anything else which makes it very light and fast to install

## Supported OS

| OS | Architecture | Availability |
|-|-|-|
| Centos 7 | arm64, x86_64 | ✅ repo.manticoresearch.com |
| Centos 8 | arm64, x86_64 | ✅ repo.manticoresearch.com|
| Ubuntu Xenial | arm64, x86_64 | ✅ repo.manticoresearch.com|
| Ubuntu Bionic | arm64, x86_64 | ✅ repo.manticoresearch.com|
| Ubuntu Focal | arm64, x86_64 | ✅ repo.manticoresearch.com|
| Ubuntu Jammy | arm64, x86_64 | ✅ repo.manticoresearch.com|
| Debian Stretch | arm64, x86_64 | ✅ repo.manticoresearch.com|
| Debian Buster | arm64, x86_64 | ✅ repo.manticoresearch.com|
| Debian Bullseye | arm64, x86_64 | ✅ repo.manticoresearch.com|
| MacOS | x86_64 | ✅ repo.manticoresearch.com, homebrew custom tap|
| MacOS | arm64 | ✅ homebrew custom tap|
| Windows | x86_64 | ✅ repo.manticoresearch.com |

## Extensions supported by the executor

By default, we disable all extensions and enable only those required to run our scripts.

We build executor from `PHP 8.3.3` with the following extensions enabled and compiled into the executable statically:

* pcntl
* posix
* pcre (JIT)
* zstd
* parallel
* openssl
* zlib
* mbstring

## Build from source

The process of building the executor from source is simple and requires the same build tools needed to build PHP.

To find out the instructions on building, you can check [.github/workflow/release.yml](.github/workflows/release.yml) and related scripts with names like `build-%platform%.`

## Known issues

### Unverified developer on MacOS

When you try to run the executor on MacOS, you will probably get an error from the system that the binary you run has an unverified developer.

This is because OSX marks binaries downloaded from the Internet from an unknown developer (not signed) with a quarantine flag.

You should remove that quarantine flag and run the binary to fix this issue. Just open your terminal, navigate to the folder where you have downloaded binary and paste this line.

```sh
xattr -dr com.apple.quarantine manticore-executor
```

## Deployment

1. [The GitHub actions workflow](.github/workflows/release.yml) prepares packages/binaries for

   * Centos 7/8 x86_64 and arm64
   * Ubuntu Xenial/Bionic/Focal/Jammy x86_64 and arm64
   * Debian Stretch/Buster/Bullseye x86_64 and arm64
   * MacOS x86_64

2. The same workflow deploys the packages to [repositories](https://repo.manticoresearch.com)

3. What's to be done manually after the above is:

   * build binaries for MacOS arm64 following [this instruction](#how-to-build-manually)
   * update `root_url` in the [Homebrew formula](https://github.com/manticoresoftware/homebrew-manticore/blob/main/Formula/manticore-executor.rb) file with the latest release version
   * update `DEB_PKG` variables in the [Dockerfile](https://github.com/manticoresoftware/manticoresearch-backup/blob/main/Dockerfile) of [manticoresearch-backup](https://github.com/manticoresoftware/manticoresearch-backup) repository

## How to build manually

Several scripts used to build the final package:

* `build-linux`
* `build-osx`

The scripts accept a version of PHP as a parameter. The current version is `8.3.3`. To build the binary, you should run the following example:

```bash
./build-linux "8.3.3"
```

The command above will build the package on Linux with **PHP** `8.3.3`. Once it's done, you can find your binary in folder `dist/bin`.

### Build for MacOS arm64

Build and collect assets, after we can put the assets to the repo.

```bash
./build-osx "8.3.3"
git checkout 0.7.6
git tag v0.7.6
APP_ARCH=$(arch) APP_NAME=manticore-executor APP_VERSION=$(git describe --tags | cut -dv -f2) GITHUB_SHA=$(git rev-parse HEAD) RUNNER_OS=macos ./collect-assets
ls -lt *.tar.gz
```

### Prepare a package for Windows

1. Download pre-built thread-safe version of [PHP](https://windows.php.net/download/)
2. Download and add to php folder parallel lib from official [artifacts](https://github.com/krakjoe/parallel/actions/workflows/windows.yml)
3. Download and add to PHP folder [ZSTD lib](https://pecl.php.net/package/zstd/0.11.0/windows) from PECL binary builds
4. Rename `php.exe` -> `manticore-executor.exe`
5. Rename and edit `php.ini-production` -> `php.ini` and add `extension=...` with wanted extensions to load
6. Zip the final archive and upload to https://repo.manticoresearch.com/repository/manticoresearch_windows/dev/x64/
