function _zsys-config()
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
alias c="zsys config"
