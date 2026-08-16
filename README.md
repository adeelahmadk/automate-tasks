# automate-tasks

Scripts to automate miscellaneous daily desktop tasks.

**System Administration Tasks**

| Script | Language | Category | Description |
| --- | --- | --- | --- |
| `back2tar` | **bash** | Filesystem | Backup a mounted filesystem to a tarball. Script looks for a file (back2tar-exc.txt) with list of excluded dir's |
| `tar2part` | **bash** | Filesystem | Restore a mounted filesystem from a tarball. |
| `headerchk` | **bash** | Network | A mass HTTP header check taking _urls_ from a file. |
| `net-test` | **bash** | Network | Test your internet connectivity status, designated by a mass HTTP header check. |
| `osinfo` | **bash** | System | script to list information about running OS. |
| `sysinf` | **bash** | System | List a system's information. (dependency: `tlp`) |
| `picotts` | **sh** | Desktop | Play Text-to-Speech for some text. (dependency: `libttspico-utils`) |
| `picotts-sel` | **sh** | Desktop | Play TTS for text selection. (dependency: `picotts`) |
| `pkgreport` | bash | Package Management | Generate an HTML report for a list of packages in a file (or stdin). |
| `themecli.sh` | **sh** | Configuration | Automation script to switch terminal & vim themes. (dependency: `state.conf`, env var `CLI_CONF`) |
| [`upgrade_golang`](./shell/system/pkgman/upgrade_golang.sh) | **bash** | Package Management | Install/upgrade Golang |
| [`uninstall_python`](./shell/system/pkgman/uninstall_python.sh) | **bash** | Package Management | Uninstall Python installed from source |
| [`updchk_calibre.py`](./shell/system/pkgman/updchk_calibre.py) | **Python** | Package Management | Check if an update is available for calibre |
| [`upgrade_calibre.py`](./shell/system/pkgman/upgrade_calibre.py) | **Python** | Package Management | Check for calibre update and upgrade if user chooses to.  |
| [lsdup.sh](./shell/system/lsdup.sh) | bash | Filesystem | List duplicate files |

**Utility Scripts**

| Script | Language | Category | Description |
| --- | --- | --- | --- |
| `clonesite` | **bash** | Network | Clone an entire website, designated by a *\<uri\>*, avoiding out-of-domain links. |
| [`reader`](system/reader) | **sh** | Network, Data | Feed reader ETL script. Dependency: `curl`, `awk`, `sed`, [`W3C HTML and XML manipulation utilities`](https://www.w3.org/Tools/HTML-XML-utils/README) and `GNU coreutils` (Companion scripts: `filter`, `feed_parser.sh`) |
| `filter` | **sh** | Text Processing, Data | Filter script for the Transform stage of the reader. (dependency: `sed`) |
| `feed_parser.sh` | **sh** | Text Processing, Data | Script to parse the feeds stored by reader. Originally written for `conky` configuration. (dependency: `sed`) |
| [`rssreader`](system/rssreader) | sh | Network, Text Processing, Data | Redesigned Feed reader ETL script. Dependency: `curl`, `awk`, `sed`, [`W3C HTML and XML manipulation utilities`](https://www.w3.org/Tools/HTML-XML-utils/README) and `GNU coreutils` (Companion script: `parsefeed.sh`) |
| [`cb_u2t`](./system/cb_u2t) | bash | Desktop | Converts a url on the clipboard to a Title string on clipboard |
| [`cb_u2m`](./system/cb_u2m) | bash | Desktop | Converts a url on the clipboard to a markdown link on clipboard |
| [`cex`](./shell/utils/cex) | bash | API Client, Utility | Get exchange rate or convert an amount |

**[Multimedia Tasks](./system/multimedia/README.md)**

Scripts to automate tasks on multimedia files.

| Script | Language | Category | Description |
| --- | --- | --- | --- |
| `ytdl-list` | bash | Network, Media | Download a YouTube playlist using `youtube-dl` to a directory |
| `ytdlp-list` | bash | Network, Media | Download a YouTube playlist using `yt-dlp` to a directory |
| [`img_orient.sh`](./shell/multimedia/img_orient.sh) | bash | Multimedia | batch update orientation of photos (single dep.). |
| [`img_orientx.sh`](./shell/multimedia/img_orientx.sh) | bash | Multimedia | batch update orientation of photos efficiently. |
| [`img_orient_progress.sh`](./shell/multimedia/img_orient_progress.sh) | bash | Multimedia | batch process of photo metadata (orientation) with progress bar. |

**Development Tasks**

| Script                                                       | Language | Category | Description                                                  |
| ------------------------------------------------------------ | -------- | -------- | ------------------------------------------------------------ |
| [`mysql-drop-all-tables.sh`](dev/mysql/mysql-drop-all-tables.sh) | bash     | Database | Drop all tables in a MySQL database. Useful for resetting development DBs. |
| [`mysql-setup-db-user.sh`](./dev/mysql/mysql-setup-db-user.sh) | bash     | Database | Create a new DB and a user with full access to it.           |
| [`run-container.sh`](./dev/docker/run-container.sh)          | bash     | Docker   | Build an image and start a container.                        |


**Linux Kernel Development**

| Script                                              | Language | Category | Description                                                  |
| --------------------------------------------------- | -------- | -------- | ------------------------------------------------------------ |
| [`busyboxx_native.sh`](./kernel/busyboxx_native.sh) | bash     | OS       | Download Linux kernel and busybox. Build a minimal distro, and boot it in QEmu. |
| [`busyboxx_arm.sh`](./kernel/busyboxx_arm.sh)       | bash     | OS       | Download cross compiler toolchain, Linux kernel, and busybox. Build a minimal distro for ARM, and boot it in QEmu. |
