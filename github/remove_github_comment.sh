#!/bin/bash

usage() {
  echo "This script removes all comments (issues) in github pull requests that matches template"
  echo "Usage:"
  echo "  remove_github_comment.sh <pullRequestId> <comment template>"
  echo "GITHUB_TOKEN, GITHUB_PROJECT_USERNAME, PULL_REQUEST_ID variables must be exported"
  echo "Example:"
  echo "  remove_github_comment.sh \"## Manifest Diff\""
}
usage
COMMENT_TEMPLATE=$1

echo "Searching for comments to remove in PullRequest $PULL_REQUEST_ID with Template $COMMENT_TEMPLATE ..."
issues_api_curl="repos/$GITHUB_PROJECT_USERNAME/$GITHUB_PROJECT_NAME/issues"

#https://docs.github.com/en/rest/issues/comments#list-issue-comments
gh api "$issues_api_curl/742/comments" \
  -X GET \
  --jq "[ .[] | select( .body | contains(\"$COMMENT_TEMPLATE\")) ] | .[] .id" >comments_to_delete

echo "Found next comments to remove:"
cat comments_to_delete

echo "Starting removing comments from the list..."
while read -r line; do
  remove_comment_url="$issues_api_curl/comments/$line"
  echo "Removing comment #$line, url=$remove_comment_url"
  #https://docs.github.com/en/rest/issues/comments#delete-an-issue-comment
  gh api "$remove_comment_url" -X DELETE || echo "Unable to remove issue #$line"
done <comments_to_delete

rm -f comments_to_delete