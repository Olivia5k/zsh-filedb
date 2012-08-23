function _zsys-execute()
{
    typeset -a files args
    local cmd

    cmd=$1
    action=$2
    shift 2

    for a in $*; do
        if [[ -f "$a" ]]; then
            # Use absolute paths. If symbolic links, follow them as long as
            # possible.
            files+=($a:A)

            if ([[ "$action" = "write" ]] && [[ ! -w "$a" ]]) || \
                ([[ "$action" = "read" ]] && [[ ! -r "$a" ]]); then
                if ! [[ $cmd =~ "^sudo " ]] ; then
                    if [[ "$2" = "write" ]]; then
                        verb="writable"
                    else
                        verb="readable"
                    fi

                    print -Pn "%B%F{yellow}${a:a}%f%b not $verb by "
                    print -P  "%B%F{green}${USER}%f%b; going sudo"

                    cmd="sudo $cmd"
                fi
            fi
        else
            args+=($a)
        fi
    done

    # Silently cd to the directory containing the files
    cd -q ${files[1]:h} &> /dev/null
    ${(z)cmd} $args $files
    cd -q - &> /dev/null
}
