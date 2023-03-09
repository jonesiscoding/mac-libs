#!/bin/bash


#
# Initialize Library
#
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_updates_metadata" ] && return 0
# shellcheck disable=SC2034
sourced_lib_updates_metadata=0
# shellcheck disable=SC2164

#
# Sourced Functions
#

# shellcheck source=./settings.sh disable=SC2164
source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/settings.sh"

#
# Internal Functions
#

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
  IFS=','
  # shellcheck disable=SC2206
  updateLineArr=($in)
  unset IFS;

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

function _minutesSinceBoot() {
  local secUp epochTime adjTime

  secUp=$( sysctl kern.boottime | awk -F'[= |,]' '{print $6}' )
  epochTime=$( date +%s )
  adjTime=$( echo "$epochTime" - "$secUp" | bc )

  echo "scale=0;$adjTime / 60" | bc
}

function _updatesMetadataInitFile() {
  local fPath fDir fName fAge bAge

  fPath="$1"
  fAge="${2:-0}"

  if [[ "$fAge" -gt "0" ]]; then
    if [ -f "$fPath" ]; then
      # Use minutes since boot if that's less than $fAge
      bAge=$(_minutesSinceBoot)
      [[ "$bAge" -lt "$fAge" ]] && fAge="$bAge"
      # Delete the file if it's older than fAge in Minutes
      fName=$(/usr/bin/basename "$fPath")
      fDir=$(/usr/bin/dirname "$fPath")
      cd "$fDir" || return 1
      /usr/bin/find . -type f -name "$fName" -mmin +"$fAge" -delete
    fi
  fi

  # Create File If Needed
  if [ ! -f "$fPath" ]; then
    if ! /usr/bin/touch "$fPath"; then
      return 1
    fi
  fi

  return 0
}

#
# Public Functions
#
function updates::metadata::init() {
  # Init the updates.* Files
  _updatesMetadataInitFile "$(updates::metadata::file::updates)" 30 || return 1
  _updatesMetadataInitFile "$(updates::metadata::file::updatesRaw)" 30 || return 1

  # Init the installed.txt file
  _updatesMetadataInitFile "$(updates::metadata::file::installed)" || return 1
  _updatesMetadataInitFile "$(updates::metadata::file::installedRaw)" || return 1

  # Init the downloaded.txt File
  _updatesMetadataInitFile "$(updates::metadata::file::downloaded)" || return 1
  _updatesMetadataInitFile "$(updates::metadata::file::downloadedRaw)" || return 1

  # Init the deferred.count File
  _updatesMetadataInitFile "$(updates::metadata::file::deferrals)" || return 1

  # Import Raw Downloads & Installs
  updates::metadata::import::installed
  updates::metadata::import::downloaded
}

function updates::metadata::add::downloaded() {
  local update downloadedTxt

  update="$1"
  downloadedTxt="$(updates::metadata::file::downloaded)"

  if ! updates::metadata::is::downloaded "$update"; then
    echo "$update" >> "$downloadedTxt"
  fi

  return 0
}

function updates::metadata::add::downloaded::allPending() {
  local jsonFile jsonCode jsGetLabels labels line

  jsonFile=$(updates::metadata::file::updates)
  jsonCode=$(/bin/cat "$jsonFile")

  read -r -d '' jsGetLabels <<EOF
  function run() {
    const updates = JSON.parse(\`$jsonCode\`);
    var updatesJson = [];
    for (const update of updates) {
      updatesJson.push(update.Title)
    }

    return updatesJson.join("\n")
  }
EOF

  labels=$(/usr/bin/osascript -l "JavaScript" <<< "${jsGetLabels}")
  while IFS=$'\n' read -r line; do
    updates::metadata::add::downloaded "$line"
  done <<< "$labels"

  return 0
}

function updates::metadata::add::installed() {
  local update installedTxt

  update="$1"
  installedTxt="$_libsMacMdm_WorkDir/installed.txt"

  if ! updates::metadata::is::installed "$update"; then
    echo "$update" >>"$installedTxt"
  fi

  return 0
}

function updates::metadata::count::deferrals() {
  local deferrals
  local deferralFile

  deferralFile="$(updates::metadata::file::deferrals)"

  # shellcheck disable=SC2155
  typeset -i deferrals=$(cat "${deferralFile}")

  # shellcheck disable=SC2086
  echo $deferrals
}

function updates::metadata::file::updatesRaw() {
  echo "$(updates::settings::workDir)/updates.raw"
}

function updates::metadata::file::updates() {
  echo "$(updates::settings::workDir)/updates.json"
}

function updates::metadata::file::deferrals() {
  echo "$(updates::settings::workDir)/deferral.count"
}

function updates::metadata::file::downloaded() {
  echo "$(updates::settings::workDir)/downloaded.txt"
}

function updates::metadata::file::downloadedRaw() {
  local downloadedFile

  downloadedFile=$(updates::metadata::file::downloaded)
  echo "${downloadedFile//.txt/.raw}"
}

function updates::metadata::file::installed() {
  echo "$(updates::settings::workDir)/installed.txt"
}

function updates::metadata::file::installedRaw() {
  local installedFile

  installedFile=$(updates::metadata::file::installed)
  echo "${installedFile//.txt/.raw}"
}

function updates::metadata::get::raw() {
  local updatesRaw lines updatePid suLine suTimeout suFail

  updates::metadata::init
  updatesRaw=$(updates::metadata::file::updatesRaw)
  if [ -f "$updatesRaw" ]; then
    lines=$(cat "$updatesRaw")
  fi

  if [ -z "$lines" ]; then
    /usr/sbin/softwareupdate --list --all > "$updatesRaw" 2>&1 &
    updatePid=$!
    suTimeout=true
    suFail=true

    # Credit: https://github.com/Macjutsu/super
    while read -t 180 -r suLine; do
      if echo "$suLine" | /usr/bin/grep -q "Can’t connect"; then
        suTimeout=false
        break
      elif echo "$suLine" | /usr/bin/grep -q "Couldn't communicate"; then
        suTimeout=false
        break
      elif echo "$suLine" | /usr/bin/grep -q "Software Update found"; then
        suTimeout=false
        suFail=false
        /usr/bin/wait $updatePid
        break
      elif echo "$suLine" | /usr/bin/grep -q "No new software available."; then
        suTimeout=false
        suFail=false
        break
      fi
    done < <(/usr/bin/tail -n1 -f "$updatesRaw")
    # shellcheck disable=SC2034
    for i in {1..180}
    do
      if /bin/ps -p $updatePid >&-; then
        sleep 1
      else
        break;
      fi
    done
    lines=$(cat "$updatesRaw")
  fi

  echo "$lines"
}

function updates::metadata::get::pending() {
  local jsonFile jsonCode jsGetPendingList

  updates::metadata::init
  jsonFile=$(updates::metadata::file::updates)
  if [ -f "$jsonFile" ]; then
    jsonCode=$(/bin/cat "$jsonFile")
  fi

  if [ -z "$jsonCode" ]; then
    updates::metadata::import::pending
    if [ -f "$jsonFile" ]; then
      jsonCode=$(/bin/cat "$jsonFile")
    fi
  fi

  if [ -n "$jsonCode" ]; then
    read -r -d '' jsGetPendingList <<EOF
    function run() {
      const updates = JSON.parse(\`$jsonCode\`);
      var updatesJson = [];
      for (const update of updates) {
        updatesJson.push(JSON.stringify(update))
      }

      return updatesJson.join("\n")
    }
EOF

    /usr/bin/osascript -l "JavaScript" <<< "${jsGetPendingList}"
  fi
}

function updates::metadata::increment::deferrals() {
  local deferrals deferralPath

  deferralPath=$(updates::metadata::file::deferrals)
  # shellcheck disable=SC2155
  typeset -i deferrals=$(/bin/cat "${deferralPath}")
  deferrals=$((deferrals+1))
  echo $deferrals > "${deferralPath}"

  echo $deferrals
}

function updates::metadata::is::installed() {
  local p

  p="^${1}$"
  if /usr/bin/grep -q -E "$p" "$(updates::metadata::file::installed)"; then
    return 0
  else
    return 1
  fi
}

function updates::metadata::is::downloaded() {
  local p dlFile

  p="^${1}$"
  dlFile=$(updates::metadata::file::downloaded)

  if [ -f "$dlFile" ] && /usr/bin/grep -q -E "$p" "$dlFile"; then
    return 0
  else
    return 1
  fi
}

function updates::metadata::import::downloaded() {
  local downloadedRaw downloadedFile suOutput

  downloadedFile=$(updates::metadata::file::downloaded)
  downloadedRaw=${downloadedFile//.txt/.raw}
  if [ -f "$downloadedRaw" ]; then
    suOutput=$(cat "$downloadedRaw")
    updates::metadata::set::downloaded "$suOutput" && return 0
  fi

  return 1
}

function updates::metadata::import::installed() {
  local installedRaw installedFile suOutput

  installedFile=$(updates::metadata::file::installed)
  installedRaw=${installedFile//.txt/.raw}
  if [ -f "$installedRaw" ]; then
    suOutput=$(cat "$installedRaw")
    updates::metadata::set::installed "$suOutput" && return 0
  fi

  return 1
}

function updates::metadata::import::pending() {
  local updatesFile lines line updateJson updatesJson

  updatesJson=""
  updatesFile=$(updates::metadata::file::updates)
  lines=$(updates::metadata::get::raw)
  if [ -n "$lines" ]; then

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
          updateJson=$(_parseUpdateLine "$line")
          if [ -n "$updateJson" ]; then
            if [ -z "$updatesJson" ]; then
              updatesJson="[\n    $updateJson"
            else
              updatesJson="${updatesJson},\n    $updateJson"
            fi
          fi
        fi
      done <<< "$lines"
    fi

    if [ -n "$updatesJson" ]; then
      updatesJson="${updatesJson}\n]"
    else
      updatesJson="[]"
    fi

    echo -e "$updatesJson" > "$updatesFile"
  fi

  return 0
}

function updates::metadata::reset::deferrals() {
  local deferralsFile

  deferralsFile=$(updates::metadata::file::deferrals)
  [ -f "$deferralsFile" ] && rm "$deferralsFile"
  if _updatesMetadataInitFile "$deferralsFile"; then
    return 0
  else
    return 1
  fi
}

function updates::metadata::reset::pending() {
  local jsonFile rawFile

  jsonFile=$(updates::metadata::file::updates)
  rawFile=$(updates::metadata::file::updatesRaw)
  [ -f "$jsonFile" ] && rm "$jsonFile"
  [ -f "$rawFile" ] && rm "$rawFile"

  _updatesMetadataInitFile "$jsonFile"
  _updatesMetadataInitFile "$rawFile"
}

function updates::metadata::set::downloaded() {
  local suOutput downloadsFile line

  suOutput="$1"
  downloadsFile="$(updates::metadata::file::downloaded)"

  # Clear Existing Downloads
  [ -f "$downloadsFile" ] && rm "$downloadsFile"
  /usr/bin/touch "$downloadsFile"

  if [ -n "$suOutput" ]; then
    # Loop through Downloaded & Add to Cached File
    while IFS=$'\n' read -r line; do
      if [ -n "$line" ]; then
        line=$(echo "$line" | grep "Downloaded" | cut -d " " -f 2-)
        if [ -n "$line" ]; then
          updates::metadata::add::downloaded "$line"
        fi
      fi
    done <<< "$suOutput"
  fi

  return 0
}

function updates::metadata::set::installed() {
  local suOutput line

  suOutput="$1"
  if [ -n "$suOutput" ]; then
    # Loop through Downloaded & Add to Cached File
    while IFS=$'\n' read -r line; do
      if [ -n "$line" ]; then
        line=$(echo "$line" | /usr/bin/grep "Installing" | cut -d " " -f 2-)
        if [ -n "$line" ]; then
          if echo "$suOutput" | /usr/bin/grep -q "Done with ${line}"; then
            updates::metadata::add::installed "$line"
          fi
        fi
      fi
    done <<< "$suOutput"
  fi

  return 0
}
