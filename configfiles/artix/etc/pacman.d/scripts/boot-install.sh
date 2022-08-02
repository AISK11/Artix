#!/usr/bin/env sh

## LOCATION:     /etc/pacman.d/scripts/boot-install.sh
## AUTHOR:       AISK11
## DESCRIPTION:  Set up boot directory for ucode(s), kernel(s) and
##               initramfs(es).
## DEPENDENCIES: system/coreutils system/grep system/file [world/dracut]

## Move ucode from default install dir ("/boot/") to target dir.
move_ucode() {
    mv "${1}" "${TARGET}/"
}

## Copy kernel from default install dir ("/usr/lib/modules/$(uname -r)/vmlinuz")
## to target dir.
copy_kernel() {
    TYPE=$(cat "${1}/pkgbase")
    cp "${1}/vmlinuz" "${TARGET}/vmlinuz-${TYPE}"
    command -v dracut > /dev/null && generate_initramfs "${TYPE}"
}

## Generate initramfs for kernel in target dir.
generate_initramfs() {
    VERSION=$(file "${TARGET}/vmlinuz-${1}" | grep -o 'version.*' | \
        cut -d ' ' -f 2)
    dracut -f "${TARGET}/initramfs-${1}.img" --kver "${VERSION}" -H -L 3
}

## Prepare target dir.
[ ! -z "${1}" ] && TARGET="${1}" || TARGET='/boot/EFI/artix'
[ ! -d "${TARGET}/" ] && mkdir -p "${TARGET}/"

## Determine which package is being installed/updated.
while read -r INPUT; do
    INPUT="/${INPUT}"
    if [ ! "${INPUT%-ucode.img}" = "${INPUT}" ]; then
        move_ucode "${INPUT}"
    elif [ ! "${INPUT%pkgbase}" = "${INPUT}" ]; then
        copy_kernel "${INPUT%/*}"
    fi
done
exit 0
