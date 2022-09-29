#!/bin/bash

function updates::update::field() {
  local jsFunc updateJson fieldName

  updateJson="$1"
  fieldName="$2"

  read -r -d '' jsFunc <<EOF
  function run() {
    const update = JSON.parse(\`$updateJson\`);
    if(update.hasOwnProperty('$fieldName')) {
      return update['$fieldName']
    }

    return null
  }
EOF

  /usr/bin/osascript -l "JavaScript" <<< "${jsFunc}"
}