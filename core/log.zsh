function _zsys-log()
{
    local target cmd

    cmd=$1
    shift

    if [[ -z "$1" ]]; then
        echo "helpful help is helpful"
        return 1
    fi

    for l in ${(s: :)LOG_GLOBAL[$1]}; do
        if [[ -f $l ]]; then
            target=$l
            break
        fi
    done

    zsys-${cmd} $target
}

#alias l="zsys log"
#alias t="zsys tail"
