#!/bin/bash

version=$(/usr/sbin/smbd --version | awk '{print $2}' | awk -F'-' '{print $1}')
V=$(echo "${version}" | awk -F'.' '{print $1$2}')
curl -sLO "https://www.greyhole.net/releases/greyhole-samba${V}-alpine.zip"

if file "greyhole-samba${V}-alpine.zip" | grep HTML >/dev/null; then
    echo "Compiling new greyhole.so VFS using Samba source..."
    if ! TERM=xterm GREYHOLE_INSTALL_DIR=$(pwd) bash ./build_vfs.sh current; then
        rm -f "greyhole-samba${V}-alpine.zip"
        exit 1
    fi
    cp -Lr vfs-build/samba-*/bin/shared ./samba-bin-shared
    mv vfs-build/samba-*/greyhole-samba*.so .
    rm -rf vfs-build/samba-*/*
    mkdir "vfs-build/$(ls -1 vfs-build | grep samba-)/bin"
    mv samba-bin-shared "vfs-build/$(ls -1 vfs-build | grep samba-)/bin/shared"
    mv greyhole-samba*.so "vfs-build/$(ls -1 vfs-build | grep samba-)/"
    (cd vfs-build/ ; rm -rf .git* .lock-wscript .testr.conf .ycm_extra_conf.py)
    (cd "vfs-build/$(ls -1 vfs-build | grep samba-)/" ; rm -rf .git* .lock-wscript .testr.conf .ycm_extra_conf.py)
else
    echo "Using pre-compiled greyhole.so VFS from greyhole.net/releases/greyhole-samba${V}-alpine.zip"
    rm -rf vfs-build
    unzip "greyhole-samba${V}-alpine.zip" >/dev/null
    ln -s "$(pwd)"/vfs-build/samba-*/greyhole-samba"${V}".so /usr/lib/samba/vfs/greyhole.so
fi

rm -f "greyhole-samba${V}-alpine.zip"
rm -rf samba-module
