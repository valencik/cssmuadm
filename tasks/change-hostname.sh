#!/usr/bin/env bash
set -e

#Set hostname
hostnamectl set-hostname $NEW_HOSTNAME
sed -i 's/127.0.1.1.*/127.0.1.1\t'"$NEW_HOSTNAME"'/g' /etc/hosts
