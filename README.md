# mac-libs
A library of common reusable bash functions to assist in the management of macOS computers.

### Usage

1. Source `core.sh` using a relative path.  See note below for scripts designed to be run as root.
2. Source other modules as you see fit, based on your needs.  You may use the variable `$libsMacSourcePath` for the path to the library, if desired.

#### For Scripts Run as Root

For scripts where the functionality is designed to be run as root or other admin user, but should affect the current console user, or another user passed via MDM, you should source `root.sh` to ensure that the user functions are run for the correct user.

### User Reference

All functions based on user information in this library run on a specific _reference user_, identified at run time.

During normal usage, the reference user will the user running the script.

If sourcing `root.sh` to indicate that your script is intended to run as _root_, the reference user is auto-detected based on:

1. If the script is running via Jamf Pro, the reference user is taken from the Jamf Pro arguments.
2. The user currently logged into the GUI console.

### Jamf Setup

To properly use the Jamf functions for downloading or installing updates on an MDM enrolled machine, you must first configure a few things.  These steps are _only_ needed if using the update functionality in the `_jamf.sh` module.

1. Create a user in Jamf with the proper permissions, only allowing for access via the API.
2. Set up a configuration profile using the `resources/jamfProfile.json` schema.
3. Store that user's password in the keychain of each computer that will be running the script.  This may be automated in Jamf.

To store the password in the keychain as described in step two above:

`security add-generic-password -a "<username>" -s "MDM API" -w "<password>" -T /usr/bin/security /Library/Keychains/System.keychain`
  