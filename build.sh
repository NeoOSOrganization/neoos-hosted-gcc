#!/bin/bash
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
MCM_DIR="${MCM_DIR:-$HERE/mcm}"

if [ ! -d "$MCM_DIR" ]; then
    git clone https://github.com/richfelker/musl-cross-make "$MCM_DIR"
fi

cp "$HERE/config.mak" "$MCM_DIR/config.mak"
rm -rf "$MCM_DIR/patches/musl-1.2.5"
mkdir -p "$MCM_DIR/patches"
cp -r "$HERE/patches/musl-1.2.5" "$MCM_DIR/patches/musl-1.2.5"

cd "$MCM_DIR"
make -j"$(nproc)" 2>&1 | tee "$HERE/build.log"
make install 2>&1 | tee -a "$HERE/build.log"

if [ -x "/home/neo/opt/cross-x86_64-neoos/bin/x86_64-neoos-musl-gcc" ]; then
    echo ""
    echo "OK hosted toolchain built successfully at /home/neo/opt/cross-x86_64-neoos"
else
    echo "ERROR: build finished but x86_64-neoos-musl-gcc not found" >&2
    exit 1
fi
