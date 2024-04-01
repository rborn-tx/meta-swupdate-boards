DESCRIPTION = "SWUpdate image artifact for benchmarking"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = "\
    file://emmcsetup.lua \
    file://sw-description.${UPDATER_BENCHMARKING_TYPE} \
"

IMAGE_DEPENDS = "torizon-core-lite"
SWUPDATE_IMAGES = "torizon-core-lite"
SWUPDATE_IMAGES_FSTYPES[torizon-core-lite] = "${@'.ext4.zck.zckheader' if d.getVar('UPDATER_BENCHMARKING_TYPE') == 'delta' else '.ext4.gz'}"

do_swuimage:prepend() {
    target = "sw-description." + d.getVar("UPDATER_BENCHMARKING_TYPE")
    link = d.getVar("WORKDIR") + "/sw-description"
    if os.path.exists(link):
        os.remove(link)
    os.symlink(target, link)
}
