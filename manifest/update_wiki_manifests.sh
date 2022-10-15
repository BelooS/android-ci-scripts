#!/bin/bash

BUILD_TYPE=$1

usage() {
  echo "Copy app manifest to wiki directory"
  echo "Usage:"
  echo "  update_wiki_manifests.sh {BUILD_TYPE}"
  echo "  Example: update_wiki_manifests.sh debug"
}

update_wiki_manifests() {
  echo "Updating $BUILD_TYPE manifests for all apps..."
  manifest_dir="$MANIFESTS_WORKSPACE_DIR/$BUILD_TYPE"
  for dir in "$manifest_dir"/*; do
    basename=$(basename "$dir")
    mkdir -p "$WIKI_DIR/manifests/$BUILD_TYPE/$basename"
    cp "$dir/AndroidManifest-sorted.xml" "$WIKI_DIR/manifests/$BUILD_TYPE/$basename/."
  done
}

usage
update_wiki_manifests