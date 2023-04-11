#!/bin/bash

function os::version::minor() {
  /usr/bin/sw_vers -productVersion | /usr/bin/cut -d "." -f2
}