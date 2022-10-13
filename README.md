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
| Windows | - | ⛔️ work in progress|

## Extensions supported by the executor

By default, we disable all extensions and enable only those required to run our scripts.

We build executor from `PHP 8.1.10` with the following extensions enabled and compiled into the executable statically:

* pcntl
* posix
* pcre (JIT)
* lz4

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

### Windows support

We do not support Windows for now but this work is in progress. For now you can just install PHP 8.1.10+ and enable the requested extensions (see above).

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

The scripts accept a version of PHP as a parameter. The current version is `8.1.11`. To build the binary, you should run the following example:

```bash
./build-linux "8.1.11"
```

The command above will build the package on Linux with **PHP** `8.1.11`. Once it's done, you can find your binary in folder `dist/bin`.


### Build ARM64 for OSX

While GitHub actions do not have runners that support ARM64 architecture for OSX, we have the manual build of it

Once you updated the manticore-executor formula in [homebrew-manticore](https://github.com/manticoresoftware/homebrew-manticore) repository, you should build it following these instructions on your ARM64 OSX:

```bash
brew install --build-bottle manticoresoftware/manticore/manticore-executor
brew bottle manticoresoftware/manticore/manticore-executor
```

Once it's done just create a new pull request and update `manticore-executor.rb` file with the suggested line of sha256 sum for your bottle.

You should also upload just the newly built bottle to the releases page. Do not forget to rename the file and remove `.1` and change `--` to `-` to follow the same format as all other files that have already been uploaded to the release.
