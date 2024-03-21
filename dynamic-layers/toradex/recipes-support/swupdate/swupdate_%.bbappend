FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://disable-signing.cfg \
    file://enable-delta.cfg \
    "
