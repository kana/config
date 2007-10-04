#!/usr/bin/env python
"""shproxs - a web server to run Windows commands from coLinux."""
__ID__ = '$Id$'
__VERSION__ = '0.0'

import BaseHTTPServer
import os
import re
import sys
import urllib




class MyHTTPServer(BaseHTTPServer.HTTPServer):
  def __init__(self, server_address, RequestHandlerClass):
    BaseHTTPServer.HTTPServer.__init__(self,
                                       server_address,
                                       RequestHandlerClass)
    self.quit_flag = False
    return

  def quit(self):
    self.quit_flag = True
    return

  def serve_forever(self):
    while not self.quit_flag:
      self.handle_request()
    return


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

    m = re.match(r'^/([^/]+)(?:/(.*))?', self.path)
    if not m:
      return

    action_name = m.group(1).upper()
    argument = m.group(2)
    if argument is None:
      argument = ''
    action = getattr(self, 'action_'+action_name, self.action_DEFAULT)
    action(argument)
    return

  def action_DEFAULT(self, argument):
    """Dummy action, nop."""
    return

  def action_RUN(self, argument):
    """Run the given argument as a command."""
    _stdin, stdout_stderr = os.popen4(urllib.unquote_plus(argument))
    self.wfile.write(stdout_stderr.read())
    return

  def action_QUIT(self, argument):
    """Quit the server."""
    print >>self.wfile, 'Shutdown will be started soon ...'
    self.server.quit()
    return




def main():
  httpd = MyHTTPServer(('', 29552), MyHTTPRequestHandler)
  httpd.serve_forever()
  return

if __name__ == '__main__':
  sys.exit(main())

# __END__
