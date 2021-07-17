#!/usr/bin/python3
# -*- coding: utf-8 -*-
# pylint: disable=invalid-name

# System Imports
from os import system
from pathlib import PurePath

# Local Imports
from python_logger import create_logger  # pylint: disable=import-error


def main():
    logger = create_logger(PurePath(__file__).stem)

    logger.info("link greyhole spool")
    system("rm -rf /var/spool/greyhole")
    system("ln -s /mnt/config/spool /var/spool/greyhole")
    system("chmod 777 /var/spool/greyhole")

    logger.info("test greyhole config")
    system("greyhole --test-config")


if __name__ == "__main__":
    main()
