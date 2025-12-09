#!/usr/bin/env bash
set -euo pipefail

# Flutter version known to avoid the Android-web keyboard gap regression.
FLUTTER_VERSION=${FLUTTER_VERSION:-3.37.0}

# Download Flutter SDK (Linux build env on Vercel).
SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
echo "Downloading Flutter ${FLUTTER_VERSION} from ${SDK_URL}"
curl -L "$SDK_URL" -o /tmp/flutter.tar.xz
mkdir -p /tmp/flutter-sdk
tar -xf /tmp/flutter.tar.xz -C /tmp/flutter-sdk
export PATH="/tmp/flutter-sdk/flutter/bin:$PATH"

flutter config --enable-web
flutter pub get
# HTML renderer tends to behave better on Android web for keyboard insets.
flutter build web --web-renderer html --release
