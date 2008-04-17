import sys

def include(file):
  for _ in file:
    if _.startswith('INCLUDE'):
      include(open(_[:-1].split(None, 1)[1]))
    else:
      sys.stdout.write(_)
  return

include(sys.stdin)
