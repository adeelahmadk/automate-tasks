# Change CLI Theme

Those who work mostly in terminal environments (e.g. software devs, system admins, etc.) may have to work in different levels of brightness: day/night, outdoor/indoor. Hence, in order to view screens with clear visibility an appropriate theme (light/dark) should be applied to a the applications in use. Most Unix/Linux terminals and CLI apps come with an ability to change theme. However, changing theme for every single app manually is a hassle tech folks seldom like to deal with. A script to automate this task can help circumvent this hassle. This simple script helps toggle/set CLI environment theme between two choices.

The script depends upon a config file (`state.conf`) with its location `export`ed in the shell environment from `.bashrc` or `.profile`. e.g.

```sh
export CLI_CONF="$HOME/.config/term/state.conf"
```

Then place the script `themecli` in your `PATH` (e.g. `~/.local/bin` or `~/bin`) and make it executable. Now use it from terminal as

```sh
# toggle theme
themecli -t

# set theme (dark)
themecli -s d
```

or set a shortcut key combination in your desktop environment settings. Cheers!!!