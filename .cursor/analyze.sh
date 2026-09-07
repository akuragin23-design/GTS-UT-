#!/usr/bin/env bash
# Run BSL Language Server static analysis over the 1C source tree and emit a
# JSON diagnostics report.
#
# Usage:
#   .cursor/analyze.sh [SRC_DIR] [OUTPUT_DIR]
#
# Defaults:
#   SRC_DIR    = repository root (.)   -> scans every .bsl module
#   OUTPUT_DIR = ./bsl-analysis
#
# Example (analyze only the extension):
#   .cursor/analyze.sh "РасширениеГТС/Джитиис" bsl-analysis
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${1:-${REPO_ROOT}}"
OUTPUT_DIR="${2:-${REPO_ROOT}/bsl-analysis}"

BSL_LS_JAR="${HOME}/.local/share/bsl-language-server/bsl-language-server.jar"
if [[ ! -f "${BSL_LS_JAR}" ]]; then
  echo "BSL Language Server jar not found at ${BSL_LS_JAR}. Run .cursor/install.sh first." >&2
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"

# Heap size for the JVM. Increase for large source trees (e.g. the full config).
BSL_LS_XMX="${BSL_LS_XMX:-4g}"

echo "Analyzing: ${SRC_DIR}"
echo "Report dir: ${OUTPUT_DIR}"
echo "JVM heap:  ${BSL_LS_XMX}"
java "-Xmx${BSL_LS_XMX}" -jar "${BSL_LS_JAR}" analyze \
  --srcDir "${SRC_DIR}" \
  --workspaceDir "${REPO_ROOT}" \
  --outputDir "${OUTPUT_DIR}" \
  --reporter json
