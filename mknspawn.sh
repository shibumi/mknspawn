#!/usr/bin/env bash
#
# mknspawn.sh - a systemd-nspawn wrapper written in shell
#
# Copyright (c) 2017 by Christian Rebischke <chris.rebischke@archlinux.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http: #www.gnu.org/licenses/
#
#======================================================================
# Author: Christian Rebischke
# Email : chris.rebischke@archlinux.org
# Github: www.github.com/Shibumi
#
#
#
# vim:set et sw=4 ts=4 tw=72:
#

if [ "$(uid -u)" != "0" ]; then
    echo "[+] You need sudo.."
    exit 1
fi

CONTAINER_NAME="$1"
DISTRIBUTION="$2"
RELEASE="$3"
MACHINED_DIR="/var/lib/machines/"
SSH_KEY="/home/chris/.ssh/archlinux.pub"


case $DISTRIBUTION in
    "ubuntu")
         debootstrap --include dbus,vim,less,tmux,openssl,openssh-server "$RELEASE" "$MACHINED_DIR$CONTAINER_NAME" http://archive.ubuntu.com/ubuntu/ > /dev/null
         ;;

    "debian")
         debootstrap --include dbus,vim,less,tmux,openssl,openssh-server "$RELEASE" "$MACHINED_DIR$CONTAINER_NAME" > /dev/null
         ;;
    *)
        echo "[-] sorry ubuntu and debian only"
        exit 2
esac

if [ -d "$MACHINED_DIR$CONTAINER_NAME" ]; then
    echo "pts/0" >> "$MACHINED_DIR$CONTAINER_NAME/etc/securetty"
    mkdir -m700 "$MACHINED_DIR$CONTAINER_NAME/root/.ssh"
    install -m600 "$SSH_KEY" "$MACHINED_DIR$CONTAINER_NAME/root/.ssh/authorized_keys"
    machinectl start "$CONTAINER_NAME"
    machinectl shell "$CONTAINER_NAME" systemctl enable systemd-networkd
    machinectl shell "$CONTAINER_NAME" systemctl enable systemd-resolved
    machinectl shell "$CONTAINER_NAME" systemctl enable sshd
    machinectl shell "$CONTAINER_NAME" passwd -d root

else
    echo "[-] target directory $MACHINED_DIR$CONTAINER_NAME does not exist!"
    exit 3
fi
