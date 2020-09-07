#!/bin/bash

hasTerm=true

termAppDisown=false

a=""

#quiet=true

qExit=false

running=true
dir=$(pwd)

term=kitty
shell=bash

helpMsg="rofiles options:\n -h : show options\n -a : show hidden files\n -e : open terminal apps in seperate terminal\n -d : with -e option, terminal apps are detached (termapp params & disown)\n -t : with -e option, what terminal emulator to use for terminal apps\n -s : shell (bash,zsh,dash,etc) to use for the 'shell' menu option\n -q : escape key on main menu exits the program"

while [ -n "$1" ]; do
	case "$1" in
		-e) hasTerm=false ;;
		-h) echo -e $helpMsg;exit ;;
		-d) termAppDisown=true;;
		-t) term="$2";;
		-s) shell="$2";;
		-a) a="-A";;
		-q) qExit=true;;
	esac
	shift
done

#qExit=true

mmOptions="navigate,run_sh,xdg_open,nano,gedit,rofi_view_file,shell,exit"
mmPlanned="copy,move"

numberline() {
	c=1;
    if (( ${#} == 0 )) ; then
        while read -r line ; do
            echo "$c"_"${line}"
            c=$((c+1))
        done
    fi
}

function termapp {
	if [ $hasTerm = true ];then
		$1 $2
	else
		if [ $termAppDisown = true ];then
			$term $1 $2 & disown
		else
			$term $1 $2
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
aStr=""

while [ $running = true ];do
	if [ "$a" = "-A" ];then
		aStr="hide_hidden_files"
	else
		aStr="show_hidden_files"
	fi
 	mm=$(echo $mmOptions,$aStr | tr ',' '\n' | numberline | rofi -i -dmenu -p "main_menu $a $(pwd)" | sed 's/^..//')
 	if [ -z "$mm" ];then
 		if [ $qExit = true ];then
			running=false
		fi
 	elif [ "$mm" = navigate ];then
 		while true; do
			dir=$( ( echo .. && ls $a 2>/dev/null -p | grep / | cut -f1 -d'/') | rofi -i -dmenu -p "navigate $a $(pwd)")
			if [ -z "$dir" ];then
				break
			fi
			eval cd "\""$dir"\""
		done
	elif [ "$mm" = run_sh ];then
		f=$( ls $a -l | grep ^-..x..x..x.*\.sh$ | rev | cut -d ' ' -f1 | rev | rofi -dmenu -p "run_sh $a $(pwd)" )
		if [ -n "$f" ]; then
			./$f
		fi
	elif [ "$mm" = xdg_open ];then
		f=$( (echo . && ls $a) | rofi -i -dmenu -p "xdg_open $a $(pwd)" )
		if [ -n "$f" ]; then
			eval xdg-open 2>/dev/null "\""$f"\"" > /dev/null & disown
		fi
	elif [ "$mm" = nano ];then
		f=$(ls $a -p | grep -v / | rofi -i -dmenu -p "nano $a $(pwd)")
		if [ -n "$f" ]; then
			termapp nano $f
		fi
	elif [ "$mm" = gedit ];then
		f=$(ls $a -p | grep -v / | rofi -i -dmenu -p "gedit $a $(pwd)")
		if [ -n "$f" ]; then
			gedit $f > /dev/null & disown
		fi
	elif [ "$mm" = rofi_view_file ];then
		f=$(ls $a -p | grep -v / | rofi -i -dmenu -p "rofi_view_file $a $(pwd)")
		if [ -n "$f" ]; then
			cat $f | rofi -i -dmenu -p "view_file $a $(pwd)/$f"
		fi
	elif [ "$mm" = shell ];then
		termapp $shell
	elif [ "$mm" = show_hidden_files ];then
		a="-A"
	elif [ "$mm" = hide_hidden_files ];then
		a=""
	elif [ "$mm" = exit ];then
		running=false
	else
		echo main menu
	fi
done
