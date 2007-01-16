# $Id$
# MISC.  {{{1

umask 077  # Default permission
ulimit -c 0  # Don't create core file


CDPATH="$(echo . ~/freq{,/latest{,/working}} | tr ' ' ':')"

HISTSIZE=50000                          # History size
HISTFILESIZE=$HISTSIZE                  # ... for history file
HISTIGNORE='&'                          # Don't save matching last line

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




# ALIASES  {{{1

alias ls='ls --show-control-chars --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias altr='ls -altr'

alias q='exit'

alias v='vim'




# ETC  {{{1

source ~/.bash/cdhist.sh

BASH_COMPLETION=~/.bash/bash_completion
BASH_COMPLETION_DIR=~/.bash/NO_SUCH_DIR  # Don't use contrib for this.
source $BASH_COMPLETION




# __END__
# vim: filetype=sh foldmethod=marker
