#!/usr/bin/python3

from os import kill
from sys import exit as sys_exit
from subprocess import run
from subprocess import Popen
from pathlib import PurePath
from os import system
from signal import signal
from signal import SIGINT
from signal import SIGTERM
from signal import SIGKILL
from time import sleep

# Local Imports
from python_logger import create_logger #pylint: disable=import-error

GREYHOLE_PID = -1

def check_pid(pid):
    """ Check For the existence of a unix pid. """
    try:
        kill(pid, 0)
    except OSError:
        return False
    else:
        return True

def stop_greyhole():
  logger = create_logger(PurePath(__file__).stem)
  logger.info('Stopping Greyhole.')
  kill(GREYHOLE_PID, SIGKILL)
  sys_exit(0)

signal(SIGINT, stop_greyhole)
signal(SIGTERM, stop_greyhole)

def main():
  logger = create_logger(PurePath(__file__).stem)
  global GREYHOLE_PID

  niceness = -1
  with open("/etc/greyhole.conf") as config:
    for line in config:
      line = line.strip()
      if line.startswith('daemon_niceness'):
        niceness = int(line.split('=')[1])
        break

  GREYHOLE_PID = Popen(['/bin/nice', '-n', f'{niceness}', '/usr/bin/php', '/usr/bin/greyhole', '--daemon']).pid

  while check_pid(GREYHOLE_PID):
    sleep(1)

  # ideally this will never happen
  sys_exit(1)

if __name__ == '__main__':
    main()
