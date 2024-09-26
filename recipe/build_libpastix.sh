#!/bin/bash
set -ex

cmake -G "Ninja" -B build -S . \
      -D CMAKE_BUILD_TYPE="Release" \
      -D BUILD_SHARED_LIBS=ON \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D PASTIX_ORDERING_SCOTCH:BOOL=ON \
      -D BUILD_PYTHON:BOOL=OFF \
      -D BUILD_LIBS:BOOL=ON

ninja -C build install


# delete this file as it needs mpi
rm $PREFIX/share/doc/pastix/examples/fortran/fmultilap