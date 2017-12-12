#!/bin/bash -e

on_chroot << EOF
wget -qO - https://mirrordirector.raspbian.org/raspbian.public.key | sudo apt-key add -
add-apt-repository 'deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi'
add-apt-repository 'deb-src http://archive.raspbian.org/raspbian/ stretch main contrib non-free rpi'
add-apt-repository 'deb http://archive.raspbian.org/raspbian/ buster main contrib non-free rpi'
apt-get update -y
apt-get upgrade -y
apt-get install -y -f openssl=1.0.2 libglib2.0-dev
add-apt-repository -r 'deb http://archive.raspbian.org/raspbian/ buster main contrib non-free rpi'
EOF

# on_chroot << EOF
# add-apt-repository 'deb http://ftp.debian.org/debian jessie-backports main'
# apt-get update -y
# apt-get upgrade -y
# apt-get remove -y openssl
# apt-get install -y -f openssl=1.0.2 libssl=1.0.0
# add-apt-repository -r 'deb http://ftp.debian.org/debian jessie-backports main'
# EOF
#
# on_chroot << EOF
# add-apt-repository 'deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi'
# apt-get update -y
# apt-get upgrade -y
# apt-get install -y -f qt4-xll libqt5gui5
# dd-apt-repository -f 'deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi'
# EOF
