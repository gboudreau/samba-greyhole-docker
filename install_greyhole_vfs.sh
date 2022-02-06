#!/bin/bash

arch=$(uname -m)
version=$(/usr/sbin/smbd --version | awk '{print $2}' | awk -F'-' '{print $1}')
V=$(echo "${version}" | awk -F'.' '{print $1$2}')
vfs_file="greyhole-samba${V}-alpine-${arch}.zip"
curl -sLO "https://www.greyhole.net/releases/$vfs_file"

if file "$vfs_file" | grep HTML >/dev/null; then
    rm -f "$vfs_file"
    echo "Compiling new greyhole.so VFS using Samba source..."
    if ! TERM=xterm GREYHOLE_INSTALL_DIR=$(pwd) bash ./build_vfs.sh current; then
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
    # To copy to web server:
    apk add zip >/dev/null
    zip -r "$vfs_file" vfs-build/
    apk del zip >/dev/null
    echo
    echo "$vfs_file file created. You can copy it to the host using:"
    echo "  id=\$(sudo docker create samba-greyhole:latest)"
    sudo "  sudo docker cp \$id:$(pwd)/$vfs_file ."
    echo
else
    echo "Using pre-compiled greyhole.so VFS from greyhole.net/releases/$vfs_file"
    rm -rf vfs-build
    unzip "$vfs_file" >/dev/null
    ln -s "$(pwd)"/vfs-build/samba-*/greyhole-samba"${V}".so /usr/lib/samba/vfs/greyhole.so
    rm -f "$vfs_file"
fi

rm -rf samba-module
