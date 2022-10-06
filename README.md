# automate-tasks

Scripts to automate miscellaneous daily desktop tasks.

| Script | Language | Description |
| --- | --- | --- |
| `back2tar` | **bash** | Backup a mounted filesystem to a tarball. Script looks for a file (back2tar-exc.txt) with list of excluded dir's |
| `tar2part` | **bash** | Restore a mounted filesystem from a tarball. |
| `clonesite` | **bash** | Clone an entire website, designated by a *\<uri\>*, avoiding out-of-domain links. |
| `headerchk` | **bash** | A mass HTTP header check taking _urls_ from a file. |
| `net-test` | **bash** | Test your internet connectivity status, designated by a mass HTTP header check. |
| `osinfo` | **bash** | script to list information about running OS. |
| `sysinf` | **bash** | List a system's information. (dependency: `tlp`) |
| `picotts` | **sh** | Play Text-to-Speech for some text. (dependency: `libttspico-utils`) |
| `picotts-sel` | **sh** | Play TTS for text selection. (dependency: `picotts`) |
| `reader` | **sh** | Feed reader ETL script. (dependency: `feed_uri`, `filter`) |
| `rssreader` | sh |  |
| `filter` | **sh** | Filter script for the Transform stage of the reader. (dependency: `sed`) |
| `feed_parser.sh` | **sh** | Script to parse the feeds stored by reader. Originally written for conky config. (dependency: `sed`) |
| `themecli.sh` | **sh** | Automation script to switch terminal & vim themes. (dependency: `state.conf`, env var `CLI_CONF`) |
| `ytdl-list` | bash | Download a YouTube playlist using `youtube-dl` to a directory |

