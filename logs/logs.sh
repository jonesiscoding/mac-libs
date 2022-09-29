#!/bin/bash

# shellcheck disable=SC2164
__libsMacSourceDir="$(cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")"; /bin/pwd -P)"

#
# Sourced Functions
#

# shellcheck source=./../updates/metadata.sh
source "$libsMacSourcePath/updates/metadata.sh"

#
# Public Functions
#

function logs::file::SoftwareUpdateMacController::progress() {
  echo "$(updates::settings::workDir)/com.apple.SoftwareUpdateMacController.progress.log"
}

function logs::file::ManagedClient::HTTPUtil() {
  echo "$(updates::settings::workDir)/com.apple.ManagedClient.HTTPUtil.log"
}

function logs::stream::ManagedClient::HTTPUtil() {
  local logFile logPid

  logFile="$_libsMacMdm_WorkDir/com.apple.ManagedClient.HTTPUtil.log"

  # Start Log Streaming
  log stream --predicate '(subsystem == "com.apple.ManagedClient") && (category == "HTTPUtil")' >> "$logFile" &
  logPid=$!
  disown

  echo $logPid
}

function logs::stream::SoftwareUpdateMacController::progress() {
  local logFile logPid

  logFile="$(logs::file::SoftwareUpdateMacController::progress)"

  # Start Log Streaming
  log stream --predicate '(subsystem == "com.apple.SoftwareUpdateMacController") && (eventMessage CONTAINS[c] "reported progress")' >> "$logFile" &
  logPid=$!
  disown

  echo $logPid
}

function logs::wait::ManagedClient::HTTPUtil::AcknowledgedScheduleOSUpdate() {
  local logFile line logPid query

  logPid="$1"
  logFile="$(logs::file::ManagedClient::HTTPUtil)"
  query="Received HTTP response (200) \[Acknowledged(ScheduleOSUpdate)"

  # Monitor Streamed Log File
  /usr/bin/tail -n 0 -f "$logFile" | while read -r line; do
    if echo "$line" | grep -q -w "$query"; then
      /bin/kill -9 "$logPid" >/dev/null 2>&1
      /usr/bin/pkill -P $$ tail
      break
    fi
  done

  return 0
}

function logs::action::SoftwareUpdateMacController::progress::onPhaseCompleted() {
  local logPid logFile line logPid query

  logPid="$1"
  logFile="$(logs::file::SoftwareUpdateMacController::progress)"
  query="phase:COMPLETED"

  # Monitor Streamed Log File
  /usr/bin/tail -n 0 -f "$logFile" | while read -r line ; do
    if echo "$line" | /usr/bin/grep -q -w "$query"; then
      # Mark all Pending Updates as Downloaded
      updates::metadata::add::downloaded::allPending
      # Stop Log Streaming
      /bin/kill -9 "$logPid" > /dev/null 2>&1
      /usr/bin/pkill -P $$ tail
      break
    fi
  done

  return 0
}