DESCRIPTION = "SWUpdate image artifact for benchmarking"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

SRC_URI = "\
    file://emmcsetup.lua \
    file://sw-description \
"

IMAGE_DEPENDS = "torizon-core-lite"
SWUPDATE_IMAGES = "torizon-core-lite"
SWUPDATE_IMAGES_FSTYPES[torizon-core-lite] = ".ext4.gz"
