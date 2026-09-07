#!/usr/bin/env bash
# Idempotent Cloud Agent install for this 1C:Enterprise (BSL) source repository.
#
# The proprietary 1C:Enterprise platform cannot run in a Linux Cloud Agent VM, so
# the development experience here is static analysis of the BSL sources with
# BSL Language Server (https://github.com/1c-syntax/bsl-language-server), the
# de-facto open-source linter/analyzer for 1C:Enterprise code.
#
# This script only downloads the analyzer once into a stable, out-of-tree
# location. It is safe to re-run.
set -euo pipefail

BSL_LS_VERSION="1.0.7"
BSL_LS_DIR="${HOME}/.local/share/bsl-language-server"
BSL_LS_JAR="${BSL_LS_DIR}/bsl-language-server-${BSL_LS_VERSION}-exec.jar"
BSL_LS_URL="https://github.com/1c-syntax/bsl-language-server/releases/download/v${BSL_LS_VERSION}/bsl-language-server-${BSL_LS_VERSION}-exec.jar"
BSL_LS_MIN_BYTES=100000000

mkdir -p "${BSL_LS_DIR}"

needs_download=1
if [[ -f "${BSL_LS_JAR}" ]]; then
  size=$(stat -c %s "${BSL_LS_JAR}" 2>/dev/null || echo 0)
  if [[ "${size}" -ge "${BSL_LS_MIN_BYTES}" ]]; then
    needs_download=0
  fi
fi

if [[ "${needs_download}" -eq 1 ]]; then
  echo "Downloading BSL Language Server ${BSL_LS_VERSION}..."
  tmp="${BSL_LS_JAR}.tmp"
  curl -fSL --retry 4 --retry-delay 4 -o "${tmp}" "${BSL_LS_URL}"
  mv -f "${tmp}" "${BSL_LS_JAR}"
else
  echo "BSL Language Server ${BSL_LS_VERSION} already present, skipping download."
fi

# Stable, version-independent symlink used by the analyze helper.
ln -sfn "${BSL_LS_JAR}" "${BSL_LS_DIR}/bsl-language-server.jar"

echo "Java: $(java -version 2>&1 | head -n 1)"
echo "BSL Language Server jar: ${BSL_LS_JAR} ($(stat -c %s "${BSL_LS_JAR}") bytes)"
echo "Install complete."
