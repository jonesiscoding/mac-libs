#!/bin/bash

function errors::file {
  local file
  file="/tmp/$(/usr/bin/basename "$0").err"
  /usr/bin/touch "$file"
  echo "$file"
}

function errors::add() {
  local errorMsg errorFile

  errorMsg="$1"
  errorFile=$(errors::file)

  echo "$errorMsg" >> "$errorFile"

  return 0
}

function errors::reset() {
  local errorFile

  errorFile=$(errors::file)
  /bin/rm "$errorFile"
  /usr/bin/touch "$errorFile"

  return 0
}

function errors::get() {
  local errorFile indent spacer err

  errorFile=$(errors::file)
  indent="${1:-0}"
  if [[ $indent -gt 0 ]]; then
    spacer=$(for ((i=1; i <= indent; i++)); do printf "%s" " "; done)
  else
    spacer=""
  fi

  while IFS="" read -r err || [ -n "$err" ]
  do
    printf '%s%s\n' "$spacer" "$err"
  done < "$errorFile"
}