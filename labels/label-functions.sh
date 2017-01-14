#!/bin/bash

set -o nounset # quit if we reference an unset variable
set -o errexit # quit if a command returns non-zero exit code (a.k.a. set -e)
set -o pipefail # Abort if a pipeline includes non-zero exit codes (requires Bash v3.x)

createLabel () {
  # Parsing out the arguments for the function
  # -n - the name of the label
  # -c - the color of the label
  # -o - the owner of the repo
  # -r - the repo
  for i in "$@"
  do
  case $i in
    -n=*|--name=*)
    local _NAME="${i#*=}"
    shift # past argument=value
    ;;
    -c=*|--color=*)
    local _COLOR="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--owner=*)
    local _OWNER="${i#*=}"
    shift # past argument=value
    ;;
    -r=*|--repo=*)
    local _REPO="${i#*=}"
    shift # past argument=value
    ;;
    *)
    ;;
  esac
  done

  if [[ -z "${_NAME:-}" ]]; then
    echo "_NAME is required. Use option -n"
    return 1
  fi

  if [[ -z "${_COLOR:-}" ]]; then
    echo "_COLOR is required. Use option -c"
    return 1
  fi

  if [[ -z "${_OWNER:-}" ]]; then
    echo "_OWNER is required. Use option -o"
    return 1
  fi

  if [[ -z "${_REPO:-}" ]]; then
    echo "_REPO is required. Use option -r"
    return 1
  fi

  # Create the label
  local CURL_OUTPUT=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -X POST "https://api.github.com/repos/$_OWNER/$_REPO/labels" -d "{\"name\":\"$_NAME\", \"color\":\"$_COLOR\"}")
  local HAS_ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors // empty')

  # Check if there was an error
  if [ ! -z "$HAS_ERROR" ]; then
    local ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors[0].code')

    # If the label already exists
    if [ "$ERROR" == "already_exists" ]; then
      # We update
      # echo "Label $_NAME already exists. Updating..."
      updateLabel -n="$_NAME" -c="$_COLOR" -o="$_OWNER" -r="$_REPO"
    else
      echo "Unknown error: $ERROR"
      echo "Output from curl: "
      echo "$CURL_OUTPUT"
      return 1
    fi
  else
    echo "Created label \"$_NAME\" with color \"$_COLOR\" in \"$_OWNER/$_REPO\"."
  fi
}

updateLabel () {
  # Parsing out the arguments for the function
  # -n - the name of the label
  # -c - the color of the label
  # -o - the owner of the repo
  # -r - the repo
  # -u - updated name
  for i in "$@"
  do
  case $i in
    -n=*|--name=*)
    local _NAME="${i#*=}"
    shift # past argument=value
    ;;
    -u=*|--updated-name=*)
    local _NEW_NAME="${i#*=}"
    shift # past argument=value
    ;;
    -c=*|--color=*)
    local _COLOR="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--owner=*)
    local _OWNER="${i#*=}"
    shift # past argument=value
    ;;
    -r=*|--repo=*)
    local _REPO="${i#*=}"
    shift # past argument=value
    ;;
    *)
    ;;
  esac
  done

  if [[ -z "${_NAME:-}" ]]; then
    echo "_NAME is required. Use option -n"
    return 1
  fi

  if [[ -z "${_COLOR:-}" ]]; then
    echo "_COLOR is required. Use option -c"
    return 1
  fi

  if [[ -z "${_OWNER:-}" ]]; then
    echo "_OWNER is required. Use option -o"
    return 1
  fi

  if [[ -z "${_REPO:-}" ]]; then
    echo "_REPO is required. Use option -r"
    return 1
  fi

  if [[ -z "${_NEW_NAME:-}" ]]; then
    local _NEW_NAME=$_NAME
  fi

  local CURL_OUTPUT=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -X PATCH "https://api.github.com/repos/$_OWNER/$_REPO/labels/${_NAME// /%20}" -d "{\"name\":\"$_NEW_NAME\", \"color\":\"$_COLOR\"}")
  local HAS_ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors // empty')

  # Check for error
  if [ ! -z "$HAS_ERROR" ]; then
    local ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors[0].code')
    echo "Unknown error: $ERROR"
    echo "Output from curl: "
    echo "$CURL_OUTPUT"
    return 1
  else
    echo "Updated label \"$_NAME\" with new name \"$_NEW_NAME\" and color \"$_COLOR\" in \"$_OWNER/$_REPO\"."
  fi

}

deleteLabel () {
  # Parsing out the arguments for the function
  # -n - the name of the label
  for i in "$@"
  do
  case $i in
    -n=*|--name=*)
    local _NAME="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|--owner=*)
    local _OWNER="${i#*=}"
    shift # past argument=value
    ;;
    -r=*|--repo=*)
    local _REPO="${i#*=}"
    shift # past argument=value
    ;;
    *)
    ;;
  esac
  done

  if [[ -z "${_NAME:-}" ]]; then
    echo "_NAME is required. Use option -n"
    return 1
  fi

  if [[ -z "${_OWNER:-}" ]]; then
    echo "_OWNER is required. Use option -o"
    return 1
  fi

  if [[ -z "${_REPO:-}" ]]; then
    echo "_REPO is required. Use option -r"
    return 1
  fi


  local CURL_OUTPUT=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -X DELETE "https://api.github.com/repos/$_OWNER/$_REPO/labels/${_NAME// /%20}")
  local HAS_ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors // empty')

  # Check for error
  if [ ! -z "$HAS_ERROR" ]; then
    local ERROR=$(echo "$CURL_OUTPUT" | jq -r '.errors[0].code')
    echo "Unknown error: $ERROR"
    echo "Output from curl: "
    echo "$CURL_OUTPUT"
    return 1
  else
    echo "Deleted label \"$_NAME\" in \"$_OWNER/$_REPO\"."
  fi

}