#!/bin/dash

configs=~/.config/rofiles

hasTerm=true
termAppDisown=false
a=""
qExit=false
running=true
term=kitty
shell=bash
p=true
dmenu="rofi -i -dmenu"
#quiet=true

helpMsg="
configs override defaults, options override configs\n\n

for options that are boolean (true/false),\n\
use capital letter to do the opposite\n\
e.g. -a shows hidden files, -A hides hidden files, i.e. opposites\n\n\
rofiles options:\n
 -h : show the help text and exit\n
 -a : show hidden files\n
 -e : open terminal apps in seperate terminal\n
 -d : with -e option, terminal apps are detached (termapp params & disown)\n
 -q : escape key on main menu exits the program\n
 -t : with -e option, what terminal emulator to use for terminal apps\n
 -s : shell (bash,zsh,dash,etc) to use for the 'shell' menu option\n
"

mmOptions="navigate,run_sh,xdg_open,nano,gedit,rofi_view_file,shell,exit"
mmPlanned="copy,move"

if test -d "$configs"; then
	if test -f "$configs/config.sh"; then
		. $configs/config.sh
	fi
fi

while [ -n "$1" ]; do
	case "$1" in
		-h) echo -e $helpMsg;exit ;;
		
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

menusel(){
	if [ $p = true ]; then
		(while read -r x; do echo $x; done) | $dmenu -p "$@ $a $dir"
	else
		(while read -r x; do echo $x; done) | $dmenu
	fi
}

numberline() {
	c=1;
    if (( ${#} == 0 )) ; then
        while read -r line ; do
            echo "$c"_"${line}"
            c=$((c+1))
        done
    fi
}

termapp() {
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
dir=$(pwd)
while [ $running = true ];do
	if [ "$a" = "-A" ];then
		aStr="hide_hidden_files"
	else
		aStr="show_hidden_files"
	fi
 	mm=$(echo $mmOptions,$aStr | tr ',' '\n' | numberline | menusel "main_menu" | sed 's/^..//')
 	if [ -z "$mm" ];then
 		if [ $qExit = true ];then
			running=false
		fi
 	elif [ "$mm" = navigate ];then
 		while true; do
			dir=$( ( echo .. && ls $a 2>/dev/null -p | grep / | cut -f1 -d'/') | menusel "navigate")
			if [ -z "$dir" ];then
				dir=$(pwd)
				break
			fi
			eval cd "\""$dir"\""
			if [ $dir = ".." ];then
				dir=$(pwd)
			fi
		done
	elif [ "$mm" = run_sh ];then
		f=$( ls $a -l | grep ^-..x..x..x.*\.sh$ | rev | cut -d ' ' -f1 | rev | menusel "run_sh" )
		if [ -n "$f" ]; then
			./$f
		fi
		dir=$(pwd)
	elif [ "$mm" = xdg_open ];then
		f=$( (echo . && ls $a) | menusel "xdg_open" )
		if [ -n "$f" ]; then
			eval xdg-open 2>/dev/null "\""$f"\"" > /dev/null & disown
		fi
	elif [ "$mm" = nano ];then
		f=$(ls $a -p | grep -v / | menusel "nano")
		if [ -n "$f" ]; then
			termapp nano $f
		fi
	elif [ "$mm" = gedit ];then
		f=$(ls $a -p | grep -v / | menusel "gedit")
		if [ -n "$f" ]; then
			gedit $f > /dev/null & disown
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
	else
		echo main menu
	fi
done
