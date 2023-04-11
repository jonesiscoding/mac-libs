#!/bin/bash

[ -z "$libsMacPathDuti" ] && libsMacPathDuti="/usr/local/bin/duti"
if [[ $(type -t "apps::acrobat::path") != function ]]; then
  # shellcheck source=./path.sh disable=SC2164
  source "$( cd "$(/usr/bin/dirname "${BASH_SOURCE[0]}")" ; /bin/pwd -P )/path.sh"
fi

# /*!
#   Public: Displays the path to the current handler of PDF files for the OS.
#
#   Example:
#     pdfHandler=$(apps::acrobat::getPdfHandler)
#
#   Dependency:
#     duti (https://github.com/moretension/duti)
# */
function apps::acrobat::getPdfHandler() {
  "$libsMacPathDuti" -x "com.adobe.pdf" | grep ".app" | tail -1
}

# /*!
#   Public: Sets the PDF handler for the OS to the given edition of Adobe
#   Acrobat, if installed.
#
#   Example:
#     apps::acrobat::setPdfHandler DC
#
#   Dependency:
#     duti (https://github.com/moretension/duti)
#
#   $1    The edition of Adobe Acrobat to use for PDF files, if installed.
# */
function apps::acrobat::setPdfHandler() {
  local edition aPath bundleId

  edition="$1"
  aPath=$(apps::acrobat::path "$edition")
  bundleId=$(/usr/bin/mdls -n kMDItemCFBundleIdentifier -r "$aPath")

  if "$libsMacPathDuti" -s "$bundleId" "com.adobe.pdf" all > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}