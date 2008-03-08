# $Id$
# MISC.  {{{1

umask 077  # Default permission
ulimit -c 0  # Don't create core file


export CDPATH="$(echo . ~/freq{,/latest{,/working,/u}} | tr ' ' ':')"

# For Subversion via SSH.
if [ "${PATH/$HOME/}" = "$PATH" ]; then  # if $HOME/bin is not in $PATH ...
  PATH="$HOME/bin:$PATH"
fi


# Default values:
#   On:
#     cmdhist extquote force_fignore hostcomplete
#     interactive_comments progcomp promptvars sourcepath
#   Off:
#     cdable_vars cdspell checkhash checkwinsize dotglob execfail extdebug
#     extglob failglob gnu_errfmt histappend histreedit histverify huponexit
#     igncr lithist mailwarn no_empty_cmd_completion nocaseglob nocasematch
#     nullglob shift_verbose xpg_echo
#   Differ for each instance:
#     expand_aliases login_shell restricted_shell
shopt -s checkwinsize                   # Auto recognizing window size
shopt -s histappend                     # Don't overwrite HISTFILE
shopt -s no_empty_cmd_completion        # Don't complete when empty line
shopt -u hostcomplete                   # Don't complete hostname
shopt -u sourcepath                     # Don't search PATH for `source'




# HISTORY

HISTSIZE=50000  # History size at runtime
HISTFILESIZE=$HISTSIZE  # History size to save

# Don't save lines which are matched to these patterns:
# 1. Same as the previous line.
# 2. Starts with a whitespace.
HISTIGNORE='&: *'




# PROMPT
#
# user@host cwd (shlvl)
# $

_set_up_prompt() {
  local _c_reset='\[\e[0m\]'
  local _c_cyan='\[\e[36m\]'
  local _c_green='\[\e[32m\]'
  local _c_red='\[\e[31m\]'
  local _c_yellow='\[\e[33m\]'

  local _c_user
  case "$USER" in
    root) _c_user="$_c_red" ;;
    *) _c_user="$_c_green" ;;
  esac
  local _c_host
  case "$HOSTNAME" in
    colinux) _c_host="$_c_cyan" ;;
    *)
      if [ "$ENV_WORKING" != "$ENV_ACCESS" ]; then
        _c_host="$_c_cyan"
      else
        _c_host="$_c_green"
      fi
      ;;
  esac

  local _prompt_title='\[\e]0;\u@\h \w\007\]'
  local _prompt_host="$_c_user\\u$_c_reset$_c_host@\\h$_c_reset"
  local _prompt_cwd="$_c_yellow\\w$_c_reset"
  local _prompt_main='\$ '
  if [[ 2 -le $SHLVL ]]; then  # is nested interactive shell?
    local _prompt_shlvl=' ($SHLVL)'
  else
    local _prompt_shlvl=''
  fi
  if [ -n "$WINDOW" ]; then  # auto-title in GNU screen
    local _prompt_auto='\ek\e\\'
  else
    local _prompt_auto=''
  fi

  PS1="$_prompt_auto$_prompt_title
$_prompt_host $_prompt_cwd$_prompt_shlvl
$_prompt_main"
}

_set_up_prompt

unset -f _set_up_prompt








# ALIASES  {{{1

alias ls='ls --show-control-chars --color=auto'
alias la='ls -a'
alias ll='ls -l'
alias lal='ls -al'
alias lla='ls -la'
alias altr='ls -altr'

alias v='vim'
alias g='git'
complete -F _git g

alias ..='cd ..'

alias afk='echo "Away From Keyboard ..."; while true; do date; sleep 5m; done'

if [ "$ENV_WORKING" = 'colinux' ]; then
  alias mount-c='mount-x c'
  alias umount-c='umount-x c'

  #alias mount-c='mount-c-smbfs'
  #alias umount-c='sudo umount /c'
  alias mount-c-cofs='sudo mount -t cofs cofs0 /c -o defaults,noatime,noexec,user,uid=$USER,gid=users'
  #alias mount-c-smbfs='sudo mount -t smbfs "//windows/C\$" /c -o defaults,noatime,user,uid=$USER,gid=users,fmask=0644,dmask=0755,username=$USER'

  alias mount-x='mount-x-samba'
  alias umount-x='umount-x-samba'

  function mount-x-samba() {
    if [ $# != 1 ]; then
      echo "Usage: $0 {drive-letter}"
      return 1
    fi
    sudo mount -t smbfs \
         "//windows/$(echo "$1" | tr '[:lower:]' '[:upper:]')\$" "/$1" \
         -o "defaults,noatime,user,uid=$USER,gid=users,fmask=0644,dmask=0755,username=$USER"
  }
  function umount-x-samba() {
    if [ $# != 1 ]; then
      echo "Usage: $0 {drive-letter}"
      return 1
    fi
    sudo umount "/$1"
  }

  function mount-x-sshfs() {
    if [ $# != 1 ]; then
      echo "Usage: $0 {drive-letter}"
      return 1
    fi
    sshfs "cygwin:/cygdrive/$1" "/$1"
  }
  function umount-x-sshfs() {
    if [ $# != 1 ]; then
      echo "Usage: $0 {drive-letter}"
      return 1
    fi
    fusermount -u "/$1"
  }

  alias shutdown-colinux='sudo halt; exit'
fi

function backup-repos() {
  local datetime=$(date '+%Y-%m-%dT%H-%M-%S')

  for i in cereja config meta nicht
  do
    pushd ~/freq/latest/working/$i &>/dev/null
      tar jcf /c/cygwin/home/$USER/var/$datetime-git-$i.tar.bz2 .git/
      git-svn dcommit
    popd &>/dev/null
  done

  ssh cygwin <<END
  pushd ~/var &>/dev/null
    for i in cereja nicht repos vim
    do
      tar jcf $datetime-svn-\$i.tar.bz2 svn-\$i/
    done
    cp -a $datetime-*.tar.bz2 /e/backup/repos/
  popd &>/dev/null
END
}








# ETC  {{{1

source ~/.bash.d/cdhist.sh


case "$ENV_WORKING" in
  cygwin|linux)
    BASH_COMPLETION=~/.bash.d/bash_completion
    BASH_COMPLETION_DIR=~/.bash.d/NO_SUCH_DIR  # Don't use contrib for this.
    ;;
  colinux)
    BASH_COMPLETION=/etc/bash_completion
    # BASH_COMPLETION_DIR=...  # Don't set - use the default value.
    ;;
  *)
    # NOP
    ;;
esac
if [ -n "$BASH_COMPLETION" ] && [ -r "$BASH_COMPLETION" ]; then
  source "$BASH_COMPLETION"
fi


complete -C ~/.bash.d/svk-completion.pl -o default svk








# __END__
# vim: filetype=sh foldmethod=marker
