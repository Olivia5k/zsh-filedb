#!/bin/zsh
#
# zsh-filedb: Quickfast access to configuration files and logs
# https://github.com/daethorian/zsh-filedb.git
#
# Written by Lowe Thiderman (lowe.thiderman@gmail.com)
# Licensed under the GPLv2.
#
# See the README for usage instructions.

# TODO:
# Configuration variables
#   Alias editor yesno
#   The different colors


# Find the db even if this file is a symbolic link
export FILEDB="$0:A:h/db/db.zsh"
source $FILEDB

export FILEDB_DIRTY=""

function config()
{
    local target f_global f_local fg lg

    if [[ -z "$1" ]]; then
        echo "helpful help is helpful"
        return 1
    fi


    if [[ "$2" =~ "(local|global)" ]]; then
        if [[ "$2" = "global" ]]; then
            target=$CONF_GLOBAL[$1]
        else
            target=$CONF_LOCAL[$1]
        fi

        if [[ -z "$target" ]]; then
            echo "Error: no such config: $1"
            return 2
        fi

        for f in ${(s: :)target}; do
            if [[ -f $f ]]; then
                edit $f
                return
            fi
        done
    else
        for fg in ${(s: :)CONF_GLOBAL[$1]}; do
            if [[ -f $fg ]]; then
                f_global=$fg
                break
            fi
        done

        for fl in ${(s: :)CONF_LOCAL[$1]}; do
            if [[ -f $fl ]]; then
                f_local=$fl
                break
            fi
        done

        if [[ -z "$f_global" ]] && [[ -z "$f_local" ]]; then
            echo "Error: no such config: $1"
            return 2

        elif [[ -n "$f_global" ]] && [[ -n "$f_local" ]]; then
            while [[ -z "$target" ]]; do
                echo -n "Both global and local configs exists for $1. "
                echo "Which one do you want?"
                echo -n "[g/l] "
                read r

                if [[ $r =~ "[gG]" ]]; then
                    target=$f_global
                elif [[ $r =~ "[lL]" ]]; then
                    target=$f_local
                else
                    echo "Oh, come on now. ;)"
                fi
            done

        elif [[ -n "$f_global" ]] ; then
            target=$f_global

        elif [[ -n "$f_local" ]] ; then
            target=$f_local

        else
            echo "Error: This is a logical absurdity! :D"
            return -1
        fi

        edit $target
    fi
}
alias c="config"

function _confcomplete()
{
    if (( CURRENT == 2 )) ; then
        for s in ${(k)CONF_GLOBAL}; do
            for f in ${(s: :)CONF_GLOBAL[$s]}; do
                if [[ -f $f ]]; then
                    reply+=($s)
                fi
            done
        done

        for s in ${(k)CONF_LOCAL}; do
            for f in ${(s: :)CONF_LOCAL[$s]}; do
                if [[ -f $f ]]; then
                    reply+=($s)
                fi
            done
        done
    else
        reply=(global local)
    fi
}

compctl -Y "%B%F{blue}conf%f%b" -K _confcomplete config

function logfile()
{
    local target

    if [[ -z "$1" ]]; then
        echo "No."
        return 1
    fi

    for l in ${(s: :)LOG_GLOBAL[$1]}; do
        if [[ -f $l ]]; then
            target=$l
            break
        fi
    done

    # By default, tail the file, unless arguments were given
    if [[ "$2" = "page" ]]; then
        page $target
    elif [[ "$2" = "edit" ]]; then
        edit $target
    else
        page --tail $target
    fi
}
alias l="logfile"

function _logcomplete()
{
    if (( CURRENT == 2 )) ; then
        for s in ${(k)LOG_GLOBAL}; do
            for f in ${(s: :)LOG_GLOBAL[$s]}; do
                if [[ -f $f ]]; then
                    reply+=($s)
                fi
            done
        done
    else
        reply=(edit page tail)
    fi
}

compctl -Y "%B%F{blue}log%f%b" -K _logcomplete logfile

# Smartypants sudo wrapper!
function edit()
{
    typeset -a args files
    local editor=${$(whence -pc $EDITOR):-vi}

    for a in $*; do
        if [[ -f "$a" ]]; then
            # Use absolute paths. If symbolic links, follow them as long as
            # possible.
            files+=($a:A)

            if [[ ! -w "$a" ]]; then
                print -Pn "%B%F{yellow}${a}%f%b not writable by "
                print -P  "%B%F{green}${USER}%f%b; going sudo"

                # Only once should be enough.
                if ! [[ $editor =~ "^sudo " ]]; then
                    editor="sudo $editor"
                fi
            fi
        else
            args+=($a)
        fi
    done

    ${(z)editor} $args $files
}
alias e="edit"

eval "alias $EDITOR=edit"

function page()
{
    typeset -a args files

    if [[ "$1" = "--tail"  ]]; then
        # Use multitail if available; otherwise tail -f
        local pager=${$(whence -pc multitail):-tail -f}
        shift
    else
        local pager=${$(whence -pc $PAGER):-less}
    fi

    for a in $*; do
        if [[ -f "$a" ]]; then
            # Use absolute paths. If symbolic links, follow them as long as
            # possible.
            files+=($a:A)

            if ! [[ -r "$a" ]]; then
                print -Pn "%B%F{yellow}${a}%f%b not readable by "
                print -P  "%B%F{green}${USER}%f%b; going sudo"

                # Only once should be enough.
                if ! [[ $pager =~ "^sudo " ]]; then
                    pager="sudo $pager"
                fi
            fi
        else
            args+=($a)
        fi
    done

    ${(z)pager} $args $files
}

function filedb()
{
    if [[ "$1" != "commit" ]] && [[ -n "$FILEDB_DIRTY" ]]; then
        echo "You have changes to your filedb database."
        print -P "Do a %B%F{cyan}filedb commit%f%b when you feel you're done!"
    fi

    if [[ "$1" = "add" ]]; then
        shift
        _filedb_add $*
        return $?
    elif [[ "$1" = "commit" ]]; then
        _filedb_commit
        return $?
    fi
}

compctl -Y "%B%F{blue}command%f%b" -k "(add commit)" filedb

function _filedb_add()
{
    local cat name file orig target

    if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
        echo "Usage: filedb add <category> <name> <file path>"
        return 1
    fi

    cat=$1
    name="[$2]"
    file=$3:a  # Use aboslute file names

    if [[ ! -f "$file" ]]; then
        echo "Error: $file is not a valid file."
        return 2
    fi

    if ! [[ "$cat" =~ "CONF_(GLOBAL|LOCAL)" ]]; then
        echo "Error: $cat is not a valid filedb category."
        return 3
    fi

    # To dynamically get the needed map, eval it in
    eval "orig=\"\$${cat}${name}\""

    if [[ -n "$orig" ]]; then
        for f in ${(s: :)orig}; do
            if [[ "$f" = "$file" ]]; then
                echo "Error: $file is already in ${cat}${name}"
                return 4
            fi
        done

        target="$orig $file"
    else
        target="$file"
    fi

    eval "${cat}${name}=\"$target\""
    print -P "%B${file}%b added to %B${cat}${name}%b"

    export FILEDB_DIRTY=";)"
}

function _filedb_commit()
{
    f=$FILEDB

    echo "#!/bin/zsh" > $f
    echo "# Database of filenames for zsh-filedb." >> $f
    echo "# Autogenerated for your pleasure." >> $f
    echo >> $f

    echo "typeset -Ag CONF_LOCAL" >> $f
    for k in ${(ko)CONF_LOCAL}; do
        s=$CONF_LOCAL[$k]

        # Substitute the expanded varaibles back into their variable form.
        s=${s/$XDG_CONFIG_HOME/\$XDG_CONFIG_HOME}
        s=${s/$HOME/\$HOME}

        echo "CONF_LOCAL[$k]=\"$s\"" >> $f
    done

    echo >> $f
    echo "typeset -Ag CONF_GLOBAL" >> $f
    for k in ${(ko)CONF_GLOBAL}; do
        s=$CONF_GLOBAL[$k]
        echo "CONF_GLOBAL[$k]=\"$s\"" >> $f
    done

    echo >> $f
    echo "typeset -Ag LOG_GLOBAL" >> $f
    for k in ${(ko)LOG_GLOBAL}; do
        s=$LOG_GLOBAL[$k]
        echo "LOG_GLOBAL[$k]=\"$s\"" >> $f
    done

    echo >> $f
    echo "export CONF_LOCAL CONF_GLOBAL LOG_GLOBAL" >> $f

    echo
    print -P "%F{green}%BSuccess%b%f! |o/ filedb db updated."
    unset FILEDB_DIRTY
}
