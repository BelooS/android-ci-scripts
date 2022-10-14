#!/bin/bash

usage() {
  echo "This script removes all comments (issues) in github pull requests that matches template"
  echo "Usage:"
  echo "  remove_github_comment.sh <pullRequestId> <comment template>"
  echo "GITHUB_TOKEN, GITHUB_PROJECT_USERNAME, PULL_REQUEST_ID variables must be exported"
  echo "Example:"
  echo "  remove_github_comment.sh \"## Manifest Diff\""
}

COMMENT_TEMPLATE=$1

issues_api_url="https://api.github.com/repos/$GITHUB_PROJECT_USERNAME/$GITHUB_PROJECT_NAME/issues/"
echo "Searching for issues to remove in PullRequest $PULL_REQUEST_ID with Template $COMMENT_TEMPLATE ..."

curl \
  -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GITHUB_TOKEN" \
  "$issues_api_url/$PULL_REQUEST_ID/comments" >github_issues.json

cat github_issues.json

jq -c "[ .[] | select( .body | contains(\"$COMMENT_TEMPLATE\")) ] | .[] .id" github_issues.json >issues_to_delete

echo "Found next issues to remove:"
cat issues_to_delete

echo "Starting removing issues from the list..."
while read -r line; do
  echo "Removing issue #$line"
  curl \
    -X DELETE \
    -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GITHUB_TOKEN" \
    "$issues_api_url/comments/$line" ||
    echo "Unable to remove issue #$line"
done <issues_to_delete