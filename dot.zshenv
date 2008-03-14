# My zshenv.
# Note: Source order:
#       (1) zshenv (always),
#       (2) zprofile (login),
#       (3) zshrc (interactive),
#       (4) zlogin (login) [not used],
#       ... session ...
#       (5) zlogout (login) [not used].


# PATH
if [ "${PATH/$HOME/}" = "$PATH" ]; then  # if $HOME/bin is not in $PATH ...
  if which gem &>/dev/null; then
    PATH="$PATH:$(gem environment gempath)/bin"
  fi

  if [ -d /usr/local/apps ]; then
    for i in /usr/local/apps/*/bin; do
      if [ -d "$i" ]; then
	PATH="$i:$PATH"
      fi
    done
  fi

  if [ -d "$HOME/bin" ]; then export PATH="$HOME/bin:$PATH"; fi
  if [ -d "$HOME/man" ]; then export MANPATH="$HOME/man:$MANPATH"; fi
  if [ -d "$HOME/info" ]; then export INFOPATH="$HOME/info:$INFOPATH"; fi
fi


# __END__
# vim: filetype=zsh
