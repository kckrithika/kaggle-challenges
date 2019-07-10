#!/usr/bin/env python

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
import sys
import os
import socket
import httplib

port = int(os.environ['CLIENT_PORT'])

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.endswith("/"):
            resp = '<h1>No target specified for Original Dest Routing</h1>'
        else:
            addr = self.path[1:]
            tokens = addr.split(':')
            if len(tokens) == 2:
                target = int(tokens[1])
                addr = tokens[0]
            else:
                target = int(addr)
                addr = 'localhost'
            conn = httplib.HTTPConnection(addr, target, timeout=10)
            conn.request("GET", "/")
            target_resp = conn.getresponse()
            status = target_resp.status
            body = target_resp.read()
            resp = '<h1>Original Dest Routing to ' + addr + ':' + str(target) + ' Status=' + str(status) + '</h1><p>' + body

        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        self.wfile.write(resp)

    def do_POST(self):
        print('POSTing')
        self.send_response(200)

    do_PUT = do_POST
    do_DELETE = do_GET

print('Client listening on port ' + str(port) + ' ...')
server = HTTPServer(('',port), RequestHandler)
server.serve_forever()
