#!/bin/bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <INPUT_DIR3> <INPUT_DIR4> <OUTPUT_DIR6>"
  exit 1
fi

INPUT_DIR3=$1
INPUT_DIR4=$2
OUTPUT_DIR6=$3

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Idempotent output handling for repeated cluster runs.
hadoop fs -rm -r -f "$OUTPUT_DIR6" >/dev/null 2>&1 || true

HCATALOG_JAR=$(find /usr/lib/ -name "hive-hcatalog-core*.jar" 2>/dev/null | head -1)
if [ -z "$HCATALOG_JAR" ]; then
  echo "ERROR: hive-hcatalog-core JAR not found under /usr/lib/"
  exit 1
fi

beeline -u jdbc:hive2://localhost:10000/default -n bigdata_mikolaj -f "$SCRIPT_DIR/hive.hql" \
  -hiveconf hcatalog_jar="$HCATALOG_JAR" \
  -hiveconf input_dir3="$INPUT_DIR3" \
  -hiveconf input_dir4="$INPUT_DIR4" \
  -hiveconf output_dir6="$OUTPUT_DIR6"