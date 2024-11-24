#!/usr/bin/env bash
# Copyright (c) 2022, Manticore Software LTD (https://manticoresearch.com)

# This program is free software; you can redistribute it and/or modify
# it under the terms of the The PHP License, version 3.01. You should have
# received a copy of the license along with this program; if you did not,
# you can find it at https://www.php.net/license/3_01.txt
set -e

PHP_VERSION="$1"
ZSTD_REV="2dfcd6524ccdcef6dfdaa97d7f3716b866885093"
DS_REV="d42750d69beb684ec3ef7b3da48fba769ce57ffc"
SWOOLE_REV="2dcfef90b3dbcfc08783747ea9abf6ebaf7eedb8"
RDKAFKA_REV="bcd5004f461d1d3a5f879bb21280bdde6f6800c2"
JCHASH_REV="8ed50cc8c211effe1c214eae1e3240622e0f11b0"
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
    "--with-mysqli"
    "--enable-mysqlnd"
    # "--enable-xdebug"
  )
fi

# Build main php
mkdir dist
./buildconf --force
BUILD_PREFIX="$(pwd)/dist"

export BUILD_EXTRA BUILD_PREFIX BUILD_STATIC
