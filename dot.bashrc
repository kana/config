# $Id$
# MISC.  {{{1

umask 077  # Default permission
ulimit -c 0  # Don't create core file


export CDPATH="$(echo . ~/freq{,/latest{,/working}} | tr ' ' ':')"


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
HISTIGNORE='&'  # Don't save matched lines




# PROMPT

# user@host cwd (shlvl)
# $
_prompt_title='\[\e]0;\u@\h \w\007\]'
_prompt_host='\[\e[32m\]\u@\h\[\e[0m\]'
_prompt_cwd='\[\e[33m\]\w\[\e[0m\]'
_prompt_main='\$ '
if [[ 2 -le $SHLVL ]]; then  # is nested interactive shell?
  _prompt_shlvl=' ($SHLVL)'
else
  _prompt_shlvl=''
fi
PS1="$_prompt_title
$_prompt_host $_prompt_cwd$_prompt_shlvl
$_prompt_main"
unset _prompt_title _prompt_host _prompt_cwd _prompt_main _prompt_shlvl








# ALIASES  {{{1

alias ls='ls --show-control-chars --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias altr='ls -altr'

alias q='exit'

alias v='vim'

alias ..='cd ..'








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








# __END__
# vim: filetype=sh foldmethod=marker
