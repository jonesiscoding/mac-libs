#!/bin/bash

# Prevent being sourced more than once
[ "${BASH_SOURCE[0]}" != "$0" ] && [ -n "$sourced_lib_mac_environment" ] && return 0

function mac::environment::user::bash() {
  local key
  local value
  local bashrc

  key="$1"
  value="$2"
  bashrc="/Users/$libsMacUser/.bashrc"
  user::touch "$bashrc"

  if ! grep -q "${key}=${value}" "$bashrc"; then
    echo "export ${key}=${value}" >>"$bashrc"
  fi

  if ! grep -q "${key}=${value}" "$bashrc"; then
    return 1
  fi

  if user::isConsole; then
    _libsMacEnvironment_UserUpdated=true
  fi

  return 0
}

function mac::environment::user::isUpdated() {
  return $_libsMacEnvironment_UserUpdated
}

function mac::environment::user::zsh() {
  local key
  local value
  local zshrc

  key="$1"
  value="$2"
  zshrc="/Users/$libsMacUser/.zshrc"
  user::touch "$zshrc"

  if ! grep -q "${key}=${value}" "$zshrc"; then
    echo "export ${key}=${value}" >>"$zshrc"
  fi

  if ! grep -q "${key}=${value}" "$zshrc"; then
    return 1
  fi

  if user::isConsole; then
    _libsMacEnvironment_UserUpdated=true
  fi

  return 0
}

function mac::environment::user::gui() {
  local key value launchagent

  key="${1}"
  value="${2}"
  launchagent="/Users/$libsMacUser/Library/LaunchAgents/${libBundlePrefix}.env.${key}.plist"
  /bin/cat >"$launchagent" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  <key>Label</key>
  <string>setenv.$key</string>
  <key>Nice</key>
  <integer>-20</integer>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/launchctl</string>
    <string>setenv</string>
    <string>$key</string>
    <string>$value</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
  user::chown "$launchagent" || return 1

  if user::isConsole; then
    _libsMacEnvironment_UserUpdated=true
  fi

  return 0
}

if [ -z "$sourced_lib_mac_environment" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_environment=0

  [ -z "$libBundlePrefix" ] && libBundlePrefix="org.organization"

  _libsMacEnvironment_UserUpdated=true
fi