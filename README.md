# Manticore Executor

## What is it?

Manticore Executor is a custom built PHP with related

## Supported OS

| OS | Architecture | Repository |
|-|-|-|
| Centos 7 | arm, amd | ✅ |
| Centos 8 | arm, amd | ✅ |
| Ubuntu Xenial | arm, amd | ✅ |
| Ubuntu Bionic | arm, amd | ✅ |
| Ubuntu Focal | arm, amd | ✅ |
| Ubuntu Jammy | arm, amd | ✅ |
| Debian Stretch | arm, amd | ✅ |
| Debian Buster | arm, amd | ✅ |
| Debian Bullseye | arm, amd | ✅ |
| MacOS | amd | ✅ |
| Windows | - | ⛔️ |

## Extensions supported by executor

By default, we disable all extensions and enable only those required to run our scripts.

We build executor from `PHP 8.1.10` with the following extensions enabled and compiled extra with static linking to executable:

- pcntl
- posix
- pcre (JIT)
- lz4

## Build from source

The process is simple and requires the same build tools needed to build PHP.

To find out the instructions on building, you can check `.github/workflow/release.yml` and related scripts with names like `build-%platform%.`

## Known issues

### Unverified developer on MacOS

When you try to run executor on MacOS, you will probably get an error from the system that the binary you run has an unverified developer.

This is because OSX marks downloaded binaries from the internet with an unknown developer (not signed) with a quarantine flag.

You should remove that quarantine flag and run the binary to fix this issue. Just open your terminal, navigate to the folder where you have downloaded binary and paste this line.

```sh
xattr -dr com.apple.quarantine manticore-executor
```

### Windows support

We do not support Windows for now but work in progress. You can install PHP 8.1.10+ and enable requested extensions that are supported on Windows.
