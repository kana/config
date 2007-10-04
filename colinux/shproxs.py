#!/usr/bin/env python
"""shproxs - a web server to run Windows commands from coLinux."""
__ID__ = '$Id$'
__VERSION__ = '0.0'

import BaseHTTPServer
import os
import re
import sys
import urllib




class MyHTTPRequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
  def version_string(self):
    return 'shprox/%s' % __VERSION__

  def do_GET(self):
    ip, port = self.client_address
    if ip != '127.0.0.1':
      return

    self.send_response(200)
    self.send_header('Content-Type', 'text/plain')
    self.end_headers()

    m = re.match(r'^/([^/]+)/(.+)', self.path)
    if not m:
      return

    action = m.group(1)
    argument = m.group(2)
    if action != 'run':
      return

    _stdin, stdout_stderr = os.popen4(urllib.unquote_plus(argument))
    self.wfile.write(stdout_stderr.read())
    return




def main():
  httpd = BaseHTTPServer.HTTPServer(('', 29552), MyHTTPRequestHandler)
  httpd.serve_forever()
  return

if __name__ == '__main__':
  sys.exit(main())

# __END__
