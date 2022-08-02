#!/usr/bin/env sh

## LOCATION:     /etc/pacman.d/scripts/dracut-install.sh
## AUTHOR:       AISK11
## DESCRIPTION:  Dracut configuration.
## DEPENDENCIES: system/coreutils

## Add numlock module to dracut.
if [ ! -d '/usr/lib/dracut/modules.d/50numlock' ]; then
    mkdir -p '/usr/lib/dracut/modules.d/50numlock'
    cat << EOF > '/usr/lib/dracut/modules.d/50numlock/module-setup.sh'
#!/usr/bin/env sh

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst /usr/bin/setleds
    inst_hook pre-trigger 50 "\${moddir}/numlock.sh"
}
EOF
    cat << EOF > '/usr/lib/dracut/modules.d/50numlock/numlock.sh'
#!/usr/bin/env sh

TTY=1
while [ ! "\${TTY}" = "9" ]; do
    /usr/bin/setleds -D +num < "/dev/tty\${TTY}"
    TTY="\$(( \${TTY} + 1 ))"
done
EOF
fi

## Change dracut's default initramfs scripts to do nothing.
[ -f '/usr/share/libalpm/scripts/dracut-install' ] && \
    cat <<EOF > '/usr/share/libalpm/scripts/dracut-install'
#!/usr/bin/env sh
exit 0
EOF
[ -f '/usr/share/libalpm/scripts/dracut-remove' ] && \
    cat <<EOF > '/usr/share/libalpm/scripts/dracut-remove'
#!/usr/bin/env sh
exit 0
EOF
exit 0
