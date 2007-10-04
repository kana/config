#!/bin/bash
# shproxc - wrapper client for shproxs.

function escape()
{
  perl -pe 's/(\W)/"%".unpack("H2",$1)/eg;'
}

function main()
{
  if [ $# = 1 ] || [ $# = 2 ]; then
    if [ "${1/:/}" = "$1" ]; then
      local server="$1"
      local port=29552
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
    echo 'Usage: shproxc server[:port] [command]'
    echo 'if command is ommitted, read from stdin.'
    return 1
  fi

  curl --silent "http://$server:$port/run/$command"
  return 0
}

main "$@"

# __END__
