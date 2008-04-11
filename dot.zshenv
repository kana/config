# My zshenv.
# Note: Source order:
#       (1) zshenv (always),
#       (2) zprofile (login),
#       (3) zshrc (interactive),
#       (4) zlogin (login) [not used],
#       ... session ...
#       (5) zlogout (login) [not used].


# PATH
export PATH MANPATH INFOPATH
if [ "${PATH/$HOME/}" = "$PATH" ]; then  # if $HOME/bin is not in $PATH ...
  # for Ruby
  if which gem &>/dev/null; then
    PATH="$PATH:$(gem environment gempath)/bin"
  fi

  # for MacPorts
  if [ -d /opt/local ]; then
    for i in /opt/local/{bin,sbin}; do
      if [ -d "$i" ]; then
	PATH="$i:$PATH"
      fi
    done
    if [ -d "/opt/local/share/man" ]; then MANPATH="/opt/local/share/man:$MANPATH"; fi
  fi

  # for manually built applications
  if [ -d /usr/local/apps ]; then
    for i in /usr/local/apps/*; do
      if [ -d "$i/bin" ]; then PATH="$i/bin:$PATH"; fi
      if [ -d "$i/man" ]; then MANPATH="$i/man:$MANPATH"; fi
      if [ -d "$i/share/man" ]; then MANPATH="$i/share/man:$MANPATH"; fi
      if [ -d "$i/info" ]; then INFOPATH="$i/info:$INFOPATH"; fi
    done
  fi

  # for my own tools
  if [ -d "$HOME/bin" ]; then PATH="$HOME/bin:$PATH"; fi
  if [ -d "$HOME/man" ]; then MANPATH="$HOME/man:$MANPATH"; fi
  if [ -d "$HOME/share/man" ]; then MANPATH="$HOME/share/man:$MANPATH"; fi
  if [ -d "$HOME/info" ]; then INFOPATH="$HOME/info:$INFOPATH"; fi
fi


# __END__
# vim: filetype=zsh
