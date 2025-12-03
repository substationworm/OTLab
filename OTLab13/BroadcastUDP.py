#!/usr/bin/env python3
import socket
import time

BROADCAST_IP = "172.30.20.15"
PORT = 15000
MSG = b"OTLab13{Connection_Timed_Out}"

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

while True:
    sock.sendto(MSG, (BROADCAST_IP, PORT))
    time.sleep(60)