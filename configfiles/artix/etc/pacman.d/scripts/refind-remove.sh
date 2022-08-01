#!/usr/bin/env sh

## LOCATION:     /etc/pacman.d/scripts/refind-remove.sh
## AUTHOR:       AISK11
## DESCRIPTION:  Refind deconfiguration.
## DEPENDENCIES: -

## Make sure, that EFI System Partition (ESP) is mounted in '/boot/' or edit
## this file accordingly!

## Prepare target dir.
[ ! -z "${1}" ] && TARGET="${1}" || TARGET='/boot/EFI/BOOT'

## Remove refind application to target + fallback (<ESP>/EFI/BOOT/BOOTX64.EFI).
rm -f "${TARGET}/refind_x64.efi"
rm -f "${TARGET}/BOOTX64.EFI"

## Remove refind icons, fonts and themes.
rm -rf "${TARGET}/icons/" "${TARGET}/fonts/" "${TARGET}/themes/"

## Remove refind configuration file and stanzas config file if exists.
rm -f "${TARGET}/refind.conf"
[ -f "${TARGET}/stanzas-artix.conf" ] && rm -f "${TARGET}/stanzas-artix.conf"

## Remove empty directories left behind.
while [ 'true' ]; do
    grep -w "${TARGET}" /etc/mtab > /dev/null && break
    rmdir "${TARGET}/" 2> /dev/null || break
    TARGET="${TARGET%/*}"
done

## ESP variables.
TARGET_MOUNT="${TARGET}"
while [ 'true' ]; do
    grep -w "${TARGET_MOUNT}" /etc/mtab > /dev/null && break
    TARGET_MOUNT="${TARGET_MOUNT%/*}"
    if [ -z "${TARGET_MOUNT}" ]; then
        TARGET_MOUNT='/'
        break
    fi
done
REFIND="${TARGET#${TARGET_MOUNT}}/refind_x64.efi"

## Block device and partition variables.
DEVICE=$(grep "${TARGET_MOUNT}" /etc/mtab | tail -n 1 | cut -d ' ' -f 1)
if [ ! "${DEVICE#/dev/nvme}" = "${DEVICE}" ]; then
    PARTITION="${DEVICE#/dev/nvme[0-9]*n[0-9]*p}"
elif [ ! "${DEVICE#/dev/sd}" = "${DEVICE}" ]; then
    PARTITION=$(echo "${DEVICE}" | grep -o '[0-9]*$')
elif [ ! "${DEVICE#/dev/hd}" = "${DEVICE}" ]; then
    PARTITION=$(echo "${DEVICE}" | grep -o '[0-9]*$')
elif [ ! "${DEVICE#/dev/mmcblk}" = "${DEVICE}" ]; then
    PARTITION="${DEVICE#/dev/mmcblk[0-9]*p}"
fi
PARTUUID=$(blkid | grep "${DEVICE}" | grep -o "PARTUUID.*" | cut -d '=' -f 2 | \
    tr -d '"')

## UEFI NVRAM variables.
NVRAM_ENTRY=$(efibootmgr | tr '\\\\' '/' | grep -i "${REFIND}" | \
    grep "(${PARTITION}," | grep "${PARTUUID}" | cut -d '*' -f 1 | \
    grep -o '[0-9]*')

## Remount efivars to be RW if RO.
grep '/sys/firmware/efi/efivars' /etc/mtab | grep -w 'ro' > /dev/null && \
    mount -o remount,rw /sys/firmware/efi/efivars

## Remove all rEFInd entries from UEFI NVRAM.
if [ ! -z "${NVRAM_ENTRY}" ]; then
    echo "${NVRAM_ENTRY}" | while read ENTRY; do
        efibootmgr -b "${ENTRY}" -B
    done
fi

## Remount efivars to be RO.
grep '/sys/firmware/efi/efivars' /etc/mtab | grep -w 'rw' > /dev/null && \
    mount -o remount,ro /sys/firmware/efi/efivars
exit 0
