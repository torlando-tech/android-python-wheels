# Android Python Wheels

Pre-built Python wheels with native extensions for Android/Chaquopy.

## Available Packages

| Package | Version | Description |
|---------|---------|-------------|
| pycodec2 | 3.0.1 | Python bindings for Codec2 low-bitrate speech codec |

## Usage

### In Chaquopy (build.gradle)

```groovy
python {
    pip {
        install "pycodec2 @ https://github.com/torlando-tech/android-python-wheels/releases/download/v1.0.0/pycodec2-3.0.1-cp311-cp311-android_arm64_v8a.whl"
    }
}
```

### In requirements.txt

```
pycodec2 @ https://github.com/torlando-tech/android-python-wheels/releases/download/v1.0.0/pycodec2-3.0.1-cp311-cp311-android_arm64_v8a.whl ; platform_machine == 'aarch64'
pycodec2 @ https://github.com/torlando-tech/android-python-wheels/releases/download/v1.0.0/pycodec2-3.0.1-cp311-cp311-android_x86_64.whl ; platform_machine == 'x86_64'
```

## Supported ABIs

- `arm64-v8a` - 64-bit ARM (most modern Android devices)
- `x86_64` - 64-bit x86 (emulators on Intel/AMD)

## Building Locally

### Prerequisites

- Docker
- Git

### Build Steps

```bash
# Clone this repo
git clone https://github.com/torlando-tech/android-python-wheels.git
cd android-python-wheels

# Clone Chaquopy
git clone --depth 1 https://github.com/chaquo/chaquopy.git

# Build Docker images
cd chaquopy
docker build -t chaquopy-base -f base.dockerfile .
docker build -t chaquopy-target target
docker build -t build-wheel server/pypi
cd ..

# Download sources
wget https://github.com/drowe67/codec2/archive/refs/tags/v1.2.0.tar.gz
tar xzf v1.2.0.tar.gz && mv codec2-1.2.0 codec2-src

pip download --no-deps --no-binary :all: pycodec2==3.0.1
tar xzf pycodec2-3.0.1.tar.gz

# Copy recipe and sources
cp -r recipes/pycodec2 chaquopy/server/pypi/packages/
cp -r codec2-src pycodec2-3.0.1 chaquopy/server/pypi/

# Build for arm64-v8a
cd chaquopy/server/pypi
docker run --rm -v $(pwd):/src \
  -e ANDROID_ABI=arm64-v8a \
  -e CODEC2_VERSION=1.2.0 \
  -e PYCODEC2_VERSION=3.0.1 \
  build-wheel \
  python build-wheel.py --python 3.11 --abi arm64-v8a pycodec2
```

## Why This Exists

[Chaquopy](https://chaquo.com/chaquopy/) enables running Python in Android apps but cannot compile native extensions at build time. Packages like `pycodec2` that wrap C libraries need to be pre-built.

This repository provides GitHub Actions CI that:
1. Cross-compiles the Codec2 C library for Android
2. Builds pycodec2 Python bindings against it
3. Bundles everything into Android-compatible wheels
4. Publishes to GitHub Releases

## Related Projects

- [Codec2](https://github.com/drowe67/codec2) - Open source speech codec
- [pycodec2](https://github.com/gregorias/pycodec2) - Python bindings for Codec2
- [Chaquopy](https://chaquo.com/chaquopy/) - Python for Android
- [LXST](https://github.com/markqvist/LXST) - Voice calls over Reticulum (uses Codec2)

## License

Build scripts and recipes: MIT

The built wheels contain:
- Codec2: LGPL-2.1
- pycodec2: Apache-2.0
