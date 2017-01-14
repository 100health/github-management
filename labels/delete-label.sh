#!/bin/bash
# Renames a label in all repos defined in repos.json. Note that it will also update the label with the color defined in labels.json
#  author: {{TC}}
#  created: {{1/13/2017}}
#  updated:
#  required permissions: none
#  required env vars: GITHUB_TOKEN - should be set to a personal access token
# Usage:
#  bash rename-label.sh $OLD_NAME $NEW_NAME

set -o nounset # Abort if you reference an undefined variable
set -o errexit # Abort if a command returns non-zero exit code
set -o pipefail # Abort if a pipeline includes non-zero exit codes (requires Bash v3.x)

if [ -z $GITHUB_TOKEN ]; then
  echo "GITHUB_TOKEN must be set"
  exit 1
fi

if [ -z "${1:-}" ]; then
  echo "OLD_NAME is required"
  exit 1
fi

NAME="$1"
REPOS=$(cat ../repos.json)
NUM_REPOS=$(echo $REPOS | jq '. | length')

source ./label-functions.sh
source ../warn-prompt.sh

echo "This will delete the label \"$NAME\" in all repos in repos.json"

warnPrompt "Any issues or pull requests with this label will have the label removed.\n"

repoIdx=0
while [[ $repoIdx -lt $NUM_REPOS ]]
do
  REPO=$(echo $REPOS | jq -r --arg repoIdx $repoIdx '.[$repoIdx|tonumber].name')
  OWNER=$(echo $REPOS | jq -r --arg repoIdx $repoIdx '.[$repoIdx|tonumber].owner')

  deleteLabel -n="$NAME" -o="$OWNER" -r="$REPO"

  ((repoIdx = repoIdx + 1))
done

