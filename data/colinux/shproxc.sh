#!/bin/bash
# shproxc - wrapper client for shproxs.

function escape()
{
  perl -pe 's/(\W)/"%".unpack("H2",$1)/eg;'
}

function main()
{
  local DEFAULT_PORT=29552

  if [ $# = 1 ] || [ $# = 2 ]; then
    if [ "${1/:/}" = "$1" ]; then
      local server="$1"
      local port=$DEFAULT_PORT
    else
      local server="${1%:*}"
      local port="${1#*:}"
    fi
    if [ $# = 1 ]; then
      local command="$(escape)"
    else
      local command="$(echo -n "$2" | escape)"
    fi
  else
    echo "Usage: shproxc server[:port=$DEFAULT_PORT] [command]"
    echo "   or: shproxc server[:port=$DEFAULT_PORT] quit"
    echo ''
    echo 'Run {command} in the host which runs {server}.'
    echo 'If {command} is ommitted, read it from stdin.'
    echo ''
    echo 'The latter usage will quit {server}.'
    return 1
  fi

  if [ "$command" = 'quit' ]; then
    curl --silent "http://$server:$port/quit"
  else
    curl --silent "http://$server:$port/run/$command"
  fi
  return 0
}

main "$@"

# __END__
