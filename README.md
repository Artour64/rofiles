# Rofiles
a file manager written in dash shell script and uses rofi/dmenu for most of it's interface


## main menu options
 - navigate/open  select a file or directory(ends with /) from the rofi/dmenu. If selected is a file, xdg-open (default application). If it is a directory, go to that directory. The rofi/dmenu selection repeated in a loop that can be escaped by pressing the escape key.
 - navigate  select a directoy from the rofi/dmenu to go to that directory. The rofi/dmenu selection repeated in a loop that can be escaped by pressing the escape key.
 - run_sh  select a shell script with suffix .sh with execute permissions to run it.
 - xdg_open  select a file to open it with default application (xdg-open)
 - nano  select a file to open it with nano
 - gedit  select a file to open it with gedit
 - rofi_view_file  select a file to view it in rofi/dmenu
 - shell  use terminal shell. To go back to the program, exit the shell
 - exit  exit the program cleanly
 - show/hide_hidden_files toggle option to show hidden files

## Options
For options that are boolean (true/false), use capital letter to do the opposite   
e.g. -a   shows hidden files, -A   hides hidden files, i.e. opposites

For options that require you to specify something, use the argument after to specify   
e.g. -s zsh   will set shell to zsh

### rofiles options:
 - -h : show the help text and exit
 - -a : show hidden files
 - -e : open terminal apps in seperate terminal
 - -d : with -e option, terminal apps are detached (termapp params & disown)
 - -q : escape key on main menu exits the program
 - -t : with -e option, what terminal emulator to use for terminal apps
 - -s : shell (bash,zsh,dash,etc) to use for the 'shell' menu option

## Config
default config-directory: ~/.config/rofiles  
#### config-directory/config.sh
This where you override default values. It is source run as a shell script ( . ~/.config/rofiles/config.sh ). Because of this, if you define a function here, it will be available for the program and your custom functions. The script is ran after defaults are defined in the program so you can access them (e.g. mmOptions=$mmOptions,mycustomfun.sh)   
#### config-directory/help.txt
contains the help message that displays when running this program with the -h option. If the file does not exist, the default help message will be displayed.   
#### config-directory/functions
This a directory that contains custom functions that you can define. More on that later in this readme.

### Config Variables
The variables that can be set in config-directory/config.sh  
Format: variable (default/other-options) description  
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

### Custom Functions
Custom functions are source run ( . yourfun.sh )   
Because of this, they must be written in dash. To go around this, you can change the shebang of this program but this will  likely make the program slower.  
Also, the custom functions can access and change variables in the program. It can also use functions that are present in the program.
The program attempts to call a custom function if the selected option in the main menu does not match any option defined in the program if-structure.   
If you made a custom function, for it to be displayed in the main menu, make sure to include it in the mmOptions varaible (use config.sh or edit source code)

### Want to use actual dmenu instead of rofi
add this to your config.sh:  
dmenu=dmenu

## Planned Features
 - delete files
 - move files
 - copy and paste files
 - manage file permissions
 - select/deselect multiple files (into a clipboard of sorts) to later open them or do the operations above
 - rename files
 - create files and directories
 - an in terminal selection program as alternative to rofi or dmenu (any recomendations?)
 - start program at specified directory
 - config dump option
 - make installable
 - rofi icons
 
 ## Misc
 Feedback and suggestions are appreciated.
