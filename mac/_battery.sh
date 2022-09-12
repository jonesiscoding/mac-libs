#!/bin/bash

function mac::battery::percentage() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_charge_info.sppower_battery_state_of_charge'
}

function mac::battery::isFullyCharged() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_charge_info.sppower_battery_fully_charged'
}

function mac::battery::isCharging() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_charge_info.sppower_battery_is_charging'
}

function mac::battery::cycles() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_health_info.sppower_battery_cycle_count'
}

function mac::battery::getSerialNumber() {
  /usr/sbin/system_profiler SPPowerDataType battery -json | "$_libsMacBattery_JQ" '.SPPowerDataType[0].sppower_battery_model_info.sppower_battery_serial_number'
}

# Initialize library variables
if [ -z "$sourced_lib_mac_battery" ]; then
  # shellcheck disable=SC2034
  sourced_lib_mac_battery=0

  # Ensure JQ dependency
  dependency::assert "jq"
  _libsMacBattery_JQ=$(dependency::path jq)
fi




