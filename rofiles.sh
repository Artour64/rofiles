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
dmenu="rofi -i -dmenu"
#quiet=true

mmOptions="navigate/open,navigate,run_sh,xdg_open,nano,gedit,rofi_view_file,shell,exit,select_files_menu"

submenus="select_files_menu"
submenu_select_files_menu="Menu options for this menu and functionality coming in future update. Go back with escape key or \"go_back\" menu option"
#mmPlanned="copy,move"

helpMsg="\
Configs override defaults, options override configs

For options that are boolean (true/false),
use capital letter to do the opposite
e.g. -a shows hidden files, -A hides hidden files, i.e. opposites

For options that require you to specify something,
use the argument after to specify
e.g. -s zsh will set shell to zsh

rofiles options:
 -h : show the help text and exit
 -a : show hidden files
 -e : open terminal apps in seperate terminal
 -d : with -e option, terminal apps are detached (termapp params & disown)
 -q : escape key on main menu exits the program
 -t : with -e option, what terminal emulator to use for terminal apps
 -s : shell (bash,zsh,dash,etc) to use for the 'shell' menu option\
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

loadconfig
#submenus="$submenus,select_files_menu"

while [ -n "$1" ]; do
	case "$1" in
		-h) echo "$helpMsg";exit ;;
		
		-e) hasTerm=false ;;
		-E) hasTerm=true ;;
		
		-d) termAppDisown=true;;
		-D) termAppDisown=false;;
		
		-a) a="-A";;
		-A) a="";;
		
		-q) qExit=true;;
		-Q) qExit=false;;
		
		-t) term="$2";;
		-s) shell="$2";;
	esac
	shift
done

#qExit=true

submenu(){
	local mm="q"
	while [ -n "$mm" -a "$mm" != "exit" -a "$mm" != "go_back" ]; do
		mm=$(eval echo $"submenu_$1",go_back | tr ',' '\n' | numberline | menusel "$1" | sed 's/^[0-9]*_//')
		menuif $mm ""
	done
}

menusel(){
	if [ $p = true ]; then
		(while read -r x; do echo "$x"; done) | $dmenu -p "$@ $a $dir"
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

aStr=""
dir=$(pwd)

while [ $running = true ];do
	if [ "$a" = "-A" ];then
		aStr="hide_hidden_files"
	else
		aStr="show_hidden_files"
	fi
 	m=$(echo $mmOptions,$aStr | tr ',' '\n' | numberline | menusel "main_menu" | sed 's/^[0-9]*_//')
	menuif $m
done

