#!/usr/bin/env python

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
import sys
import os
import socket

port = int(os.environ['AMQP_PORT'])

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        host = socket.gethostname()
        addr = socket.gethostbyname(host)
        resp = '<h1>Response from ' + addr + ' (' + host + ')</h1>'
        self.wfile.write(resp)

    def do_POST(self):
        print('POSTing')
        self.send_response(200)

    do_PUT = do_POST
    do_DELETE = do_GET

print('Listening on port ' + str(port) + '...')
server = HTTPServer(('',port), RequestHandler)
server.serve_forever()
