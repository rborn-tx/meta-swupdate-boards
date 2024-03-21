do_install:append() {
    echo "/dev/mmcblk0p2" >> ${D}${sysconfdir}/udev/mount.ignorelist
    echo "/dev/mmcblk0p3" >> ${D}${sysconfdir}/udev/mount.ignorelist
}
