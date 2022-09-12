# mac-libs
A library of common reusable bash functions to assist in the management of macOS computers.

### Usage

For the simplest usage this library, first "source" one of the bootstrap scripts.

#### For Scripts Run as Root

For scripts where the functionality is designed to be run as root or other admin user, but should affect the current console user, or a another user passed via MDM, you should source `_root.sh`.

#### For Scripts Run as User

For all other scripts (where script functionality is intended to affect the user running the script) source `_core.sh`