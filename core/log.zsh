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
