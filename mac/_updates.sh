#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_updates" ] && return 0

# shellcheck disable=SC2206
function _parseUpdateLine() {
  local in
  local updateLineArr
  local item
  local key
  local value
  local out
  local restart
  local shutdown

  restart="NO"
  shutdown="NO"
  in="$1"

  updateLineArr=()
  IFS=','; updateLineArr=($in); unset IFS;

  for field in "${updateLineArr[@]}"
  do
    item="$field"
    key=$(echo "$item" | cut -d ':' -f1 | sed 's/\* //' | sed -e 's/^[[:space:]]*//')
    value=$(echo "$item" | cut -d ':' -f2 | sed -e 's/^[[:space:]]*//' )
    if [ -n "$key" ] && [ -n "$value" ]; then
      if [ "$key" == "Action" ]; then
        if [ "$value" == "restart" ]; then
          restart="YES"
        elif [ "$value" == "shut down" ]; then
          shutdown="YES"
        fi
      else
        if [ -z "$out" ]; then
          out="{ \"${key}\": \"$value\""
        else
          out="$out, \"${key}\": \"$value\""
        fi
      fi
    fi
  done

  if [ -n "$out" ]; then
    out="$out, \"Restart\": \"$restart\""
    out="$out, \"Halt\": \"$shutdown\""
    out="$out }"
  else
    out="{}"
  fi

  echo "$out"
}

function _getUpdates() {
  local updatePid
  local i
  local cwd

  if [ -z "$_libsMacUpdates_outputRaw" ]; then
    # Delete cached data older than 30 min
    cwd="$(/bin/pwd)"
    cd "$_libsMacUpdates_WorkPath" || exit 1
    /usr/bin/find . -type f -name 'updates.txt' -mmin +30 -delete
    cd "$cwd" || exit 1
    if [ ! -f "$_libsMacUpdates_WorkPath/updates.txt" ]; then
      /usr/sbin/softwareupdate --list --all >>"$_libsMacUpdates_WorkPath"/updates.txt 2>&1 &
      updatePid=$!
      for i in {1..180}
      do
        if /bin/ps -p $updatePid >&-; then
          sleep 1
        else
          break;
        fi
      done
    fi

    touch "$_libsMacUpdates_WorkPath/updates.txt"
    _libsMacUpdates_outputRaw=$(/bin/cat "$_libsMacUpdates_WorkPath/updates.txt")
  fi

  echo "$_libsMacUpdates_outputRaw"
}

function mac::updates::populate() {
  local lines
  local updateLineArr
  local line
  local update

  lines=$(_getUpdates)
  updateLineArr=()
  [ -n "$lines" ] && lines=$(echo "$lines" | /usr/bin/grep -v "Software Update Tool")
  [ -n "$lines" ] && lines=$(echo "$lines" | /usr/bin/grep -v "XType")
  [ -n "$lines" ] && lines=$(echo "$lines" | /usr/bin/grep -v "Finding available software")
  [ -n "$lines" ] && lines=$(echo "$lines" | /usr/bin/grep -v "No new software available")
  [ -n "$lines" ] && lines=$(echo "$lines" | /usr/bin/grep -v "Software Update found the following new or updated software:")
  [ -n "$lines" ] && lines=$(echo "$lines" | /usr/bin/grep -v "The operation couldn’t be completed.")
  [ -n "$lines" ] && lines=$(echo "$lines" | /usr/bin/sed '/^\* Label/N;s/\n/,/')

  if [ -n "$lines" ]; then
    while IFS= read -r line; do
      if [ -n "$line" ]; then
        updateLineArr+=("$line")
      fi
    done <<< "$lines"

    # shellcheck disable=SC2034
    libsMacParsedUpdates=()
    for updateLine in "${updateLineArr[@]}"
    do
      update=$(_parseUpdateLine "$updateLine")
      # shellcheck disable=SC2034
      libsMacParsedUpdates+=("$update")
    done
  else
    # shellcheck disable=SC2034
    libsMacParsedUpdates=()
  fi
}

function mac::updates::catalogUrl() {
  [ -z "$_libsMacUpdates_CatalogUrl" ] && _libsMacUpdates_CatalogUrl=$(/usr/bin/defaults read "/Library/Managed Preferences/com.apple.SoftwareUpdate" CatalogURL 2>"/dev/null")
  echo "$_libsMacUpdates_CatalogUrl"
}

function mac::updates::defer::increment() {
  local deferrals

  [ ! -d "$_libsMacUpdates_WorkPath" ] && /bin/mkdir -p "$_libsMacUpdates_WorkPath"
  touch "${_libsMacUpdates_DeferralPath}"
  # shellcheck disable=SC2155
  typeset -i deferrals=$(/bin/cat "${_libsMacUpdates_DeferralPath}")
  deferrals=$((deferrals+1))
  echo $deferrals > "${_libsMacUpdates_DeferralPath}"

  echo $deferrals
}

function mac::updates::defer::count() {
  local deferrals
  local deferralFile

  deferralFile="$_libsMacUpdates_DeferralPath"

  [ ! -d "$_libsMacUpdates_WorkPath" ] && /bin/mkdir -p "$_libsMacUpdates_WorkPath"
  touch "${deferralFile}"
  # shellcheck disable=SC2155
  typeset -i deferrals=$(cat "${deferralFile}")

  # shellcheck disable=SC2086
  echo $deferrals
}

function mac::updates::defer::clear() {
  [ -f "$_libsMacUpdates_DeferralPath" ] && rm "$_libsMacUpdates_DeferralPath" && touch "$_libsMacUpdates_DeferralPath"

  return 0
}

function mac::updates::defer::allowed() {
  local deferrals

  deferrals=$(mac::updates::defer::count)

  if [ "$deferrals" -le "$libsMacUpdatesMaxDeferrals" ]; then
    return 0
  else
    return 1
  fi
}

if [ -z "$sourced_lib_mac_updates" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_updates=0

  if [ -n "$libsMacUpdatesWorkPath" ]; then
    _libsMacUpdates_WorkPath="$libsMacUpdatesWorkPath"
  else
    if [ -n "$libsMacUpdatesPlist" ] && [ -f "$libsMacUpdatesPlist" ]; then
      _libsMacUpdates_WorkPath=$(/usr/bin/defaults read "$libsMacUpdatesPlist" "workPath")
    elif [ ! -f "$libsMacUpdatesPlist" ]; then
      echo "ERROR: $libsMacUpdatesPlist does not exist."
      exit 44
    else
      echo "ERROR: You must declare \$libsMacUpdatesPlist or \$libsMacUpdatesWorkPath before sourcing _updates.sh"
      exit 44
    fi
  fi

  if [ -n "$libsMacUpdatesPlist" ] && [ -f "$libsMacUpdatesPlist" ]; then
    libsMacUpdatesMaxDeferrals=$(/usr/bin/defaults read "$libsMacUpdatesPlist" "maxDeferrals")
  elif [ ! -f "$libsMacUpdatesPlist" ]; then
    echo "ERROR: $libsMacUpdatesPlist does not exist."
    exit 44
  else
    echo "ERROR: You must declare \$libsMacUpdatesPlist or \$libsMacUpdatesMaxDeferrals before sourcing _updates.sh"
    exit 44
  fi

  [ ! -d "$_libsMacUpdates_WorkPath" ] && /bin/mkdir -p "$_libsMacUpdates_WorkPath"
  _libsMacUpdates_DeferralPath="$_libsMacUpdates_WorkPath/deferral.count"
  /usr/bin/touch "$_libsMacUpdates_DeferralPath"
  _libsMacUpdates_outputRaw=""
  _libsMacUpdates_CatalogUrl=""
  # shellcheck disable=SC2034
  libsMacParsedUpdates=()
fi