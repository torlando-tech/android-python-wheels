#!/bin/bash
set -ex

# This script builds libcodec2 for Android and then builds pycodec2 against it
#
# Environment variables expected:
#   ANDROID_NDK - Path to Android NDK
#   ANDROID_ABI - Target ABI (arm64-v8a, x86_64, etc.)
#   CODEC2_VERSION - Version of Codec2 to build (e.g., 1.2.0)

echo "=== Building Codec2 for Android ==="
echo "NDK: $ANDROID_NDK"
echo "ABI: $ANDROID_ABI"
echo "Codec2 version: ${CODEC2_VERSION:-1.2.0}"

# Set API level (23 = Android 6.0, minimum for complex.h math functions)
API_LEVEL=23

# Build libcodec2
cd /src/codec2-src
mkdir -p build-android
cd build-android

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=$ANDROID_ABI \
    -DANDROID_NATIVE_API_LEVEL=$API_LEVEL \
    -DANDROID_STL=c++_shared \
    -DBUILD_SHARED_LIBS=ON \
    -DUNITTEST=OFF \
    -DINSTALL_EXAMPLES=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/src/codec2-install

make -j$(nproc)
make install

echo "=== Codec2 build complete ==="
ls -la /src/codec2-install/lib/

# Set up environment for pycodec2 to find libcodec2
export CODEC2_DIR=/src/codec2-install
export CODEC2_INCLUDE_DIR=/src/codec2-install/include
export CODEC2_LIB_DIR=/src/codec2-install/lib
export LD_LIBRARY_PATH=/src/codec2-install/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/src/codec2-install/lib:$LIBRARY_PATH
export C_INCLUDE_PATH=/src/codec2-install/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/src/codec2-install/include:$CPLUS_INCLUDE_PATH

# Build pycodec2
echo "=== Building pycodec2 ==="
cd /src/pycodec2-${PYCODEC2_VERSION:-3.0.1}

# pycodec2 uses Cython and needs to find codec2.h and libcodec2.so
# The setup.py should pick these up from the environment variables

pip wheel . --no-deps --no-build-isolation -w /src/dist

echo "=== pycodec2 build complete ==="
ls -la /src/dist/

# Copy the libcodec2.so into the wheel (it needs to be bundled)
# This is a bit hacky but necessary for the wheel to be self-contained
cd /src/dist
for whl in *.whl; do
    echo "Patching $whl to include libcodec2.so..."
    unzip -q "$whl" -d wheel_contents

    # Find the pycodec2 package directory
    pkg_dir=$(find wheel_contents -name "pycodec2" -type d | head -1)
    if [ -n "$pkg_dir" ]; then
        # Copy libcodec2.so into the package
        cp /src/codec2-install/lib/libcodec2.so* "$pkg_dir/" 2>/dev/null || true

        # Repack the wheel
        cd wheel_contents
        zip -q -r "../$whl" .
        cd ..
    fi

    rm -rf wheel_contents
done

echo "=== Final wheels ==="
ls -la /src/dist/
