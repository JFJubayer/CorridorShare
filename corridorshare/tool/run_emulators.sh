#!/usr/bin/env bash
# Start the local Firebase emulator suite used by CorridorShare development.
#
# Requires the Firebase CLI (`npm i -g firebase-tools`) and Java 11+.

set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase CLI not found. Install with: npm i -g firebase-tools" >&2
  exit 1
fi

firebase emulators:start --project "${FB_PROJECT:-corridorshare-dev}"
