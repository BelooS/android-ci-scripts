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
  cd "${MANIFESTS_WORKSPACE_DIR}/$BUILD_TYPE" || exit 2
  for dir in */; do
    echo "$dir"
    mkdir -p "$WIKI_DIR/manifests/$BUILD_TYPE/$dir"
    cp "$dir/AndroidManifest-sorted.xml" "$WIKI_DIR/manifests/$BUILD_TYPE/$dir/."
  done
  cd ..
}

usage
update_wiki_manifests