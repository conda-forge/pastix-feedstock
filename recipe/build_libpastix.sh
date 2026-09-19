#!/bin/bash
set -ex

# Detect SCOTCH integer size via header: works also when cross-compiling
# conda-forge scotch has int32/int64 variants (SCOTCH_Num = int vs int64_t)
PASTIX_INT64=OFF
if [ -f "$PREFIX/include/scotch.h" ]; then
  echo "scotch.h SCOTCH_Num line: $(grep -E "SCOTCH_Num|SCOTCH_VERSION" "$PREFIX/include/scotch.h" | head -10)"
  # Precise check: int64 variants use int64_t / long long / INT64
  if grep -Eq "typedef.*(int64_t|long long|INT64).*SCOTCH_Num" "$PREFIX/include/scotch.h" 2>/dev/null; then
    PASTIX_INT64=ON
  elif grep -Eq "typedef.*int.*SCOTCH_Num" "$PREFIX/include/scotch.h" 2>/dev/null; then
    PASTIX_INT64=OFF
  else
    echo "Could not parse SCOTCH_Num from header, trying compile test"
    if [ "$build_platform" = "$target_platform" ]; then
      cat > /tmp/check_scotch.c <<'EOF'
#include <scotch.h>
#include <stdio.h>
int main(){ printf("%zu\n", sizeof(SCOTCH_Num)); return 0; }
EOF
      if $CC /tmp/check_scotch.c -I$PREFIX/include -o /tmp/check_scotch 2>/dev/null && [ -x /tmp/check_scotch ]; then
        SZ=$(/tmp/check_scotch 2>/dev/null || echo 4)
        if [ "$SZ" = "8" ]; then PASTIX_INT64=ON; fi
      fi
    else
      echo "Cross-compiling ($build_platform -> $target_platform), skipping run-time check, keeping OFF"
    fi
  fi
fi
echo "Using PASTIX_INT64=$PASTIX_INT64 (detected from scotch.h)"

cmake -G "Ninja" -B build -S . \
      -D CMAKE_BUILD_TYPE="Release" \
      -D BUILD_SHARED_LIBS=ON \
      -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
      -D PASTIX_ORDERING_SCOTCH:BOOL=ON \
      -D BUILD_PYTHON:BOOL=OFF \
      -D BUILD_LIBS:BOOL=ON \
      -D PASTIX_INT64:BOOL=$PASTIX_INT64

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
