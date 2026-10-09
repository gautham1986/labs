#!/usr/bin/env python3
"""minicache - a tiny Redis-protocol-ish cache server (answers PING with +PONG).

usage: minicache [--port PORT] [--bind ADDR]   (default 127.0.0.1:6379)
"""
import argparse, socketserver

p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
p.add_argument("--port", type=int, default=6379)
p.add_argument("--bind", default="127.0.0.1")
a = p.parse_args()


class H(socketserver.StreamRequestHandler):
    def handle(self):
        for line in self.rfile:
            cmd = line.strip().upper()
            if cmd == b"PING":
                self.wfile.write(b"+PONG\r\n")
            elif cmd == b"QUIT":
                return
            else:
                self.wfile.write(b"-ERR unknown command\r\n")


socketserver.ThreadingTCPServer.allow_reuse_address = True
print(f"minicache listening on {a.bind}:{a.port}", flush=True)
socketserver.ThreadingTCPServer((a.bind, a.port), H).serve_forever()
