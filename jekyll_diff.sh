#!/bin/bash

set -x # verbose mode
set -e # stop executing after error

echo "Starting Jekyll diff script"


####################################################
# Run prerequisite checks
####################################################
if [ "$GITHUB_EVENT_NAME" = "pull_request_target" ] && [ -n "${GITHUB_TOKEN}" ]; then
   echo "ERROR: Injecting the Github Token into a build triggered by a forked repo is blocked due to security concerns!"
   echo "See https://securitylab.github.com/research/github-actions-preventing-pwn-requests for more info"
   exit 1
fi

if [ "$GITHUB_EVENT_NAME" != "push" ] &&
   [ "$GITHUB_EVENT_NAME" != "pull_request" ] &&
   [ "$GITHUB_EVENT_NAME" != "pull_request_target" ]; then
    echo "ERROR: Unsupported trigger for the action"
    exit 1
fi


####################################################
# Create workspace for Jekyll Diff Action
####################################################

mkdir /jekyll-diff-action
mkdir /jekyll-diff-action/new
mkdir /jekyll-diff-action/old
mkdir /jekyll-diff-action/diff
mkdir /jekyll-diff-action/workspace
cp --archive /github/workspace/. /jekyll-diff-action/workspace
cd /jekyll-diff-action/workspace


####################################################
# Determine whether it's a PR or Commit
####################################################

if [ "$GITHUB_EVENT_NAME" = "push" ]; then
    echo "Commit mode"
    common_ancestor_sha="$(git rev-parse HEAD^1)"
    api_url="https://api.github.com/repos/${GITHUB_REPOSITORY}/commits/${GITHUB_SHA}/comments"
else
    echo "PR mode"
    common_ancestor_sha="$(git merge-base $GITHUB_SHA origin/$GITHUB_BASE_REF)" # find the closest common ancestor between the PR branch and the target branch
    api_url="$(cat $GITHUB_EVENT_PATH | jq --raw-output '.pull_request.comments_url')"
fi


####################################################
# Build both site versions and determine diff
####################################################

chmod -R a+rw /jekyll-diff-action
jekyll build --trace --destination /jekyll-diff-action/new
git checkout --force $common_ancestor_sha
chmod -R a+rw /jekyll-diff-action
jekyll build --trace --destination /jekyll-diff-action/old
diff="$(diff --recursive --new-file --unified=0 /jekyll-diff-action/old /jekyll-diff-action/new || true)" # 'or true' because a non-identical diff outputs 1 as the exit status


####################################################
# Export the generated diff
####################################################

echo "$diff" > /github/workspace/jekyll-site.diff

if [ -n "${GITHUB_TOKEN}" ]; then
    echo "Commenting the diff on Github "

    new_line=$'\n'
    comment="\`\`\`diff $new_line$diff$new_line\`\`\`"

    curl --include --verbose --fail \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    --request POST --data "$(jq --null-input --arg escaped_diff "$comment" '{body: $escaped_diff}')" \
    $api_url
fi

echo "Done"
