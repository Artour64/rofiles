#!/bin/dash
configs=~/.config/rofiles

hasTerm=true
termAppDisown=false
a=""
qExit=false
running=true
term=kitty
#term=x-terminal-emulator
shell=bash
p=true
promptOpt="-p"
dmenu="rofi -i -dmenu"
#quiet=true

mmOptions="fast_navigate,navigate/open,navigate,run_sh,xdg_open,nano,gedit,rofi_view_file,shell,select_files_menu,toggle_show_hidden_files,exit"

submenus="select_files_menu"
submenu_select_files_menu="Menu options for this menu and functionality coming in future update. Go back with escape key or \"go_back\" menu option"
#mmPlanned="copy,move"

helpMsg="\
Configs override defaults, options override configs

arguments: directory to start in (last specified)
e.g. rofiles.sh ~/Documents will start the program in the ~/Documents directory

For options that are boolean (true/false),
use capital letter to do the opposite
e.g. -a shows hidden files, -A hides hidden files, i.e. opposites
For the boolean multi-character options, appending \"-false\" will do the opposite
e.g. --show-hidden shows hidden files, --show-hidden-false hides hidden files, i.e. opposites

For options that require you to specify something,
use the argument after to specify
e.g. -s zsh will set shell to zsh

rofiles options:
 -h, --help : show the help text and exit
 -a, --show-hidden : show hidden files
 -e, --separate-terminal : open terminal apps in separate terminal
 -d, --detach-term : with -e option, terminal apps are detached (termapp params & disown)
 -q, --quick-exit : escape key on main menu exits the program
 -t, --term : with -e option, what terminal emulator to use for terminal apps
 -s, --shell : shell (bash,zsh,dash,etc) to use for the 'shell' menu option
 --start-script : run these commands on start (like config.sh). Overrides config.\
"

loadconfig(){
	if test -d "$configs"; then
		if test -f "$configs/help.txt"; then
			helpMsg=$(cat $configs/help.txt)
		fi
		if test -f "$configs/config.sh"; then
			. $configs/config.sh
		fi
	fi
}


#submenus="$submenus,select_files_menu"


#qExit=true

submenu(){
	local mm="q"
	while [ -n "$mm" -a "$mm" != "exit" -a "$mm" != "go_back" ]; do
		mm=$(eval echo $"submenu_$1",go_back | tr ',' '\n' | togglemenuopt | numberline | menusel "$1" | sed 's/^[0-9]*_//')
		menuif $mm ""
	done
}

menusel(){
	if [ $p = true ]; then
		(while read -r x; do echo "$x"; done) | $dmenu $promptOpt "$@ $a $dir"
	else
		(while read -r x; do echo "$x"; done) | $dmenu
	fi
}

numberline() {
	c=1;
    if [ "$#" = 0 ] ; then
        while read -r line ; do
            echo "$c"_"${line}"
            c=$((c+1))
        done
    fi
}

togglemenuopt(){
	if [ "$#" = 0 ] ; then
        while read -r line ; do
            if [ "$line" = "toggle_show_hidden_files" ];then
            	if [ "$a" = "-A" ];then
					echo "hide_hidden_files"
				else
					echo "show_hidden_files"
				fi
            else
            	echo "$line"
            fi
        done
    fi
}

termapp() {
	if [ "$hasTerm" = true ];then
		$1 $2
	else
		if [ "$termAppDisown" = true ];then
			nohup $term $1 $2 &
		else
			$term $1 $2
		fi
	fi
}

navopencmd(){
	while true; do
		f=$( (echo .. && ls $a 2>/dev/null -p) | menusel "navigate/open")
		if [ -z "$f" ];then
			dir=$(pwd)
			break
		elif test -d "$f"; then
			eval cd "\""$f"\""
		elif test -f "$f"; then
			eval nohup xdg-open 2>/dev/null "\""$f"\"" > /dev/null &
		fi
		dir=$(pwd)
	done
}

navigatecmd() {
	while true; do
		dir=$( (echo .. && ls $a 2>/dev/null -p | grep "/" | cut -f1 -d'/') | menusel "navigate")
		if [ -z "$dir" ];then
			dir=$(pwd)
			break
		fi
		eval cd "\""$dir"\""
		dir=$(pwd)
	done
}

fastnav(){
	if [ "$a" = "-A" ];then
		dir=$(find -type d "$@" | sed 's/^..//' | menusel "fast_navigate")
	else
		dir=$(find -not -path '*/\.*' -type d \( ! -iname ".*" \)| sed 's/^..//' | menusel "fast_navigate")
	fi
	if [ -z "$dir" ];then
		dir=$(pwd)
		break
	fi
	eval cd "\""$dir"\""
	dir=$(pwd)
}

customfun() {
	if test -d "$configs/functions"; then
		if test -f "$configs/functions/$mm"; then
			. $configs/functions/$mm
		fi
	fi
}

#function guiapp {
#	if [ $quiet = true ];then
#		$1 $2 > /dev/null & disown
#	else
#		$1 $2 & disown
#	fi
#}
menuif(){
	local mm=$1
 	if [ -z "$mm" ];then
 		if [ $qExit = true -a $# = 0 ];then
			running=false
		fi
	elif [ "$mm" = "fast_navigate" ];then
		fastnav
 	elif [ "$mm" = "navigate" ];then
 		navigatecmd
 	elif [ "$mm" = "navigate/open" ];then
 		navopencmd
	elif [ "$mm" = run_sh ];then
		f=$( ls $a -l | grep "^-..x..x..x.*\.sh$" | rev | cut -d ' ' -f1 | rev | menusel "run_sh" )
		if [ -n "$f" ]; then
			./$f
		fi
		dir=$(pwd)
	elif [ "$mm" = xdg_open ];then
		f=$( (echo . && ls $a) | menusel "xdg_open" )
		if [ -n "$f" ]; then
			eval nohup xdg-open 2>/dev/null "\""$f"\"" > /dev/null &
		fi
	elif [ "$mm" = nano ];then
		f=$(ls $a -p | grep -v / | menusel "nano")
		if [ -n "$f" ]; then
			termapp nano $f
		fi
	elif [ "$mm" = gedit ];then
		f=$(ls $a -p | grep -v / | menusel "gedit")
		if [ -n "$f" ]; then
			nohup gedit $f > /dev/null &
		fi
	elif [ "$mm" = rofi_view_file ];then
		f=$(ls $a -p | grep -v / | menusel "rofi_view_file")
		if [ -n "$f" ]; then
			cat $f | $dmenu -p "view_file $dir/$f"
		fi
	elif [ "$mm" = shell ];then
		termapp $shell
		dir=$(pwd)
	elif [ "$mm" = show_hidden_files ];then
		a="-A"
	elif [ "$mm" = hide_hidden_files ];then
		a=""
	elif [ "$mm" = exit ];then
		running=false
	elif [ "$(echo "$submenus" | tr ',' '\n' | grep -c "^$mm$")" = 1 ];then
		submenu "$mm"
	else
		customfun "$mm"
	fi
}

mainloop(){
	while [ $running = true ];do
		if [ "$a" = "-A" ];then
			aStr="hide_hidden_files"
		else
			aStr="show_hidden_files"
		fi
	 	m=$(echo $mmOptions | tr ',' '\n' | togglemenuopt | numberline | menusel "main_menu" | sed 's/^[0-9]*_//')
		menuif $m
	done
}


processparams(){
	while [ -n "$1" ]; do
		case "$1" in
			-h|--help) echo "$helpMsg";running=false;exit ;;
			
			-e|--separate-terminal) hasTerm=false ;;
			-E|--separate-terminal-false) hasTerm=true ;;
			
			-d|--detach-term) termAppDisown=true;;
			-D|--detach-term-false) termAppDisown=false;;
			
			-a|--show-hidden) a="-A";;
			-A|--show-hidden-false) a="";;
			
			-q|--quick-exit) qExit=true;;
			-Q|--quick-exit-false) qExit=false;;
			
			-t|--term) term="$2";shift;;
			-s|--shell) shell="$2";shift;;
			
			--start-script) eval $2;shift;;
			
			*) cd "$1";;
		esac
		shift
	done
}

loadconfig
processparams "$@"

aStr=""
dir=$(pwd)

mainloop


