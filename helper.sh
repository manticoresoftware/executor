#!/usr/bin/env bash
set -ex

install_curl() {
	test -d curl-8.0.0 && rm -fr "$_"
	curl -sSL https://github.com/curl/curl/releases/download/curl-8_0_0/curl-8.0.0.tar.gz | tar -xzf -
	cd curl-8.0.0
	./configure --disable-shared --with-ssl --without-libidn2
	make -j8
	make install
	cd ..
	rm -fr curl-8.0.0
}

install_libzip() {
	test -d libzip-1.9.2 && rm -fr "$_"
	curl -sSL https://github.com/nih-at/libzip/releases/download/v1.9.2/libzip-1.9.2.tar.gz | tar -xzf -
	cd libzip-1.9.2 && mkdir -p build && cd build
	cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=OFF -DENABLE_LZMA=OFF -DENABLE_BZIP2=OFF ..
	make -j4 && make install
	cd ../..
	rm -fr libzip-1.9.2
}

install_zlib() {
	test -d zlib-1.3.1 && rm -fr "$_"
	curl -sSL https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz | tar -xzf -
	cd zlib-1.3.1
	export CFLAGS="-O3 -fPIC"
	./configure --prefix=/usr --static
	make -j4 && make install
	cd ..
	rm -fr zlib-1.3.1
}

install_rdkafka() {
	test -d librdkafka-2.3.0 && rm -fr "$_"
	curl -sSL https://github.com/confluentinc/librdkafka/archive/refs/tags/v2.3.0.tar.gz | tar -xzf -
	cd librdkafka-2.3.0
	./configure --prefix=/usr --enable-static --disable-shared \
		--disable-debug-symbols --enable-strip \
		--disable-sasl --enable-lz4 --enable-zstd \
		--enable-zlib --enable-curl \
		--disable-regex-ext
	make -j4 && make install
	cd ..
	rm -fr librdkafka-2.3.0
}

install_libxml2() {
  test -d libxml2-2.10.3 && rm -fr libxml2-2.10.3
  curl -sSL https://github.com/GNOME/libxml2/archive/refs/tags/v2.10.3.tar.gz | tar -xzf -
  cd libxml2-2.10.3 && mkdir -p build && cd build
  cmake -DBUILD_SHARED_LIBS=OFF -DLIBXML2_WITH_LZMA=OFF -DLIBXML2_WITH_PYTHON=OFF -DLIBXML2_WITH_ICONV=OFF -DCMAKE_BUILD_TYPE=Release ..
  make -j4 && make install
  cd ../..
  rm -fr libxml2-2.10.3
}

build_dev_conf() {
	cd ext

	git clone https://github.com/donhardman/php-memory-profiler.git memprof && cd "$_"
	git checkout 68eb143bd5700a6fe041826118aeb9a13a3fcef3
	cd ..

	git clone https://github.com/tideways/php-xhprof-extension.git tideways_xhprof && cd "$_"
	git checkout 6ee298f910a3661960f454bd6a787686657c7570
	cd ..

	# Still not working due to zend
	# git clone https://github.com/donhardman/xdebug.git xdebug && cd "$_"
	# git checkout xdebug_3_2
	# cd ..

	cd ..

	# We need to rebuild because we modify extensions in PHP core code
	./buildconf --force
}

fix_static_linking() {
	sed -ie 's/PHP_INI_ENTRY("openssl.cafile", NULL, PHP_INI_PERDIR, NULL)/PHP_INI_ENTRY("openssl.cafile", "\/etc\/ssl\/cert.pem", PHP_INI_PERDIR, NULL)/g' ext/openssl/openssl.c
	sed -ie 's/-export-dynamic//g' Makefile
	sed -ie 's/-o $(SAPI_CLI_PATH)/-all-static -o $(SAPI_CLI_PATH)/g' Makefile
}