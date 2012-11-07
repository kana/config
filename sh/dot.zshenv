# /etc/zshenv seems to be changed between Mac OS X Leopard and Lion.
# Whenever a shell process is invoked as a child process of another shell,
# the order of directories in PATH is changed.  For example:
#
# * PATH="$ADDITIONAL_PATH:$DEFAULT_PATH" in the parent shell.
# * PATH="$DEFAULT_PATH:$ADDITIONAL_PATH" in the child shell.
#
# To avoid confusion, reset PATH to the one configured by my zprofile.

if [ "$CUSTOM_PATH" != '' ]  # Is the current process a subshell?
then
  PATH="$CUSTOM_PATH"
fi

# vim: filetype=zsh
