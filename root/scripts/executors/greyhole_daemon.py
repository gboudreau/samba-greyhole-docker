#!/usr/bin/python3

from os import kill
from pathlib import PurePath
from signal import SIGINT
from signal import SIGKILL
from signal import signal
from signal import SIGTERM
from subprocess import Popen
from sys import exit as sys_exit
from time import sleep

# Local Imports
from python_logger import create_logger #pylint: disable=import-error

#pylint: disable=global-statement

GREYHOLE_PID = -1
PHP_PID = -1

def check_pid(pid):
  """ Check For the existence of a unix pid. """
  try:
    kill(pid, 0)
  except OSError:
    return False
  else:
    return True

def stop_greyhole(_signal_number, _stack_frame):
  logger = create_logger(PurePath(__file__).stem)
  logger.info('Stopping Greyhole.')

  kill(PHP_PID, SIGKILL)
  kill(GREYHOLE_PID, SIGKILL)

  sys_exit(0)

signal(SIGINT, stop_greyhole)
signal(SIGTERM, stop_greyhole)

def main():
  logger = create_logger(PurePath(__file__).stem)
  global GREYHOLE_PID
  global PHP_PID

  logger.info('Starting PHP')
  PHP_PID = Popen(['/usr/bin/php']).pid

  logger.info('Starting Greyhole')
  GREYHOLE_PID = Popen(['/usr/bin/greyhole', '--daemon']).pid

  while check_pid(PHP_PID) and check_pid(GREYHOLE_PID):
    sleep(1)

  if not check_pid(PHP_PID):
    logger.info('PHP Exited on its own')

  if not check_pid(GREYHOLE_PID):
    logger.info('Greyhole Exited on its own')

  kill(PHP_PID, SIGKILL)
  kill(GREYHOLE_PID, SIGKILL)

  # ideally this will never happen
  sys_exit(1)

if __name__ == '__main__':
  main()
