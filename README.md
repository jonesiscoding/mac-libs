# mac-libs
A library of common reusable bash functions, with 0 non-native dependencies, to assist in the management of macOS computers.

While all the functionality can be replicated within macOS itself, there are two advantages to using the library:

* Less code to touch if the method to do something in macOS changes.
* Less remembering (or searching for) obscure macOS utilities, flags, and filters. 

### Usage

* Source one of the stub files below, depending on how your script to be run.
* Source each of the function files that contain the functions you want to use.  
  * Internal dependencies are taken care of automatically.
  * See individual function files for arguments & additional notes.
* If using `jamf.sh` or `root.sh`, initialize the user with one of the `user::init` functions.

#### Stub Files

| File      | For                                             | Effects                                                                 |
|-----------|-------------------------------------------------|-------------------------------------------------------------------------|
| `core.sh` | Scripts run as shell user                       | User functions automatically run on $USER                               |
| `root.sh` | Scripts run as root, affecting a different user | Must call `user::init <username>` or `user::init::console` to set user. |
| `jamf.sh` | Scripts run via Jamf Pro | * User functions automaticaly run on username supplied by Jamf as $3.<br>* `$jamfUser` automatically set to `$3`<br>* `$jamfHost` automatically set to `$2<br>* `$jamfRoot` automatically set to `$1`<br>* All arguments shifted, $4 becomes $1 |


### User Functions

All functions based on user information in this library run on a specific _reference user_, based on the chosen sub file (see above) and the `user::init` function used.

### Optional Installer Script

If your script is running as root, you can silently install the library using the 1-liner below:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/jonesiscoding/mac-libs/HEAD/bin/install.sh)" || exit 1

The installer will check this repo for the most recent release, then if needed, download & extract to `/usr/local/sbin/lib/mac-libs/`.