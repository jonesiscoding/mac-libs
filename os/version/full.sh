#!/bin/bash

function os::version::full() {
  /usr/bin/sw_vers -productVersion
}