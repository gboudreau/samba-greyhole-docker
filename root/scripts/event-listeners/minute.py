#!/usr/bin/python3

import sys
from os import system

def write_stdout(string_to_write):
  # only eventlistener protocol messages may be sent to stdout
  sys.stdout.write(string_to_write)
  sys.stdout.flush()

def write_stderr(string_to_write):
  sys.stderr.write(string_to_write)
  sys.stderr.flush()


def main():
  while True:
    # transition from ACKNOWLEDGED to READY
    write_stdout('READY\n')

    # block for trigger
    sys.stdin.read()

    system('greyhole --process-spool --keepalive')

    # transition from READY to ACKNOWLEDGED
    write_stdout('RESULT 2\nOK')

if __name__ == '__main__':
  main()
