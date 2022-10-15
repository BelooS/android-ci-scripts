#!/bin/bash

BUILD_TYPE=$1

usage() {
  echo "Find a diff between baseline and a current manifest. Then post it to github"
  echo "Usage:"
  echo "  post_manifest_diff.sh {BUILD_TYPE}"
  echo "  Example: post_manifest_diff.sh release"
  echo "MANIFESTS_WORKSPACE_DIR, PULL_REQUEST_URL, PULL_REQUEST_ID, WIKI_DIR variables must be exported"
}

capture_diffs() {
  echo "Capturing $BUILD_TYPE merged manifest diffs..."
  manifest_dir="$MANIFESTS_WORKSPACE_DIR/$BUILD_TYPE"
  printf "## Manifest Diff:\n" >> manifest.diff
  for dir in "$manifest_dir"/*; do
      basename=$(basename "$dir")
      echo "process dir $basename"
      {
        echo "### $basename"
        printf "\n\`\`\`diff\n"
        diff "$WIKI_DIR/manifests/$BUILD_TYPE/$basename/AndroidManifest-sorted.xml" "$dir/AndroidManifest-sorted.xml"
        printf "\n\`\`\`\n"
      } >> manifest.diff
  done

}

post_comment() {
  echo "Commenting on PR: $PULL_REQUEST_URL"
  gh pr comment "$PULL_REQUEST_ID" -F manifest.diff || {
    echo "Failed to comment to pr $PULL_REQUEST_URL"
    exit 1
  }
}

./ci/github/remove_github_comment.sh "## Manifest Diff"
capture_diffs
post_comment

rm -f manifest.diff