#!/bin/bash

# /*!
#   Public: Uses jamfHelper to ask a yes/no question
#
#   $1  Window Title
#   $2  Window Heading
#   $3  Question Text
#   $4  Yes Button Label
#   $5  No Button Label
#   $6  Icon Path
# */
function jamf::output::ask() {
  local heading title question buttonYes buttonNo icon

  title="$1"
  heading="$2"
  question="$3"
  buttonYes="${4:-Yes}"
  buttonNo="${5:-No}"
  icon="${6:-/Applications/Self Service.app/Contents/Resources/AppIcon.icns}"

  if [ ! -f "$_libsMacJamf_Helper" ]; then
    # Show error message in logs
    output::errorln "ERROR: Jamf Helper Not Found!"
  fi

  if "$_libsMacJamf_Helper" -windowType hud -lockHUD -title "$title" -heading "$heading" -description "$question" -icon "$icon" -button1 "$buttonYes" -button2 "$buttonNo" -defaultButton "0" -cancelButton "2"; then
    return 0
  else
    return $?
  fi
}

# /*!
#   Public: Uses jamfHelper to display a message that cannot be closed by the user
#
#   $1  Window Title
#   $2  Window Heading
#   $3  Message Text
#   $4  Icon Path
# */
function jamf::output::assert() {
  local heading title message icon

  title="$1"
  heading="$2"
  message="$3"
  icon="${4:-/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns}"
  [ ! -f "$icon" ] && icon="$_libsMacJamf_IconDefault"

  if [ ! -f "$_libsMacJamf_Helper" ]; then
    # Show error message in logs
    echo "ERROR: Jamf Helper Not Found"
    return 1
  fi

  "$_libsMacJamf_Helper" -windowType hud -lockHUD -title "$title" -heading "$heading" -description "$message" -icon "$icon" &
  disown
}

# /*!
#   Public: Uses jamfHelper to display a message with a countdown, and wait for the countdown
#   to complete before returning
#
#   $1  Window Title
#   $2  Window Heading
#   $3  Message Text
#   $4  Icon Path
#   $5  Countdown Timeout
# */
function jamf::output::countdown() {
  local heading title message icon timeout

  title="$1"
  heading="$2"
  message="$3"
  icon="${4:-/Applications/Self Service.app/Contents/Resources/AppIcon.icns}"
  timeout="${5:-300}"
  [ ! -f "$icon" ] && icon="$_libsMacJamf_IconDefault"

  if [ ! -f "$_libsMacJamf_Helper" ]; then
    # Show error message in logs
    echo "ERROR: Jamf Helper Not Found"
    return 1
  fi

  "$_libsMacJamf_Helper" -windowType hud -lockHUD -title "$title" -heading "$heading" -description "$message" -icon "$icon" -timeout "$timeout" -countdown
}

# /*!
#   Public: Uses jamfHelper to display a message.
#
#   $1  Window Title
#   $2  Window Heading
#   $3  Message Text
#   $4  Icon Path
# */
function jamf::output::notify() {
  local heading title message icon

  title="$1"
  heading="$2"
  message="$3"
  icon="${4:-/Applications/Self Service.app/Contents/Resources/AppIcon.icns}"
  [ ! -f "$icon" ] && icon="$_libsMacJamf_IconDefault"

  if [ ! -f "$_libsMacJamf_Helper" ]; then
    # Show error message in logs
    echo "ERROR: Jamf Helper Not Found"
    return 1
  fi

  "$_libsMacJamf_Helper" -windowType hud -title "$title" -heading "$heading" -description "$message" -icon "$icon" &
  disown
}

# /*!
#   Public: Uses the jamf binary to display a message.
#
#   $1  Message Text
# */
function jamf::output::alert() {
  local msg

  msg="$1"

  # Show error message in logs
  if [ ! -f "$_libsMacJamf_Bin" ]; then
    echo "ERROR: Jamf Helper Not Found - Could Not Show Alert"
  fi

  "$_libsMacJamf_Bin" displayMessage -message "$msg" &

  return 0
}

if [ -z "$sourced_lib_jamf_output" ]; then
  # shellcheck disable=SC2034
  sourced_lib_jamf_output=0

  # Paths to Binaries
  _libsMacJamf_Helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
  _libsMacJamf_Bin="/usr/local/bin/jamf"

  # Paths to Icons
  # shellcheck disable=SC2034
  _libsMacJamf_IconAlert="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"
  _libsMacJamf_IconDefault="/Applications/Self Service.app/Contents/Resources/AppIcon.icns"
fi