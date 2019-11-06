#!/bin/sh

set -x # verbose mode
set -e # stop executing after error

echo "Starting Jekyll diff script"


####################################################
# Determine whether it's a PR or Commit
####################################################

if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    echo "PR mode"
    common_ancestor_sha="$(git merge-base $GITHUB_SHA origin/master)" # find the closest common ancestor between the PR branch and master
    api_url="$(cat $GITHUB_EVENT_PATH | jq --raw-output '.pull_request.comments_url')"
else
    echo "Commit mode"
    common_ancestor_sha="$(git rev-parse HEAD^1)"
    api_url="https://api.github.com/repos/${GITHUB_REPOSITORY}/commits/${GITHUB_SHA}/comments"
fi


####################################################
# Build both site versions and determine diff
####################################################

cd /github/workspace
jekyll build --destination /tmp/new/
git checkout $common_ancestor_sha
jekyll build --destination /tmp/old
diff="$(diff --recursive --new-file --unified=0 /tmp/old /tmp/new || true)" # 'or true' because a non-identical diff outputs 1 as the exit status


####################################################
# Comment the diff on Github
####################################################

comment="\`\`\`diff
$diff
\`\`\`"

curl --include --verbose --fail \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-H "Authorization: token ${GITHUB_TOKEN}" \
--request POST --data "$(jq --null-input --arg escaped_diff "$comment" '{body: $escaped_diff}')" \
$api_url


echo "Done"
