#!/usr/bin/env bash
# Copyright (c) 2022, Manticore Software LTD (https://manticoresearch.com)

# This program is free software; you can redistribute it and/or modify
# it under the terms of the The PHP License, version 3.01. You should have
# received a copy of the license along with this program; if you did not,
# you can find it at https://www.php.net/license/3_01.txt
set -e

PHP_VERSION="$1"
ZSTD_REV="2dfcd6524ccdcef6dfdaa97d7f3716b866885093"
PARALLEL_REV="25ba1ee594c350b0e3e239c6b995d772d0e4fc9c"
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


curl -sSL "https://github.com/php/php-src/archive/refs/tags/php-$PHP_VERSION.tar.gz" | tar -xzf -
test -d build && rm -fr "$_"
mv "php-src-php-$PHP_VERSION" build && cd "$_"

# Build extra extensions
cd ext

#  zstd
git clone --recursive --depth=1 https://github.com/manticoresoftware/php-ext-zstd.git
mv php-ext-zstd zstd
cd zstd && git checkout "$ZSTD_REV"
# cd zstd && make && cd ..
cd ..

# parallel
git clone https://github.com/manticoresoftware/krakjoe-parallel.git parallel
cd parallel && git checkout "$PARALLEL_REV"
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
    "--enable-filter"
    "--with-zip"
    # Little extra exts in case we will need it
    "--enable-bcmath"
    "--with-gmp"
    # Profiling extensions
    "--enable-memprof"
    "--enable-memprof-debug"
    "--enable-tideways-xhprof"
    # "--enable-xdebug"
  )
fi

# Build main php
mkdir dist
./buildconf --force
BUILD_PREFIX="$(pwd)/dist"

export BUILD_EXTRA BUILD_PREFIX BUILD_STATIC
