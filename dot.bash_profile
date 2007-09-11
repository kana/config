# $Id$
# MISC. INITIALIZATION {{{1

_check_then_source() {  # script-path
  if [ -e "$1" ]; then
    source "$1"
  fi
}


_report_error() {  # variable-name message
  echo ".bash_profile: $2: Invalid $1=${!1}" >/dev/stderr
}








# ENVIRONMENT VARIABLES  {{{1
# COMMON  {{{2

# What machine am I working on?
  # BUGS: The way to determine is not so good.
if [ "$OSTYPE" == 'cygwin' ]; then
  export ENV_WORKING='cygwin'
elif [ "$HOSTNAME" == 'colinux' ]; then
  export ENV_WORKING='colinux'
else
  export ENV_WORKING='linux'
fi

# What machine am I accessing to $ENV_WORKING?
if [ "$TERM" == 'xterm-256color' ]; then
  # FIXME: How to determine colinux or linux?
  export ENV_ACCESS="$ENV_WORKING"
else
  export ENV_ACCESS='cygwin'
fi


if [ -d "$HOME/bin" ]; then export PATH="$HOME/bin:$PATH"; fi
if [ -d "$HOME/man" ]; then export MANPATH="$HOME/man:$MANPATH"; fi
if [ -d "$HOME/info" ]; then export INFOPATH="$HOME/info:$INFOPATH"; fi

# export DISPLAY=localhost:0.0  # Don't set to use some applications without X.
export EDITOR=vim
export PAGER=less
export SHELL=/bin/bash
export TZ=JST-9

case "$ENV_ACCESS" in
  cygwin)
    export TERM=rxvt-cygwin-native
    export LANG=
    ;;
  colinux|linux)
    # export TERM=...  # Don't touch -- use the default values.
    # export LANG=...  # Don't touch -- use the default values.
    ;;
  *)
    _report_error ENV_ACCESS 'TERM/LANG'
    ;;
esac




# COMMAND-SPECIFIC  {{{2

# bash
IGNOREEOF=1  # Don't export -- only set for the login shell.


# cvs
export CVS_RSH=ssh
if [ "$ENV_WORKING" = 'cygwin' ]; then
  export CVSROOT=$HOME/var/cvsroot
fi


# gzip
export GZIP='--best --name --verbose'


# less
# -P '[?eEOF:?pB%pB\%..]  .?f%f:(stdin).?m (%i of %m).?lb  %lb?L/%L..'
export LESS='-P [?eEOF:?PB%PB\%..]'
case "$ENV_ACCESS" in
  cygwin)
    export JLESSCHARSET=japanese-sjis
    ;;
  colinux|linux)
    # Don't set.
    ;;
  *)
    _report_error ENV_ACCESS 'JLESSCHARSET'
    ;;
esac

# make
if [ "$ENV_WORKING" = 'cygwin' ]; then
  export MAKE_MODE=unix
fi








# SYSTEM-WIDE SETTINGS  {{{1

case "$ENV_WORKING" in
  cygwin)
    _check_then_source /etc/bash.bashrc
    ;;
  colinux)
    _check_then_source /etc/bash.bashrc
    ;;
  linux)
    _check_then_source /etc/bashrc
    ;;
  *)
    _report_error ENV_WORKING 'SYSTEM-WIDE SETTINGS'
    ;;
esac








# USER-SPECIFIC SETTINGS  {{{1

_check_then_source ~/.bashrc








# MISC. FINALIZATION  {{{1

unset -f _check_then_source
unset -f _report_error








# __END__
# vim: filetype=sh foldmethod=marker
