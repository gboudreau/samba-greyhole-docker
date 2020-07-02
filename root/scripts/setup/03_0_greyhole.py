#!/usr/bin/python3

# System Imports
from os import system
from pathlib import PurePath

# Local Imports
from python_logger import create_logger #pylint: disable=import-error

def main():
  logger = create_logger(PurePath(__file__).stem)

  logger.info('link greyhole config')
  system('rm -f etc/greyhole.conf')
  system('ln -s /mnt/config/greyhole.conf /etc/greyhole.conf')

  logger.info('link greyhole spool')
  system('rm -rf /var/spool/greyhole')
  system('ln -s /mnt/config/spool /var/spool/greyhole')
  system('chmod 777 /var/spool/greyhole')

if __name__ == "__main__":
  main()
