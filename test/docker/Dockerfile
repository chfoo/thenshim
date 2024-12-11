FROM ubuntu:24.04

RUN apt-get update && apt-get install --yes software-properties-common build-essential wget nodejs npm

# Install Haxe
RUN apt-add-repository --yes ppa:haxe/releases \
    && apt-get install --yes haxe

# Install HashLink dependencies
RUN apt-get install --yes libpng-dev libturbojpeg-dev libvorbis-dev libopenal-dev libsdl2-dev libglu1-mesa-dev libmbedtls-dev libuv1-dev libsqlite3-dev

# Build and install HashLink
RUN wget https://github.com/HaxeFoundation/hashlink/archive/refs/tags/1.14.tar.gz \
    && tar -xzf 1.14.tar.gz \
    && cd hashlink-1.14 \
    && make && make install && ldconfig

WORKDIR /home/ubuntu/thenshim
