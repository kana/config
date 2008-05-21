#!/usr/bin/env python

import BaseHTTPServer
import os
import sys




class MyHTTPRequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
  def version_string(self):
    return 'coLinux boot checker/0.0'

  def do_GET(self):
    ip, port = self.client_address
    if ip == '127.0.0.1':
      self.send_response(200)
      self.send_header('Content-Type', 'text/plain')
      self.end_headers()
      print >>self.wfile, 'I see.'
      os.system("msg %s 'I see.'" % os.environ['USER'])
    else:
      pass
    return




def main():
  httpd = BaseHTTPServer.HTTPServer(('', 19001), MyHTTPRequestHandler)
  httpd.handle_request()
  return

if __name__ == '__main__':
  sys.exit(main())

# __END__
