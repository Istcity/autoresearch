#!/usr/bin/env bash
# Idempotent bootstrap for the Stillway repo on a Linux Cloud Agent.
#
# Stillway is a native iOS/SwiftUI app. Building and running the app itself
# requires macOS 14+ with Xcode 16+ and cannot happen on this Linux machine.
# What this script sets up is everything the repo CAN do on Linux:
#   - Python 3 tooling (station DB, localization, sounds, project generator)
#   - The Swift 6.1 toolchain, used for syntax-validating the app source
#     (swiftc -parse) since the Apple SDKs are unavailable here.
set -euo pipefail

SWIFT_VERSION="6.1"
SWIFT_TAG="swift-${SWIFT_VERSION}-RELEASE"
SWIFT_TARBALL="${SWIFT_TAG}-ubuntu24.04.tar.gz"
SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2404/${SWIFT_TAG}/${SWIFT_TARBALL}"
SWIFT_HOME="/opt/swift"

echo "==> Python toolchain"
python3 --version
# Every helper script in scripts/ is standard-library only, so there is
# nothing to pip install. Fail loudly if that assumption ever breaks.
python3 - <<'PY'
import csv, io, json, math, pathlib, re, struct, sys, zipfile, zlib  # noqa: F401
print("python stdlib modules for scripts/ available")
PY

echo "==> System packages for the Swift runtime"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  binutils \
  ffmpeg \
  gnupg2 \
  libc6-dev \
  libcurl4-openssl-dev \
  libedit2 \
  libgcc-13-dev \
  libncurses-dev \
  libpython3-dev \
  libstdc++-13-dev \
  libxml2-dev \
  libz3-dev \
  pkg-config \
  tzdata \
  zlib1g-dev

echo "==> Swift ${SWIFT_VERSION} toolchain"
if [ ! -x "${SWIFT_HOME}/usr/bin/swiftc" ]; then
  tmp="$(mktemp -d)"
  curl -fL --retry 4 -o "${tmp}/${SWIFT_TARBALL}" "${SWIFT_URL}"
  sudo mkdir -p "${SWIFT_HOME}"
  sudo tar xzf "${tmp}/${SWIFT_TARBALL}" -C "${SWIFT_HOME}" --strip-components=1
  rm -rf "${tmp}"
else
  echo "Swift already installed at ${SWIFT_HOME}"
fi

# Expose swift/swiftc on PATH for interactive shells and future boots.
sudo ln -sf "${SWIFT_HOME}/usr/bin/swift" /usr/local/bin/swift
sudo ln -sf "${SWIFT_HOME}/usr/bin/swiftc" /usr/local/bin/swiftc
swift --version

echo "==> Environment ready"
echo "    Python scripts:   python3 scripts/<name>.py"
echo "    Swift syntax check: scripts (see README) or swiftc -parse <file>.swift"
echo "    Full app build:    requires macOS + Xcode (not available on Linux)"
