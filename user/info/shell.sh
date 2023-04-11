#!/bin/bash

function user::shell() {
  /usr/bin/finger "$libsMacUser" | /usr/bin/grep 'Shell: ' | /usr/bin/cut -d ':' -f3
}
