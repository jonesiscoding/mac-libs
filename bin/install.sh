#!/bin/bash

## region ############################################## Destination

# Allow setting of destination via prefix, verify that it's writable
[ -z "$MACLIBS_PREFIX" ] && MACLIBS_PREFIX="/usr/local/sbin"
if [ ! -w "$MACLIBS_PREFIX" ]; then
  userDir=$(/usr/bin/dscl . -read /Users/"$USER" NFSHomeDirectory 2>/dev/null | /usr/bin/awk -F ': ' '{print $2}')
  if [ -z "$userDir" ] && [ -d "/Users/$USER/Desktop" ]; then
    userDir="/Users/$USER/Desktop"
  fi
  MACLIBS_PREFIX="$userDir/.local/sbin"
fi
destDir="${MACLIBS_PREFIX}/lib/mac-libs"

## endregion ########################################### End Destination

## region ############################################## Main Code

installed=""
if [ -d "$destDir" ]; then
  if [ -f "$destDir/.version" ]; then
    installed=$(cat "$destDir/.version")
    if [ "$1" == "--replace" ]; then
      installed=""
      rm -R "$destDir"
      mkdir -p "$destDir" || exit 1
    fi
  fi
else
  mkdir -p "$destDir" || exit 1
fi

repoUrl="https://github.com/jonesiscoding/mac-libs/releases/latest"
effectiveUrl=$(curl -Ls -o /dev/null -I -w '%{url_effective}' "$repoUrl")
tag=$(echo "$effectiveUrl" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
if [ -n "$tag" ]; then
  # Exit successfully if same version
  [ "$tag" == "$installed" ] && exit 0
  dlUrl="https://github.com/jonesiscoding/mac-libs/archive/refs/tags/${tag}.zip"
  repoFile=$(basename "$dlUrl")
  tmpDir="/private/tmp/mac-libs/${tag}"
  [ -d "$tmpDir" ] && rm -R "$tmpDir"
  if mkdir -p "$tmpDir"; then
    if curl -Ls -o "$tmpDir/$repoFile" "$dlUrl"; then
      cd "$tmpDir" || exit 1
      if unzip -qq "$tmpDir/$repoFile"; then
        rm "$tmpDir/$repoFile"
        [ -d "$tmpDir/bin" ] && rm -R "${tmpDir:?}/bin"
        if cp -R "$tmpDir/mac-libs-${tag//v/}/" "$destDir/"; then
          rm -R "$tmpDir"
          # Success - Exit Gracefully
          exit 0
        fi
      fi
    fi
  fi
fi

# All Paths that lead here indicate we couldn't install
exit 1

## endregion ########################################### End Main Code
