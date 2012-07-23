function zsys-edit()
{
    _zsys-execute "${${ZSYS_EDITOR:-$EDITOR}:-vi}" write $*
}

alias e="zsys-edit"
eval "alias $EDITOR=zsys-edit"

function zsys-log()
{
    _zsys-execute "${${ZSYS_PAGER:-$PAGER}:-less}" read $*
}
function zsys-tail()
{
    _zsys-execute "${${ZSYS_TAILER:-$TAILER}:-tail -f}" read $*
}
