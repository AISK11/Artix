#!/usr/bin/env sh

## LOCATION:     /etc/pacman.d/scripts/dracut-remove.sh
## AUTHOR:       AISK11
## DESCRIPTION:  Dracut deconfiguration.
## DEPENDENCIES: system/coreutils

## Remove dracut's numlock module.
rm -rf '/usr/lib/dracut/modules.d/50numlock'

## Remove empty dracut directories left behind.
DIR="/usr/lib/dracut/modules.d"
while [ ! "${DIR}" = "/usr/lib" ]; do
    rmdir "${DIR}/" 2> /dev/null || break
    DIR="${DIR%/*}"
done
exit 0
