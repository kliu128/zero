import json
import socket
import subprocess
import sys

from pexpect import pxssh

def is_port_open(ip: str, port: int):
  sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  result = sock.connect_ex((ip, port))
  return result == 0


with open("/keys/ssh-unlocker/hosts.json") as hosts_file:
  hosts = json.load(hosts_file)
  for host in hosts:
    print("Processing host " + str(host))
    port_open = is_port_open(host["ip"], host["port"])
    print("SSH port open? " + str(port_open))
    if port_open:
      try:
        print("Attempting to remote-unlock LUKS.")
        ssh = pxssh.pxssh(options={"UserKnownHostsFile": "/keys/ssh-unlocker/known_hosts"})
        ssh.login(host["ip"], "root",
                  port=host["port"],
                  ssh_key="/keys/ssh-unlocker/unlocker_id_rsa")
        ssh.sendline("cryptsetup-askpass")
        ssh.sendline(host["password"])
        ssh.prompt()
        ssh.logout()
      except Exception as e:
        print("Got an exception (not necessarily fatal, might have worked): " + str(e))
        print("Continuing.")
    else:
      print("SSH port not present, not unlocking.")

print("Reached end of list.")