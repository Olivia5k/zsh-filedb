for daemon in rc.d service; do
    if [[ -x $commands[$daemon] ]]; then
        alias d="sudo $daemon"
    fi
done
