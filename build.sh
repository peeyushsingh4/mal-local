#!/bin/bash
set -e

# Install Flutter SDK if not present in build environment
if [ ! -d "$HOME/flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
fi

export PATH="$PATH:$HOME/flutter/bin"

echo "Checking Flutter version..."
flutter --version

flutter config --enable-web
flutter pub get
flutter build web --release
