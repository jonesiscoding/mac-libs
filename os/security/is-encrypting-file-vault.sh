#!/bin/bash

function os::security::isEncryptingFileVault() {
  [ -f /usr/bin/fdesetup ] && /usr/bin/fdesetup status | /usr/bin/grep -q 'Encryption in progress'
}