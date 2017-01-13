#!/bin/bash
# Creates the labels defined in labels.json in the repositories defined in repos.json
#  author: {{TC}}
#  created: {{1/13/2017}}
#  updated:
#  required permissions: none
#  required env vars: GITHUB_TOKEN - should be set to a personal access token
# Usage:
#  bash create-labels.sh

set -o nounset # Abort if you reference an undefined variable
set -o errexit # Abort if a command returns non-zero exit code
set -o pipefail # Abort if a pipeline includes non-zero exit codes (requires Bash v3.x)

if [ -z $GITHUB_TOKEN ]; then
  echo "GITHUB_TOKEN must be set"
  exit 1
fi

LABELS=$(cat labels.json)
NUM_LABELS=$(echo $LABELS | jq '. | length')
REPOS=$(cat ../repos.json)
NUM_REPOS=$(echo $REPOS | jq '. | length')

source ./label-functions.sh

labelIdx=0
while [[ $labelIdx -lt $NUM_LABELS ]]
do
  NAME=$(echo $LABELS | jq -r --arg labelIdx $labelIdx '.[$labelIdx|tonumber].name')
  COLOR=$(echo $LABELS | jq -r --arg labelIdx $labelIdx '.[$labelIdx|tonumber].color')

  echo "Creating / Updating label \"$NAME\" with color \"$COLOR\""

  repoIdx=0
  while [[ $repoIdx -lt $NUM_REPOS ]]
  do
    REPO=$(echo $REPOS | jq -r --arg repoIdx $repoIdx '.[$repoIdx|tonumber].name')
    OWNER=$(echo $REPOS | jq -r --arg repoIdx $repoIdx '.[$repoIdx|tonumber].owner')

    createLabel -n="$NAME" -c="$COLOR" -o="$OWNER" -r="$REPO"

    ((repoIdx = repoIdx + 1))
  done

  ((labelIdx = labelIdx + 1))
  echo
done