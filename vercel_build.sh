#!/usr/bin/env bash
set -euo pipefail

# Flutter version known to avoid the Android-web keyboard gap regression.
FLUTTER_VERSION=${FLUTTER_VERSION:-3.37.0}

SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
SDK_DIR=/tmp/flutter-sdk
TARBALL=/tmp/flutter.tar.xz

mkdir -p "$SDK_DIR"

download_and_extract_tarball() {
	echo "Downloading Flutter ${FLUTTER_VERSION} from ${SDK_URL}"
	curl -fL --retry 4 --retry-delay 2 "$SDK_URL" -o "$TARBALL"
	# Some tar builds need -J for xz.
	tar -xJf "$TARBALL" -C "$SDK_DIR"
}

if ! download_and_extract_tarball; then
	echo "Tarball fetch/extract failed; falling back to git clone of tag ${FLUTTER_VERSION}" >&2
	rm -rf "$SDK_DIR"
	git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$SDK_DIR/flutter"
fi

export PATH="$SDK_DIR/flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
# HTML renderer tends to behave better on Android web for keyboard insets.
flutter build web --web-renderer html --release
