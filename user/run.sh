#!/bin/bash

function user::run() {
  /usr/bin/su - "$libsMacUser" -c "$1"
}