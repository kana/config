# $Id$
# SYSTEM-WIDE SETTINGS  {{{1

if [ -e /etc/bash.bashrc ]; then
  source /etc/bash.bashrc
fi




# ENVIRONMENT VARIABLES  {{{1

# COMMON

# What machine am I working on?
if [ "$OSTYPE" == 'cygwin' ]; then  # On Windows
  export ENV_WORKING=cygwin
else  # == 'linux-gnu' - On Linux
  export ENV_WORKING=linux
fi

# What machine do I access from? (via SSH)
if [ "$ENV_WORKING" == 'cygwin' -o "$TERM" == 'rxvt-cygwin-native' ]; then
  export ENV_ACCESS=cygwin
else
  export ENV_ACCESS=linux
fi


export PATH="$HOME/bin:$PATH"
export MANPATH="$HOME/man:$MANPATH"
export INFOPATH="$HOME/info:$INFOPATH"

# export DISPLAY=localhost:0.0  # Don't set to use some applications without X.
export EDITOR=vim
export PAGER=less
export SHELL=/bin/bash
export TZ=JST-9

if [ "$ENV_ACCESS" = 'cygwin' ]; then
  export TERM=rxvt-cygwin-native
  export LANG=
else
  # export TERM=...  # Don't touch -- use the default value.
  export LANG=ja_JP.EUC-JP
fi



# COMMAND-SPECIFIC

# bash
# Don't export -- set only login shell.
IGNOREEOF=1

# cvs
export CVSROOT=$HOME/var/cvsroot
export CVS_RSH=ssh

# gzip
export GZIP='--best --name --verbose'

# less
# -P '[?eEOF:?pB%pB\%..]  .?f%f:(stdin).?m (%i of %m).?lb  %lb?L/%L..'
export LESS='-P [?eEOF:?PB%PB\%..]'
export JLESSCHARSET=japanese-sjis

# make
export MAKE_MODE=unix




# USER-SPECIFIC SETTINGS  {{{1

if [ -e ~/.bashrc ]; then
  source ~/.bashrc
fi

# __END__
# vim: filetype=sh foldmethod=marker
