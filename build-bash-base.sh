#!/usr/bin/env bash
# Copyright (c) 2022, Manticore Software LTD (https://manticoresearch.com)

# This program is free software; you can redistribute it and/or modify
# it under the terms of the The PHP License, version 3.01. You should have
# received a copy of the license along with this program; if you did not,
# you can find it at https://www.php.net/license/3_01.txt
set -e

PHP_VERSION="$1"
ZSTD_REV="d6d26eb805058fc672686715a7b5e39d8f65dd36"
DS_REV="118c06b8863386ceada4238f3cec18ab84c9efb7"
SWOOLE_REV="d611ff3ca60e8c9425b2e2e3ba1a9004faab64f5"
RDKAFKA_REV="2df0c74170d95d027e6773d3a9afb1fab5917558"
JCHASH_REV="8ed50cc8c211effe1c214eae1e3240622e0f11b0"
SIMDJSON_REV="9a2745669fea733a40f9443b1a793846d0759b89"
LLM_REV="8ef13fa0911de91fddebe0bde48ba7569a055482"
SKIP_SYSTEM_DEPS="$2"
BUILD_DEV="$3"
BUILD_STATIC=1 # Always build static but dev

if [[ -z "$PHP_VERSION" ]]; then
  echo >&2 "Usage: $0 php-version [skip-system-deps] [build-dev]"
  exit 1
fi

if [[ -z "$SKIP_SYSTEM_DEPS"  || "$SKIP_SYSTEM_DEPS" == 0 ]]; then
  install_deps

  if [[ "$BUILD_DEV" == "1" ]]; then
    install_dev_deps
  fi
fi


curl -sSL "https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz" | tar -xzf -
test -d build && rm -fr "$_"
mv "php-$PHP_VERSION" build && cd "$_"

# Build extra extensions
cd ext

#  zstd
git clone --recursive --depth=1 https://github.com/manticoresoftware/php-ext-zstd.git
mv php-ext-zstd zstd
cd zstd && git checkout "$ZSTD_REV"
# cd zstd && make && cd ..
cd ..

# ds
git clone https://github.com/php-ds/ext-ds.git ds
cd ds && git checkout "$DS_REV"
cd ..

# openswoole
git clone https://github.com/swoole/swoole-src.git swoole
cd swoole && git checkout "$SWOOLE_REV"
cd ..

# rdkafka
git clone https://github.com/arnaud-lb/php-rdkafka.git
mv php-rdkafka rdkafka
cd rdkafka && git checkout "$RDKAFKA_REV"
cd ..

git clone https://github.com/c9s/jchash.git
cd jchash && git checkout "$JCHASH_REV"
cd ..

git clone https://github.com/crazyxman/simdjson_php.git
mv simdjson_php simdjson
cd simdjson && git checkout "$SIMDJSON_REV"
# Clean up php version ncheck that fails when we build without phpize
if [ "$(uname)" == "Darwin" ]; then
	# macOS (OSX)
	sed -i '' '9,24d' config.m4
else
	# Linux
	sed -i '9,24d' config.m4
fi
cd ..

# llm
git clone https://github.com/manticoresoftware/llm-php-ext.git llm
cd llm && git checkout "$LLM_REV"
if [ "$(uname)" == "Darwin" ]; then
	# macOS: Use LLVM 17 from Homebrew
	LLVM_PREFIX="$(brew --prefix llvm@17 2>/dev/null || echo /opt/homebrew/opt/llvm@17)"
	LIBCLANG_PATH="$LLVM_PREFIX/lib"
	LLVM_CONFIG_PATH="$LLVM_PREFIX/bin/llvm-config"
	LLVM_PATH="$LLVM_PREFIX/bin"
	# Ensure PHP is still accessible by appending LLVM to PATH instead of prepending
	export LIBCLANG_PATH="$LIBCLANG_PATH" LLVM_CONFIG_PATH="$LLVM_CONFIG_PATH" PATH="$PATH:$LLVM_PATH"
	# Verify PHP is accessible
	echo "Verifying PHP is accessible for ext-php-rs build..."
	which php && php --version || echo "WARNING: php not found in PATH!"
fi
cd ../..

BUILD_EXTRA=()
if [[ "$BUILD_DEV" == "1" ]]; then
  BUILD_STATIC=0
  BUILD_EXTRA=(
    "--enable-dom"
    "--with-libxml"
    "--enable-tokenizer"
    "--enable-xml"
    "--enable-xmlwriter"
    "--enable-xmlreader"
    "--enable-simplexml"
    "--enable-phar"
    # Little extra exts in case we will need it
    "--enable-bcmath"
    "--enable-ctype"
    "--with-gmp"
    # Profiling extensions
    "--enable-debug"
    # "--enable-memprof"
    # "--enable-memprof-debug"
		#
		# It does not work with PHP 8.4.17
    # "--enable-tideways-xhprof"
    # "--enable-xdebug"
  )
fi

# Build main php
mkdir dist
./buildconf --force
BUILD_PREFIX="$(pwd)/dist"

export BUILD_EXTRA BUILD_PREFIX BUILD_STATIC
