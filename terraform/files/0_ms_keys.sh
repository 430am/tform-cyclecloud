#!/bin/sh
# This script is used to install the Microsoft GPG keys for the Microsoft package repositories. It is intended to be run on a Debian-based Linux distribution, such as Ubuntu.

mkdir -m 0755 -p /etc/apt/keyrings 
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/keyrings/microsoft.gpg > /dev/null
chmod go+r /etc/apt/keyrings/microsoft.gpg