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

            if [[ ! -w "$a" ]] && ! [[ $editor =~ "^sudo " ]]; then
                print -Pn "%B%F{yellow}${a:a}%f%b not writable by "
                print -P  "%B%F{green}${USER}%f%b; going sudo"

                editor="sudo $editor"
            fi
        else
            args+=($a)
        fi
    done

    # Before editing, cd to the parent directory of the first file given
    cd -q ${files[1]:h} &> /dev/null
    ${(z)editor} $args $files
    cd -q - &> /dev/null
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
