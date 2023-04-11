#!/bin/bash

function user::info::fullname() {
  /usr/bin/id -F "$libsMacUser"
}