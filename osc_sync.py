from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import BlockingOSCUDPServer
import socket

def default_handler(address, *args):
  print(f"DEFAULT{address}: {args}")

if __name__ == "__main__":
  dispatcher = Dispatcher()
  dispatcher.set_default_handler(default_handler)
  ip = socket.gethostbyname("10.10.143.255")
  port = 6575

  server = BlockingOSCUDPServer((ip,port), dispatcher)
  server.serve_forever()
