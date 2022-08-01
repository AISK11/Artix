#!/usr/bin/env sh

## LOCATION:     /etc/pacman.d/scripts/opendoas-remove.sh
## AUTHOR:       AISK11
## DESCRIPTION:  Opendoas deconfiguration.
## DEPENDENCIES: system/coreutils system/grep system/shadow

## Remove doas group.
cat /etc/group | grep '^doas:' && groupdel doas

## Remove doas configuration file.
rm -f /etc/doas.conf
exit 0
