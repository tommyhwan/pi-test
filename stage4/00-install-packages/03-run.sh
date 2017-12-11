#!/bin/bash -e

on_chroot << EOF
wget -qO - https://http://mirrordirector.raspbian.org/raspbian.public.key sudo apt-key add -
add-apt-repository 'deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi'
add-apt-repository 'deb-src http://archive.raspbian.org/raspbian/ stretch main contrib non-free rpi'
add-apt-repository 'deb-src http://archive.raspbian.org/raspbian/ buster main contrib non-free rpi'

apt-get update -y
apt-get upgrade -y
apt-get install -y -f libglib2.0-dev
add-apt-repository -r 'deb-src http://archive.raspbian.org/raspbian/ buster main contrib non-free rpi'
EOF

# on_chroot << EOF
# add-apt-repository 'deb http://ftp.debian.org/debian jessie-backports main'
#
#
# EOF
