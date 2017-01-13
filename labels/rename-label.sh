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

if [ -z "${2:-}" ]; then
  echo "NEW_NAME is required"
  exit 1
fi

OLD_NAME="$1"
NEW_NAME="$2"
LABELS=$(cat labels.json)
REPOS=$(cat ../repos.json)
NUM_REPOS=$(echo $REPOS | jq '. | length')

source ./label-functions.sh
source ../warn-prompt.sh

echo "This will rename the label \"$OLD_NAME\" to \"$NEW_NAME\" in all repos in repos.json"

warnPrompt "Once you do this, remember to update the labels.json file with the new name of the label\n"

echo "Renameing label \"$OLD_NAME\" to \"$NEW_NAME\""
COLOR=$(echo $LABELS | jq -r --arg OLD_NAME "$OLD_NAME" '.[] | select(.name==$OLD_NAME) | .color')

if [ -z "$COLOR" ]; then
  echo "No color found for label $OLD_NAME"
  exit 1
fi

repoIdx=0
while [[ $repoIdx -lt $NUM_REPOS ]]
do
  REPO=$(echo $REPOS | jq -r --arg repoIdx $repoIdx '.[$repoIdx|tonumber].name')
  OWNER=$(echo $REPOS | jq -r --arg repoIdx $repoIdx '.[$repoIdx|tonumber].owner')

  updateLabel -n="$OLD_NAME" -c="$COLOR" -o="$OWNER" -r="$REPO" -u="$NEW_NAME"

  ((repoIdx = repoIdx + 1))
done

