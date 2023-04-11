#!/bin/bash

function user::info::name() {
  /usr/bin/dscl . -read "$(user::dir)" RealName | /usr/bin/sed -n 's/^ //g;2p'
}