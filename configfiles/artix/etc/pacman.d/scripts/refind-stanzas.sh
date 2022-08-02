#!/usr/bin/env sh

## LOCATION:     /etc/pacman.d/scripts/refind-stanzas.sh
## AUTHOR:       AISK11
## DESCRIPTION:  Dynamically update static refind entries (stanzas).
## DEPENDENCIES: system/coreutils system/grep system/filesystem system/findutils

## Make sure, that EFI System Partition (ESP) is mounted in '/boot/' or edit
## this file accordingly!

## Prepare artix kernel directory.
[ ! -z "${1}" ] && TARGET="${1}" || TARGET='/boot/EFI/artix'
[ ! -d "${TARGET}/" ] && mkdir -p "${TARGET}/"

## Prepare rEFInd dir.
[ ! -z "${2}" ] && STANZAS="${2}" || STANZAS='/boot/EFI/BOOT/stanzas-artix.conf'
[ ! -d $(dirname "${STANZAS}") ] && mkdir -p $(dirname "${STANZAS}")

## ESP variables.
TARGET_MOUNT="${TARGET}"
while [ 'true' ]; do
    grep -w "${TARGET_MOUNT}" /etc/mtab > /dev/null 2>&1 && break
    TARGET_MOUNT="${TARGET_MOUNT%/*}"
done

## Block device variables.
ROOT_DEVICE=$(grep -w '/' /etc/mtab | tail -n 1 | cut -d ' ' -f 1)

## Fill 'stanzas.conf' with entries.
cat << EOF > "${STANZAS}"
## LOCATION:     ${STANZAS}
## AUTHOR:       Generated by "/etc/pacman.d/scripts/refind-stanzas.sh"
## DESCRIPTION:  Configuration for rEFInd bootloader containing static entries.
## DEPENDENCIES: omniverse/refind

EOF

## Add static entries to refind's stanzas config file.
for KERNEL in "${TARGET}"/vmlinuz*; do
    ## Entry name.
    if [ $(basename "${KERNEL}") = 'vmlinuz-linux' ]; then
        echo 'menuentry "Artix" {' >> "${STANZAS}"
        INITRAMFS="${TARGET}/initramfs-linux.img"
    elif [ $(basename "${KERNEL}") = 'vmlinuz-linux-hardened' ]; then
        echo 'menuentry "Artix Hardened" {' >> "${STANZAS}"
        INITRAMFS="${TARGET}/initramfs-linux-hardened.img"
    elif [ $(basename "${KERNEL}") = 'vmlinuz-linux-lts' ]; then
        echo 'menuentry "Artix LTS" {' >> "${STANZAS}"
        INITRAMFS="${TARGET}/initramfs-linux-lts.img"
    elif [ $(basename "${KERNEL}") = 'vmlinuz-linux-zen' ]; then
        echo 'menuentry "Artix Zen" {' >> "${STANZAS}"
        INITRAMFS="${TARGET}/initramfs-linux-zen.img"
    fi

    ## Entry icon.
    ICON=$(find $(dirname "${STANZAS}")'/themes' -regex '.*os_artix.png$' | \
        head -n 1)
    [ -z "${ICON}" ] && ICON=$(dirname "${STANZAS}")'/icons/os_linux.png'
    echo "    icon    ${ICON#${TARGET_MOUNT}}" >> "${STANZAS}"

    ## Entry kernel.
    echo "    loader  ${KERNEL#${TARGET_MOUNT}}" >> "${STANZAS}"

    ## Entry options.
    OPTIONS="quiet rw root=${ROOT_DEVICE}"
    for UCODE in "${TARGET}"/*-ucode.img; do
        OPTIONS="${OPTIONS} initrd=${UCODE#${TARGET_MOUNT}}"
    done
    [ -f "${INITRAMFS}" ] && \
        OPTIONS="${OPTIONS} initrd=${INITRAMFS#${TARGET_MOUNT}}"
    echo "    options \"${OPTIONS}\"" >> "${STANZAS}"

    ## Submenu with debug kernel parameter.
    echo '    submenuentry "Debug" {' >> "${STANZAS}"
    echo "        loader  ${KERNEL#${TARGET_MOUNT}}" >> "${STANZAS}"
    OPTIONS=$(echo "${OPTIONS}" | sed 's/\<quiet\>/rd.debug/g')
    echo "        options \"${OPTIONS}\"" >> "${STANZAS}"
    echo "    }" >> "${STANZAS}"
    echo "}" >> "${STANZAS}"
done
exit 0
