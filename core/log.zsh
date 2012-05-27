function _zsys-log()
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
alias l="zsys log"
