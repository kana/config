# $Id$
# SYSTEM-WIDE SETTINGS  {{{1

if [ -e /etc/bash.bashrc ]; then
  source /etc/bash.bashrc
fi




# ENVIRONMENT VARIABLES  {{{1

# COMMON

export PATH="~/bin:$PATH"
export MANPATH="~/man:$MANPATH"
export INFOPATH="~/info:$INFOPATH"

# export DISPLAY=localhost:0.0  # Don't set to use some applications without X.
export EDITOR=vim
export PAGER=less
export SHELL=/bin/bash
export TERM=cygwin
export TZ=JST-9


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
