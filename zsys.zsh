#!/bin/zsh
#
# zsh-sysadmin: Quickfast access to configuration files and logs
# https://github.com/daethorian/zsh-sysadmin.git
#
# Written by Lowe Thiderman (lowe.thiderman@gmail.com)
# Licensed under the MIT license.
#
# See the README for usage instructions.

# TODO:
# Configuration variables
#   Alias editor yesno
#   The different colors


# Find the db even if this file is a symbolic link
export FILEDB="$0:A:h/db/db.zsh"
source $FILEDB

for f in $0:A:h/core/*.zsh(n); do
    source $f
done
unset f

function zsys()
{
    if [[ "$1" != "commit" ]] && [[ -n "$FILEDB_DIRTY" ]]; then
        echo "You have changes to your zsys file database."
        print -P "Do a %B%F{cyan}zsys commit%f%b when you feel you're done!"
    fi

    case $1 in
        add)
            shift
            _filedb_add $*
            return $?
        ;;
        commit)
            _filedb_commit
            return $?
        ;;

        config)
            shift
            _zsys-config $*
            return $?
        ;;

        "log")
            shift
            _zsys-log $*
            return $?
        ;;
    esac
}
