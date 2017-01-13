#!/bin/bash

set -o nounset # quit if we reference an unset variable
set -o errexit # quit if a command returns non-zero exit code (a.k.a. set -e)
set -o pipefail # Abort if a pipeline includes non-zero exit codes (requires Bash v3.x)

warnPrompt () {
  echo -e $1

  read -p "Are you sure you want to continue? (Yes/n) " ANSWER

  ANSWER=$(echo $ANSWER | tr '[:upper:]' '[:lower:]')

  if [[ "$ANSWER" != "yes" ]]; then
    return 1;
  fi

  return 0
}