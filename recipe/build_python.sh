#!/bin/bash
set -ex

cmake -G "Ninja" -B build -S . \
      -D CMAKE_BUILD_TYPE="Release" \
      -D BUILD_SHARED_LIBS=ON \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D Python3_EXECUTABLE="$PYTHON" \
      -D PASTIX_ORDERING_SCOTCH:BOOL=ON \
      -D BUILD_PYTHON:BOOL=ON \
      -D BUILD_LIBS:BOOL=OFF

ninja -C build install
