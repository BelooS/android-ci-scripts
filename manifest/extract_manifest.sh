#!/bin/bash
set -eo pipefail
#extract_manifest.sh {TARGET_APP_NAME} {BUILD_TYPE}
#launch example: ./ci/extract_manifest.sh app debug

TARGET_APP_NAME=$1
BUILD_TYPE=$2

echo "extract manifest for $TARGET_APP_NAME"

SOURCE_FILE="$WORKSPACE/apps/$TARGET_APP_NAME/build/intermediates/merged_manifest/$BUILD_TYPE/AndroidManifest.xml"
SOURCE_LOG_FILE="$WORKSPACE/apps/$TARGET_APP_NAME/build/outputs/logs/manifest-merger-$BUILD_TYPE-report.txt"
MANIFEST_TARGET_DIR="$MANIFESTS_WORKSPACE_DIR/$BUILD_TYPE/$TARGET_APP_NAME"

mkdir -p "$MANIFEST_TARGET_DIR"
cp "$SOURCE_LOG_FILE" "$MANIFEST_TARGET_DIR" || echo "Failed to copy manifest log for $TARGET_APP_NAME"
cp "$SOURCE_FILE" "$MANIFEST_TARGET_DIR" || echo "Failed to copy manifest for $TARGET_APP_NAME"

export TARGET_MANIFEST_PATH=$SOURCE_FILE
export SORTED_MANIFEST_PATH="$MANIFEST_TARGET_DIR/AndroidManifest-sorted.xml"

function failedManifestSorting {
  echo "Failed to sort&copy manifest for $TARGET_APP_NAME"
  exit 1
}

#sort and store copy of manifest to $SORTED_MANIFEST_PATH
python3 ./sort_manifest.py || failedManifestSorting

