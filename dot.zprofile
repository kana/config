# My zprofile.


# What machine am I working on?
# BUGS: ad hoc conditions to determine.
if [ "$OSTYPE" = 'cygwin' ]; then
  export ENV_WORKING='cygwin'
elif [ "$HOST" = 'colinux' ]; then
  export ENV_WORKING='colinux'
else
  export ENV_WORKING='linux'
fi


# What machine am I using to access $ENV_WORKING?
if [ "$TERM" = 'xterm-256color' ]; then
  # FIXME: How to determine colinux or linux?
  export ENV_ACCESS="$ENV_WORKING"
else
  export ENV_ACCESS='cygwin'
fi


# Suitable character encoding for $ENV_WORKING
export ENCODING_colinux='utf-8'
export ENCODING_cygwin='cp932'
export ENCODING_linux='euc-jp'


# Misc.
export EDITOR=vim
export PAGER=less
export SHELL=$(which zsh)
export TZ=JST-9

case "$ENV_ACCESS" in
  cygwin)
    export TERM=rxvt-cygwin-native
    export LANG=
    ;;
  colinux|linux|*)
    # export TERM=...  # Don't touch -- use the default values.
    # export LANG=...  # Don't touch -- use the default values.
    ;;
esac

export CYGHOME="/c/cygwin$HOME"




# gzip
export GZIP='--best --name --verbose'


# less
# -P '[?eEOF:?pB%pB\%..]  .?f%f:(stdin).?m (%i of %m).?lb  %lb?L/%L..'
export LESS='-P [?eEOF:?PB%PB\%..]'
case "$ENV_ACCESS" in
  cygwin)
    export JLESSCHARSET=japanese-sjis
    ;;
  colinux|linux|*)
    # Don't set.
    ;;
esac


# make
if [ "$ENV_WORKING" = 'cygwin' ]; then
  export MAKE_MODE=unix
fi


# X
if [ "$ENV_WORKING" = 'linux' ] && [ -n "$DISPLAY" ]; then
  setxkbmap us
  xmodmap ~/.xmodmaprc
  if ! xset q | grep $HOME >/dev/null; then
    for dir in ~/share/fonts/*; do
      xset fp+ $dir
    done
    xset fp rehash
  fi
fi


# __END__
# vim: filetype=zsh
