# My .bash_profile

source ~/.sh_common_login




IGNOREEOF=1  # Don't export -- only set for the login shell.




_check_then_source() {  # script-path
  if [ -e "$1" ]; then
    source "$1"
  fi
}

_check_then_source ~/.bashrc

unset -f _check_then_source

# __END__
# vim: filetype=sh
