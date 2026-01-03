# automate-tasks

Scripts to automate miscellaneous daily desktop tasks.

| Script | Language | Category | Description |
| --- | --- | --- | --- |
| `back2tar` | **bash** | Filesystem | Backup a mounted filesystem to a tarball. Script looks for a file (back2tar-exc.txt) with list of excluded dir's |
| `tar2part` | **bash** | Filesystem | Restore a mounted filesystem from a tarball. |
| `clonesite` | **bash** | Network | Clone an entire website, designated by a *\<uri\>*, avoiding out-of-domain links. |
| `headerchk` | **bash** | Network | A mass HTTP header check taking _urls_ from a file. |
| `net-test` | **bash** | Network | Test your internet connectivity status, designated by a mass HTTP header check. |
| `osinfo` | **bash** | System | script to list information about running OS. |
| `sysinf` | **bash** | System | List a system's information. (dependency: `tlp`) |
| `picotts` | **sh** | Desktop | Play Text-to-Speech for some text. (dependency: `libttspico-utils`) |
| `picotts-sel` | **sh** | Desktop | Play TTS for text selection. (dependency: `picotts`) |
| [`reader`](shell/reader) | **sh** | Network, Data | Feed reader ETL script. Dependency: `curl`, `awk`, `sed`, [`W3C HTML and XML manipulation utilities`](https://www.w3.org/Tools/HTML-XML-utils/README) and `GNU coreutils` (Companion scripts: `filter`, `feed_parser.sh`) |
| `filter` | **sh** | Text Processing, Data | Filter script for the Transform stage of the reader. (dependency: `sed`) |
| `feed_parser.sh` | **sh** | Text Processing, Data | Script to parse the feeds stored by reader. Originally written for `conky` configuration. (dependency: `sed`) |
| [`rssreader`](shell/rssreader) | sh | Network, Text Processing, Data | Redesigned Feed reader ETL script. Dependency: `curl`, `awk`, `sed`, [`W3C HTML and XML manipulation utilities`](https://www.w3.org/Tools/HTML-XML-utils/README) and `GNU coreutils` (Companion script: `parsefeed.sh`) |
| `pkgreport` | bash | Package Management | Generate an HTML report for a list of packages in a file (or stdin). |
| `themecli.sh` | **sh** | Configuration | Automation script to switch terminal & vim themes. (dependency: `state.conf`, env var `CLI_CONF`) |
| `ytdl-list` | bash | Network, Media | Download a YouTube playlist using `youtube-dl` to a directory |
| `ytdlp-list` | bash | Network, Media | Download a YouTube playlist using `yt-dlp` to a directory |
| `update_golang` | bash | Package Management | Install/upgrade Golang |
| [`mysql-drop-all-tables.sh`](dev/mysql/mysql-drop-all-tables.sh) | bash | Database | Drop all tables in a MySQL database. Useful for resetting development DBs. |
| [`mysql-setup-db-user.sh`](./dev/mysql/mysql-setup-db-user.sh) | bash | Database | Create a new DB and a user with full access to it. |
| [`run-container.sh`](./dev/docker/run-container.sh) | bash | Docker | Build an image and start a container. |

