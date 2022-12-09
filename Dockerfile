FROM ubuntu:22.04
ARG BUILD_DEV=0
ARG REV=main

# Install the manticore-executor binary
RUN apt-get update -y && apt-get install -y sudo git && \
  git clone https://github.com/manticoresoftware/executor.git && \
  cd executor && git checkout $REV && \
  ./build-linux 8.1.13 0 $BUILD_DEV && \
  mv build/dist/bin/php /usr/bin/manticore-executor && \
  ln -s /usr/bin/manticore-executor /usr/bin/php && \
  cd .. && rm -fr executor

# Add composer
RUN test "$BUILD_DEV" -eq 1 && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
  php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
  php composer-setup.php && \
  php -r "unlink('composer-setup.php');" && \
  sudo mv composer.phar /usr/local/bin/composer

WORKDIR /src

# Build on silicon chip mac:
#  docker buildx build --build-arg BUILD_DEV=1 --build-arg REV=v0.4.1 --platform linux/amd64 -t manticoresearch/manticore-executor:0.4.1 --push .
