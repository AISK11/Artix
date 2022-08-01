#!/usr/bin/env sh

## LOCATION:     /etc/pacman.d/scripts/boot-remove.sh
## AUTHOR:       AISK11
## DESCRIPTION:  Clean boot directory from ucode(s), kernel(s) and
##               initramfs(es).
## DEPENDENCIES: system/coreutils system/grep

## Remove ucode from target dir.
remove_ucode() {
    rm -f "${TARGET}/${1}.img"
}

## Remove kernel from target dir.
remove_kernel() {
    rm -f "${TARGET}/vmlinuz-${1}"
    remove_initramfs "${1}"
}

## Remove initramfs from target dir.
remove_initramfs() {
    rm -f "${TARGET}/initramfs-${1}.img"
}

## Prepare target dir.
[ ! -z "${1}" ] && TARGET="${1}" || TARGET='/boot/EFI/artix'
[ ! -d "${TARGET}/" ] && exit 0

## Determine which package is being removed.
while read -r INPUT; do
    [ ! "${INPUT%-ucode}" = "${INPUT}" ] && remove_ucode "${INPUT}"
    [ ! "${INPUT#linux}" = "${INPUT}" ] && remove_kernel "${INPUT}"
done

## Remove empty directories left behind.
while [ 'true' ]; do
    grep -w "${TARGET}" /etc/mtab > /dev/null && break
    rmdir "${TARGET}/" 2> /dev/null || break
    TARGET="${TARGET%/*}"
done
exit 0
