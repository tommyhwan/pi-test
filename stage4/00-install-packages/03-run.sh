#!/bin/bash -e

on_chroot << EOF
cat /etc/apt/sources.list > sources.orig
echo 'deb http://archive.raspbian.org/raspbian/ buster main contrib non-free rpi' >> /etc/apt/sources.list
apt-get update
apt-get install -y libglib2.0-dev -t buster
cat sources.orig > /etc/apt/sources.list
EOF

on_chroot << EOF
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 379ce192d401ab61
cat /etc/apt/sources.list > sources.orig
echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list
apt-get update
apt-get remove -y openssl
apt-get install -y -f openssl -t jessie-backports --allow-unauthenticated
cat sources.orig > /etc/apt/sources.list
apt-get update
apt-get install -y -f libqt5gui5
EOF

on_chroot << EOF
cat /etc/apt/sources.list > sources.orig
echo 'deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi'  >> /etc/apt/sources.list
apt-get update
apt-get install -y libopenexr-dev -t jessie
cat sources.orig > /etc/apt/sources.list
apt-get update
EOF
