#!/usr/bin/env python

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
import sys
import os
import socket
import httplib

port = int(os.environ['CLIENT_PORT'])
target = int(os.environ['HTTP_PORT'])

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        global target
        if self.path.endswith("qpid0"):
            offset = 0
        else:
            offset = 0
        target = target + offset

        conn = httplib.HTTPConnection("localhost", target, timeout=10)
        conn.request("GET", "/")
        target_resp = conn.getresponse()
        status = target_resp.status
        body = target_resp.read()

        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        resp = '<h1>Original Dest Routing to localhost:' + str(target) + ' Status=' + str(status) + '</h1><p>' + body
        self.wfile.write(resp)

    def do_POST(self):
        print('POSTing')
        self.send_response(200)

    do_PUT = do_POST
    do_DELETE = do_GET

print('Client listening on port ' + str(port) + ' and server is on ' + str(target) + ' ...')
server = HTTPServer(('',port), RequestHandler)
server.serve_forever()
