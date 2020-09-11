# Rofiles
a file manager written in dash shell script and uses rofi/dmenu for most of it's interface

## Want to use actual dmenu instead of rofi
add this to the config.sh:
dmenu=dmenu

## config
default config-directory: ~/.config/rofiles
config-directory/config.sh is where you override default values. It is run as a shell script.

### config variables
the variables that can be set in config-directory/config.sh
format: variable (default/other-options) description
 - hasTerm (true/false) false to open a new terminal emulator when running a terminal app
 - termAppDisown (false/true) true to detach/disown new terminal emulators opened by this program
 - a (""/"-A") "-A" to show hidden files
 - qExit (false/true) true to exit program when pressing escape in main menu
 - running (true/false) probably shouldn't touch this, the program will exit immediately when it enters the main loop if it is not set to true
 - term (kitty/xterm/urxvt/gnome-terminal/"termcmd --options") what terminal emulator to use (if hasTerm=false)
 - shell (bash/zsh/fish/dash/sh) what shell to use when opening a shell (the program itself still uses dash)
 - p (true/false) true to display prompt in rofi/dmenu
 - dmenu ("rofi -i -dmenu" / "dmenu -my-options" / "rofi -my-options") the command (with options) that will be used for all of the menus, you may choose to use dmenu instead of rofi
 - mmOptions ("navigate/open,navigate,run_sh,xdg_open,nano,gedit,rofi_view_file,shell,exit") the options present in the main menu, separated by "," commas
 - helpMsg (it's too long, sorry) the message to display when running this program with the -h option

## main menu options
 - todo: readme this
