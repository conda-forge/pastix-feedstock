#!/bin/bash
set -ex

cmake -G "Ninja" -B build -S . \
      -D CMAKE_BUILD_TYPE="Release" \
      -D BUILD_SHARED_LIBS=ON \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D PASTIX_ORDERING_SCOTCH:BOOL=ON \
      -D BUILD_PYTHON:BOOL=OFF \
      -D BUILD_LIBS:BOOL=ON \
      -D PASTIX_INT64:BOOL=OFF

ninja -C build install

if [ "$build_platform" == "$target_platform" ]; then
    echo "Running tests with ninja..."
    ninja -C build test --verbose
else
    echo "Skipping tests due to cross-compiling "
    echo "(build_platform: $build_platform, target_platform: $target_platform)"
fi




# delete this file as it needs mpi
rm $PREFIX/share/doc/pastix/examples/fortran/fmultilap
