#!/bin/bash

# This is a bash script helper.  It provides docstring help command.
# 
# Your script should source this script:
#
#   shellcheck disable=SC1091
#   source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/helpme.sh"
#
# and then define some command functions with a help docstring as a
# prefacing comment like:
#
#   # myfunc [options] <arg>
#   #
#   # This function does ....
#   cmd_myfunc () {
#     # ...
#   }
#
# Finish the script with:
#
#   helpme "${BASH_SOURCE[0]}" "$@"
#
# Additional guidance:
#
# The main script program may provide a docstring in comments which
# starts with the name of the script.  For example, if the script file
# is named "myscript.sh", a block such as the following will provide
# general docstring:
#
#   # myscript [-h|--help|help] | [cmds [options]]
#   #
#   # This program will flarg the foo and make cromulent the bar.
#
# Ending with an empty line terminates this docstring.
#
# If the command takes no arguments the comment MUST HAVE A SPACE
# following the command name:
#
#  # mycmd
#  #      ^ space
#  # This function takes no arguments
#  cmd_mycmd () {
#    # ...
#  }
#
# See also the helpme_* functions providing generic utilities that may
# help you write your scripts.

debug_output="no"


# debug [msg]
#
# Print msg to stderr if debugging is on.
debug () {
    if [ "$debug_output" == "no" ] ; then
        return
    fi
    echo "$(date +'%F %T.%N') $*" 1>&2
}


# info [msg]
#
# Print msg to stderr 
info () {
    echo "$*" 1>&2
}


helpme_log="${XDG_CACHE_HOME:-$HOME/.cache}/${helpme_name:-helpme}/log"
mkdir -p "$(dirname "$helpme_log")"

# log [msg]
#
# Print message to logfile
log () {
    echo "$(date +'%F %T.%N') $*" >> "$helpme_log" 2>&1
}


# die [msg]
#
# Print error msg and exit.
die () {
    echo "ERROR: $*" 1>&2
    exit 1
}

help_main () {
    local script="$1" ; shift
    local base
    base="$(basename "$script")"
    local name="${base%.*}"

    awk "/^# $name /{flag=1}/^$/{flag=0}flag" < "$script" | sed -e 's/^# //g' -e 's/^#//g' 
}

help_one () {
    local script="$1" ; shift
    local cmd="$1" ; shift
    debug "thecmd=|$cmd|"

    echo -n " \$ $(basename "$script") "
    awk "/^# $cmd /{flag=1}/^cmd_$cmd /{flag=0}flag" < "$script" | sed -e 's/^# //g' -e 's/^#//g' 
    echo
}

help_all () {
    local script="$1" ; shift

    help_main "$script"
    
    echo -e "\nThe commands for $(basename "$script"):\n"

    grep ^cmd_ "$script" | sed -n 's/^cmd_\(\S*\) .*/\1/p' | while read -r func
    do
        func="${func#*_}"
        func="${func% *}"
        help_one "$script" "$func"
    done
}

help () {
    local script="$1" ; shift
    if [ -z "$1" ] ; then
        help_all "$script"
    else
        help_one "$script" "$1"
    fi
}

# helpme_basedir <type>
#
# Return the base directory of the given type.  This first tires XDG_*
# env vars given in:
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
helpme_basedir () {
    local kind="${1:-data}"
    local KIND="${kind^^}"
    local xdgvar="XDG_${KIND}_HOME"
    local xdgval="${!xdgvar}"
    if [[ -z "$xdgval" ]] ; then
        echo -n "$xdgval"
    fi
    case $KIND in
        DATA)
            echo -n "$HOME/.local/share"
            return;;
        CONFIG)
            echo -n "$HOME/.config"
            return;;
        STATE)
            echo -n "$HOME/.local/state"
            return;;
        CACHE)
            echo -n "$HOME/.cache"
            return;;
        *) die "Unknown base dir kind: \"$kind\"" ;;
    esac
    die "Unknown base dir kind: \"$kind\"" 
}

helpme () {
    local script="$1"; shift
    if [ ! -f "$script" ] ; then
        echo "helpme requires script file as first arg"
        exit 1
    fi

    local -a args
    while [[ $# -gt 0 ]] ; do
        case "$1" in
            -h|--help|help) want_help="yes"; shift ;;
            --debug) debug_output="yes"; shift ;;
            *) args+=( "$1" ) ; shift ;;
        esac
    done

    if [ "$want_help" = "yes" ] || [ -z "${args[0]}" ] ; then
        help "$script" "${args[0]}"
        return
    fi
                
    cmd="${args[0]}"
    "cmd_$cmd" "${args[@]:1}"
}


