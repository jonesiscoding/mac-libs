#!/bin/bash

function jamf::ea::string() {
  local result default

  result="$1"
  default="${2:-Unknown}"

  if [ -n "$result" ]; then
    echo "<result>$result</result>"
  else
    echo "<result>$default</result>"
  fi

  return 0
}

function jamf::ea::bool() {
  local result

  result="$1"
  if [ -n "$result" ] && [ "$result" != "0" ] && [ "$result" != "false" ] && [ "$result" != "FALSE" ]; then
    echo "<result>true</result>"
  else
    echo "<result>false</result>"
  fi

  return 0
}