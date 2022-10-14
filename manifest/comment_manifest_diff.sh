#!/bin/bash

BUILD_TYPE=$1
manifest_diff_file="/manifest.diff"

usage() {
  echo "Find a diff between baseline and a current manifest. Then post it to github"
  echo "Usage:"
  echo "  post_manifest_diff.sh {BUILD_TYPE}"
  echo "  Example: post_manifest_diff.sh release"
  echo "MANIFESTS_WORKSPACE_DIR, PULL_REQUEST_URL, PULL_REQUEST_ID, WIKI_DIR variables must be exported"
}

capture_diffs() {
  echo "Capturing $BUILD_TYPE merged manifest diffs..."
  cd "$MANIFESTS_WORKSPACE_DIR/$BUILD_TYPE" || exit 2
  {
  printf "## Manifest Diff:\n"
  for dir in */; do
      echo "### $dir"
      printf "\n\`\`\`diff\n"
      diff "$WIKI_DIR/manifests/$BUILD_TYPE/$dir/AndroidManifest-sorted.xml" "$dir/AndroidManifest-sorted.xml"
      printf "\n\`\`\`\n"
  done
  } >> $manifest_diff_file
  cd ..
}

post_comment() {
  echo "Commenting on PR: $PULL_REQUEST_URL"
  gh pr comment "$PULL_REQUEST_ID" -F "$manifest_diff_file" || {
    echo "Failed to comment to pr $PULL_REQUEST_URL"
    exit 1
  }
}

usage
./ci/github/remove_github_comment.sh "## Manifest Diff"
capture_diffs
post_comment

rm -f $manifest_diff_file