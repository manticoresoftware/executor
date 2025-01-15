#!/usr/bin/env bash
# Copyright (c) 2022, Manticore Software LTD (https://manticoresearch.com)

# This program is free software; you can redistribute it and/or modify
# it under the terms of the The PHP License, version 3.01. You should have
# received a copy of the license along with this program; if you did not,
# you can find it at https://www.php.net/license/3_01.txt
set -e

PHP_VERSION="$1"
ZSTD_REV="2dfcd6524ccdcef6dfdaa97d7f3716b866885093"
DS_REV="da4d2f2a2c0f3732b34562636849c5e52e79e6c3"
SWOOLE_REV="3e1a1f89930ba0bbea1f5ee31bcd0ee701a87aab"
RDKAFKA_REV="53398031f1cd96e437e9705b67b4dc19d955acb6"
JCHASH_REV="8ed50cc8c211effe1c214eae1e3240622e0f11b0"
SIMDJSON_REV="9a2745669fea733a40f9443b1a793846d0759b89"
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

cd ..

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
    "--enable-tideways-xhprof"
    # "--enable-xdebug"
  )
fi

# Build main php
mkdir dist
./buildconf --force
BUILD_PREFIX="$(pwd)/dist"

export BUILD_EXTRA BUILD_PREFIX BUILD_STATIC
