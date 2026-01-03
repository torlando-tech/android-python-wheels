# Android Python Wheels

Pre-built Python wheels with native extensions for Android/Chaquopy.

## Available Packages

| Package | Version | Python | Description |
|---------|---------|--------|-------------|
| pycodec2 | 3.0.1 | 3.13 | Python bindings for Codec2 low-bitrate speech codec |

## Usage

### In Chaquopy (build.gradle)

```groovy
python {
    pip {
        install "pycodec2 @ https://github.com/torlando-tech/android-python-wheels/releases/download/v1.0.0/pycodec2-3.0.1-cp313-cp313-android_arm64_v8a.whl"
    }
}
```

### In requirements.txt

```
pycodec2 @ https://github.com/torlando-tech/android-python-wheels/releases/download/v1.0.0/pycodec2-3.0.1-cp313-cp313-android_arm64_v8a.whl ; platform_machine == 'aarch64'
pycodec2 @ https://github.com/torlando-tech/android-python-wheels/releases/download/v1.0.0/pycodec2-3.0.1-cp313-cp313-android_x86_64.whl ; platform_machine == 'x86_64'
```

## Supported ABIs

- `arm64_v8a` - 64-bit ARM (most modern Android devices)
- `x86_64` - 64-bit x86 (emulators on Intel/AMD)

## How It Works

This repository uses [cibuildwheel](https://cibuildwheel.pypa.io/) with Android platform support to:

1. Cross-compile the Codec2 C library for each Android ABI using the Android NDK
2. Build pycodec2 Python extension against it
3. Bundle everything into Android-compatible wheels
4. Publish to GitHub Releases on tag push

## Building Locally

### Prerequisites

- Python 3.13+
- cibuildwheel
- Android NDK

### Build Steps

```bash
# Install cibuildwheel
pip install cibuildwheel

# Clone this repo
git clone https://github.com/torlando-tech/android-python-wheels.git
cd android-python-wheels

# Download sources
wget https://github.com/drowe67/codec2/archive/refs/tags/v1.2.0.tar.gz
tar xzf v1.2.0.tar.gz && mv codec2-1.2.0 codec2-src

pip download --no-deps --no-binary :all: pycodec2==3.0.1
tar xzf pycodec2-3.0.1.tar.gz
cd pycodec2-3.0.1

# Copy codec2 source
cp -r ../codec2-src .

# Build for Android
cibuildwheel --platform android --output-dir ../dist
```

## Why This Exists

[Chaquopy](https://chaquo.com/chaquopy/) enables running Python in Android apps but cannot compile native extensions at build time. Packages like `pycodec2` that wrap C libraries need to be pre-built.

This repository provides GitHub Actions CI that cross-compiles these packages for Android.

## Related Projects

- [Codec2](https://github.com/drowe67/codec2) - Open source speech codec
- [pycodec2](https://github.com/gregorias/pycodec2) - Python bindings for Codec2
- [Chaquopy](https://chaquo.com/chaquopy/) - Python for Android
- [LXST](https://github.com/markqvist/LXST) - Voice calls over Reticulum (uses Codec2)
- [cibuildwheel](https://cibuildwheel.pypa.io/) - Build Python wheels for all platforms

## License

Build scripts: MIT

The built wheels contain:
- Codec2: LGPL-2.1
- pycodec2: Apache-2.0
