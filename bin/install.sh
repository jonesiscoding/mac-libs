#!/bin/bash

installed=""
isReplace=false
destDir="/usr/local/sbin/mac-libs"
if [ -d "$destDir" ]; then
  if [ -f "/usr/local/sbin/mac-libs/.version" ]; then
    installed=$(cat "$destDir/.tag")
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
  tmpDir="/tmp/mac-libs/${tag}"
  [ -d "$tmpDir" ] && rm -R "$tmpDir"
  if mkdir -p "$tmpDir"; then
    if curl -Ls -o "$tmpDir/$repoFile" "$dlUrl"; then
      cd "$tmpDir" || exit 1
      if unzip -qq "$tmpDir/$repoFile"; then
        rm "$tmpDir/$repoFile"
        [ -d "$tmpDir/bin" ] && rm -R "${tmpDir:?}/bin"
        if cp -R "$tmpDir/mac-libs-${tag//v/}/" "/usr/local/sbin/lib/mac-libs/"; then
          rm -R "$tmpDir"
          exit 0
        fi
      fi
    fi
  fi
fi

exit 1