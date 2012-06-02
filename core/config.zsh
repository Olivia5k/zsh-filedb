function _zsys-config() {
    typeset -a args orig_args
    local target f_global f_local fg lg kind

    if [[ -z "$1" ]]; then
        echo "helpful help is helpful"
        return 1
    fi

    conf=$1
    shift

    if [[ "$1" =~ "(local|global)" ]]; then
        kind=$1
        shift
    fi

    orig_args=($*)
    if [[ ${#orig_args} != 0 ]] ; then
        if [[ -z "$kind" ]]; then
            _zsys-parse_config $conf
        fi
        _zsys-parse_config_path $conf $kind
        for a in $orig_args; do
            f="$conf_path/$a"
            f=$f:A

            if [[ -f "$f" ]]; then
                args+=($f)
            else
                args+=($a)
            fi
        done

        edit $files
        return
    fi

    if [[ -n "$kind" ]]; then
        if [[ "$kind" = "global" ]]; then
            target=$CONF_GLOBAL[$conf]
        else
            target=$CONF_LOCAL[$conf]
        fi

        if [[ -z "$target" ]]; then
            echo "Error: no such config: $conf"
            return 2
        fi

        for f in ${(s: :)target}; do
            if [[ -f $f ]]; then
                target=$f
                break
            fi
        done

    else
        _zsys-parse_config $conf

        if [[ -z "$conf_global" ]] && [[ -z "$conf_local" ]]; then
            echo "Error: no such config: $conf"
            return 2

        elif [[ -n "$conf_global" ]] && [[ -n "$conf_local" ]]; then
            while [[ -z "$target" ]]; do
                echo -n "Both global and local configs exists for $conf. "
                echo "Which one do you want?"
                echo -n "[g/l] "
                read r

                if [[ $r =~ "[gG]" ]]; then
                    target=$conf_global
                elif [[ $r =~ "[lL]" ]]; then
                    target=$conf_local
                else
                    echo "Oh, come on now. ;)"
                fi
            done

        elif [[ -n "$conf_global" ]] ; then
            target=$conf_global

        elif [[ -n "$conf_local" ]] ; then
            target=$conf_local
        fi
    fi

    edit $target
}

function _zsys-parse_config() {
    conf_global=""
    conf_local=""
    kind=""

    for fg in ${(s: :)CONF_GLOBAL[$1]}; do
        if [[ -f $fg ]]; then
            conf_global=$fg
            kind="global"
            break
        fi
    done

    for fl in ${(s: :)CONF_LOCAL[$1]}; do
        if [[ -f $fl ]]; then
            conf_local=$fl
            kind="local"
            break
        fi
    done
}

function _zsys-parse_config_path() {
    conf_path=""

    if [[ "$2" = "global" ]]; then
        arr=$CONF_GLOBAL_DIR
    else
        arr=$CONF_LOCAL_DIR
    fi

    # Check if there is a path.
    if [[ -n "$arr[$1]" ]]; then
        for cp in ${(s: :)arr[$1]}; do
            if [[ -d $cp ]]; then
                conf_path=$cp:A
                break
            fi
        done

    # If there isn't, take the dir the config file is in.
    else
        _zsys-parse_config $1
        eval "f=\$conf_$2"
        conf_path=$f:A:h

        # Check if the selected dir is one of the ignored ones
        for id in ${(s: :)CONF_IGNORE_DIR}; do
            if [[ "$conf_path" = "$id" ]]; then
                conf_path=""
                break
            fi
        done

    fi
}

function _zsys-parse_config_filearg() {
    s=$words[3]

    # Check if we have a kind set already.
    if [[ -n "$words[4]" ]] && [[ $words[4] =~ "(global|local)" ]]; then
        kind=$words[4]

    # If not, try to find it!
    else
        _zsys-parse_config $s

        # If there are both local and global configs, we need to know
        # which one the user wants. Ask for it!
        # If there is just one, then $kind will be set!
        if [[ -n "$conf_global" ]] && [[ -n "$conf_local" ]]; then
            _values "$s" \
                "global[$conf_global]" \
                "local[$conf_local]" && return
        fi
    fi

    _zsys-parse_config_path $s $kind
    if [[ -d "$conf_path" ]]; then
        typeset -a ignores
        ignores=($words[3,1000])  # Really lazy default for now
        _arguments "*:$conf_path:_path_files -W $conf_path -F ignores" \
             && return
    fi
}

alias c="zsys config"
