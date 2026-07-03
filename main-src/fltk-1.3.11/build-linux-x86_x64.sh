#!/usr/bin/env bash
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash ./configure --enable-images --enable-forms
make -j"$(nproc)"
