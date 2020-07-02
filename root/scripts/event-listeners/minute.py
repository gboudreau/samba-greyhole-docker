#!/usr/bin/python3

import sys
from os import system

def write_stdout(s):
  # only eventlistener protocol messages may be sent to stdout
  sys.stdout.write(s)
  sys.stdout.flush()

def write_stderr(s):
  sys.stderr.write(s)
  sys.stderr.flush()

def main():
  while True:
    # transition from ACKNOWLEDGED to READY
    write_stdout('READY\n')

    system('greyhole --process-spool --keepalive')

    # transition from READY to ACKNOWLEDGED
    write_stdout('RESULT 2\nOK')

if __name__ == '__main__':
    main()
