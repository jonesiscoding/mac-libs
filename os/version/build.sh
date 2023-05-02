#!/bin/bash

function os::version::build() {
  /usr/bin/sw_vers -buildVersion
}
