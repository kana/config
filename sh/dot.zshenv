# /etc/zshenv seems to be changed between Max OS X Leopard and Lion.
# Whenever a shell process is invoked as a child process of another shell,
# the order of directories in PATH is changed.  For example:
#
# * PATH="$ADDITIONAL_PATH:$DEFAULT_PATH" in the parent shell.
# * PATH="$DEFAULT_PATH:$ADDITIONAL_PATH" in the child shell.
#
# To avoid confusion, reorder PATH to be the same order as the parent shell.

if [ "$DEFAULT_PATH" = '' ]  # Is the current process invoked as a login shell?
then
  export DEFAULT_PATH="$PATH"
else
  PATH="${PATH/$DEFAULT_PATH:/}:$DEFAULT_PATH"
fi

# vim: filetype=zsh
