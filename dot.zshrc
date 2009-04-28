# My zshrc.
# Misc.  #{{{1

umask 077  # Default permission
ulimit -c 0  # Don't create core dumps
bindkey -v  # vi!  vi!








# Parameters  #{{{1

case "$ENV_WORKING" in
  cygwin)
    export CDPATH="$(echo . ~/freq{,/latest{,/working,/u}} | tr ' ' ':')"
    ;;
  mac)
    export CDPATH="$(echo . ~/{working,Downloads,} | tr ' ' ':')"
    ;;
  *)
    export CDPATH="$(echo . ~/{working,} | tr ' ' ':')"
    ;;
esac
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000








# Options  #{{{1

# aliases
unsetopt all_export
# always_last_prompt
# always_to_end
setopt append_history
unsetopt auto_cd
# auto_continue
setopt auto_list
# setopt auto_menu
# auto_name_dirs
setopt auto_param_keys
setopt auto_param_slash
# auto_pushd
setopt auto_remove_slash
# auto_resume
setopt bad_pattern
setopt bang_hist
# bare_glob_qual
# setopt bash_auto_list
unsetopt beep
# bg_nice
# brace_ccl
# bsd_echo
setopt case_glob
# c_bases
unsetopt cdable_vars
# chase_dots
# chase_links
setopt check_jobs
# clobber
# complete_aliases
# complete_in_word
# correct
# correct_all
# csh_junkie_history
# csh_junkie_loops
# csh_junkie_quotes
# csh_null_glob
# csh_nullcmd
# dvorak
# emacs
# equals
# err_exit
# err_return
# exec
setopt extended_glob
# extended_history
# flow_control
# function_argzero
setopt glob
# glob_assign
setopt glob_complete
# glob_dots
# glob_subst
# global_export
# global_rcs
# hash_cmds
# hash_dirs
# hash_list_all
# hist_allow_clobber
# hist_beep
# hist_expire_dups_first
# hist_find_no_dups
# hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
# hist_no_functions
# hist_no_store
# hist_reduce_blanks
# hist_save_no_dups
# hist_verify
# hup
# ignore_braces
setopt ignore_eof
# inc_append_history
# interactive
setopt interactive_comments
# ksh_arrays
# ksh_autoload
# ksh_glob
# ksh_option_print
# ksh_typeset
setopt list_ambiguous
# list_beep
setopt list_packed
# list_rows_first
setopt list_types
# local_options
# local_traps
# login
setopt long_list_jobs
# magic_equal_subst
# mail_warning
# mark_dirs
setopt menu_complete
# monitor
setopt multios
setopt nomatch
# notify
unsetopt null_glob
# numeric_glob_sort
# octal_zeroes
# overstrike
# path_dirs
# posix_builtins
setopt print_eight_bit
# print_exit_value
# privileged
# prompt_bang
# prompt_cr
setopt prompt_percent
setopt prompt_subst
# pushd_ignore_dups
# pushd_minus
# pushd_silent
# pushd_to_home
setopt rc_expand_param
# rc_quotes
# rcs
# rec_exact
# restricted
# rm_star_silent
# rm_star_wait
# sh_file_expansion
# sh_glob
# sh_nullcmd
# sh_option_letters
# sh_word_split
setopt share_history
# shin_stdin
# short_loops
# single_command
# single_line_zle
# sun_keyboard_hack
setopt transient_rprompt
# typeset_silent
# unset
# verbose
# vi
# xtrace
# zle








# Prompt  #{{{1
#
# user@host cwd (shlvl)
# $

function prompt_setup() {
  local c_reset=$'\e[0m'
  local c_cyan=$'\e[36m'
  local c_green=$'\e[32m'
  local c_red=$'\e[31m'
  local c_yellow=$'\e[33m'

  local c_user
  case "$USER" in
    root)
      c_user="$c_red"
      ;;
    *)
      c_user="$c_green"
      ;;
  esac
  local c_host
  case "$HOST" in
    colinux)
      c_host="$c_cyan"
      ;;
    *)
      if [ "$ENV_WORKING" != "$ENV_ACCESS" ]; then
        c_host="$c_cyan"
      else
        c_host="$c_green"
      fi
      ;;
  esac

  local t_host="$c_user%n$c_reset$c_host@%m$c_reset"
  local t_cwd="$c_yellow%~$c_reset"
  local t_main='YUKI.N%(!.#.>) '
  if [[ 2 -le $SHLVL ]]; then  # is nested interactive shell?
    local t_shlvl=' ($SHLVL)'
  else
    local t_shlvl=''
  fi

  PS1="
$t_host $t_cwd$t_shlvl\$(prompt-git-head-name)
$t_main"
}

prompt_setup
unset -f prompt_setup








# Aliases  #{{{1
# common  #{{{2

alias ls='ls --show-control-chars --color=auto'
alias la='ls -a'
alias ll='ls -l'
alias lal='ls -al'
alias lla='ls -la'
alias altr='ls -altr'

alias v='vim'
alias g='git'
alias gs='git svn'
alias screen='LANG= screen'

alias ..='cd ..'




# colinux only  #{{{2

if [ "$ENV_WORKING" = 'colinux' ]; then
  alias shutdown-colinux='sudo halt; exit'

  # mount wrappers  #{{{
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
  #}}}

  function backup-repos() {  #{{{
    local datetime=$(date '+%Y-%m-%dT%H-%M-%S')

    for i in cereja config meta nicht vim
    do
      pushd ~/freq/latest/working/$i &>/dev/null
        echo "Processing $i ..."
        git gc
        tar jcf /c/cygwin/home/$USER/var/$datetime-git-$i.tar.bz2 .git/
        # # disabled, it's somewhat dangerous.
        # # if dcommit is necessary, do it manually.
        # git-svn dcommit
      popd &>/dev/null
    done

    ssh cygwin <<END
    pushd ~/var &>/dev/null
      # # experimental: disabled to fully migrate to git.
      # for i in cereja nicht repos vim
      # do
      #   tar jcf $datetime-svn-\$i.tar.bz2 svn-\$i/
      # done
      cp -av $datetime-*.tar.bz2 /e/backup/repos/
    popd &>/dev/null
END
  }  #}}}
fi








# Functions  #{{{1

if where git &>/dev/null; then
  function prompt-git-head-name() {
    local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
    if [ -z "$git_dir" ]; then
      return 1
    fi

    local head_name=''
    local additional_info=''
    if [ -d "$git_dir/rebase-apply" ]; then
      if [ -f "$git_dir/rebase-apply/rebasing" ]; then
        additional_info="REBASE"
      elif [ -f "$git_dir/rebase-apply/applying" ]; then
        additional_info="AM"
      else
        additional_info="AM/REBASE"
      fi
      head_name="$(git symbolic-ref HEAD 2>/dev/null)"
    elif [ -f "$git_dir/rebase-merge/interactive" ]; then
      additional_info="REBASE-i"
      head_name="$(< "$git_dir/rebase-merge/head-name")"
    elif [ -d "$git_dir/rebase-merge" ]; then
      additional_info="REBASE-m"
      head_name="$(< "$git_dir/rebase-merge/head-name")"
    elif [ -f "$git_dir/MERGE_HEAD" ]; then
      additional_info="MERGING"
      head_name="$(git symbolic-ref HEAD 2>/dev/null)"
    fi
    if [ -z "$head_name" ]; then
      head_name="$(git branch | sed -e 's/^\* //;t;d')"
      if [ "$head_name" = '(no branch)' ]; then
        # "git branch" doesn't show the correct name of a branch after
        # "git checkout {commitish-and-not-the-head-of-a-branch}",
        # so we have to use another method to get the name of {commitish}.
        head_name="($(
          {
            fgrep 'checkout: moving from ' .git/logs/HEAD |
            sed '$s/^.* to \([^ ]*\)$/\1/;t;d'
          } 2>/dev/null
        ))"
      elif [ "$head_name" = '' ]; then
        head_name='(just initialized; nothing commited)'
      fi
    else
      head_name="${head_name##refs/heads/}"
    fi
    if [ -n "$additional_info" ]; then
      additional_info="|$additional_info"
    fi

    echo " [$head_name$additional_info]"
    return 0
  }
else
  function prompt-git-head-name() {
    echo ''
  }
fi








# Line Editor  #{{{1
# Vim-like behavior  #{{{2

# Another Esc key.
bindkey -M viins '\C-@' vi-cmd-mode
bindkey -M vicmd '\C-@' vi-cmd-mode

# to delete characters beyond the starting point of the current insertion.
bindkey -M viins '\C-h' backward-delete-char
bindkey -M viins '\C-w' backward-kill-word
bindkey -M viins '\C-u' backward-kill-line

# undo/redo more than once.
bindkey -M vicmd 'u' undo
bindkey -M vicmd '\C-r' redo

# history
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M vicmd '^[k' history-beginning-search-backward
bindkey -M vicmd '^[j' history-beginning-search-forward
bindkey -M vicmd 'gg' beginning-of-history

# modification
bindkey -M vicmd 'gu' down-case-word
bindkey -M vicmd 'gU' up-case-word
bindkey -M vicmd 'g~' vi-oper-swap-case




# Misc.  #{{{2

bindkey -M vicmd '\C-t' transpose-chars
bindkey -M viins '\C-t' transpose-chars
bindkey -M vicmd '^[t' transpose-words
bindkey -M viins '^[t' transpose-words

# Disable - the default binding _history-complete-older is very annoying
# whenever I begin to search with the same key sequence.
bindkey -M viins -r '^[/'

# Experimental: Alternate keys to the original bindings.
bindkey -M viins '^[,' _history-complete-newer
bindkey -M viins '^[.' _history-complete-older

# Hot key to continue a Vim process from the previous pseudo-:suspend.
my-screen-to-other () { screen -X other; }
zle -N my-screen-to-other
bindkey -M vicmd '^Z' my-screen-to-other
bindkey -M viins '^Z' my-screen-to-other








# Completion  #{{{1
# by compinstall  #{{{2

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _list _expand _complete _ignored _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' max-errors 1
zstyle ':completion:*' menu select=1
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' prompt '%e errors found'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' verbose true
zstyle :compinstall filename '/home/kana/.zshrc'

autoload -Uz compinit
compinit




# Misc.  #{{{2

# Generate functions like the followings to enable the default completion of
# zsh for user-defined aliases of git commands.  Because such aliases aren't
# automatically recognized by zsh.
#
#   _git-$alias_name() {
#     _git-$original_command "$@"
#   }

_git  # FIXME: force loading as necessary
source <(
  git config --global --list |
    sed -e '/!/!s/^alias\.\([^=]*\)=\(.*\)$/\1 \2/;t;d' |
    awk '{
      print "_git-" $1 "() {"
      print "  _git-" $2 " \"\$@\""
      print "}"
    }'
)


# Don't show matches as a list for _history-complete-older and
# _history-complete-newer.  Because number of matches is usually very big so
# the list for them is annoying.

zstyle ':completion:history-words:*' list no








# __END__  #{{{1
# vim: filetype=zsh foldmethod=marker
