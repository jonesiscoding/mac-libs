#!/bin/bash

function os::version::major() {
  /usr/bin/sw_vers -productVersion | /usr/bin/cut -d "." -f1
}