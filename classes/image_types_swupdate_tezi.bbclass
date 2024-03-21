# This class implements a SWUpdate-enabled Toradex Easy Installer image
# Based largely on meta-mender-community/meta-mender-toradex-nxp/classe/image_type_mender_tezi.bbclass

IMAGE_TYPEDEP:swupdate_tezi:append = " wic.gz "

TEZI_AUTO_INSTALL ??= "false"
TEZI_CONFIG_FORMAT ??= "2"
TEZI_STORAGE_DEVICE ??= "mmcblk0"

WKS_FILE_DEPENDS:append = " tezi-metadata "

do_image_swupdate_tezi[recrdeptask] += "do_deploy"
RM_WORK_EXCLUDE += "${PN}"

def rootfs_swupdate_tezi_emmc(d):
    from collections import OrderedDict
    offset_bootrom = d.getVar('OFFSET_BOOTROM_PAYLOAD')
    offset_spl = d.getVar('OFFSET_SPL_PAYLOAD')
    imagename = d.getVar('IMAGE_LINK_NAME')
    storage_device = d.getVar('TEZI_STORAGE_DEVICE')

    bootpart_rawfiles = []

    if offset_spl:
        bootpart_rawfiles.append(
              {
                "filename": d.getVar('SPL_BINARY'),
                "dd_options": "seek=" + offset_bootrom
              })
    bootpart_rawfiles.append(
              {
                "filename": d.getVar('UBOOT_BINARY_TEZI_EMMC'),
                "dd_options": "seek=" + (offset_spl if offset_spl else offset_bootrom)
              })

    return [
        OrderedDict({
          "name": storage_device,
          "table_type": "gpt",
              "content": {
                  "rawfiles": [
                      {
                          "dd_options": "bs=8M",
                          "filename": "%s.wic.gz" % (imagename)
                      }
                  ]
              }
        }),
        OrderedDict({
          "name": "%sboot0" % (storage_device),
          "erase": True,
          "content": {
            "filesystem_type": "raw",
            "rawfiles": bootpart_rawfiles
          }
        })]

python rootfs_swupdate_tezi_json() {
    json_file = "image-%s.json" % d.getVar('IMAGE_BASENAME')

    import json
    from collections import OrderedDict
    from datetime import datetime

    data = OrderedDict({ "config_format": d.getVar('TEZI_CONFIG_FORMAT'), "autoinstall": oe.types.boolean(d.getVar('TEZI_AUTO_INSTALL')) })

    data["name"] = d.getVar('SUMMARY')
    data["description"] = d.getVar('DESCRIPTION')
    data["version"] = "SWupdate %s" % d.getVar('DISTRO_CODENAME')
    data["release_date"] = datetime.strptime(d.getVar('SRCDATE'), '%Y%m%d').date().isoformat()
    data["prepare_script"] = "prepare.sh"
    data["wrapup_script"] = "wrapup.sh"
    data["marketing"] = "marketing.tar"
    data["icon"] = "toradexlinux.png"

    product_ids = d.getVar('TORADEX_PRODUCT_IDS')
    if product_ids is None:
        bb.fatal("Supported Toradex product ids missing, assign TORADEX_PRODUCT_IDS with a list of product ids.")
    data["supported_product_ids"] = product_ids.split()
    data["blockdevs"] = rootfs_swupdate_tezi_emmc(d)

    with open(os.path.join(d.getVar('IMGDEPLOYDIR'), json_file), 'w') as outfile:
        json.dump(data, outfile, indent=4)
}

IMAGE_CMD:swupdate_tezi () {
    cp ${IMGDEPLOYDIR}/image-${IMAGE_BASENAME}*.json ${WORKDIR}/image-json/image.json

    uboot_files=""
    for file in ${UBOOT_BINARY_TEZI_EMMC} ${SPL_BINARY} uboot.env; do
        if [ -f "${DEPLOY_DIR_IMAGE}/$file" ]; then
            uboot_files="${DEPLOY_DIR_IMAGE}/$file $uboot_files"
        fi
    done

    # The first transform strips all folders from the files
    # The second adds back a subfolder
    ${IMAGE_CMD_TAR} --transform='s/.*\///' \
		     --transform 's,^,${IMAGE_LINK_NAME}/,' \
		     -chf ${IMGDEPLOYDIR}/${IMAGE_NAME}.swupdate_tezi.tar \
		     ${WORKDIR}/image-json/image.json \
		     ${DEPLOY_DIR_IMAGE}/prepare.sh \
		     ${DEPLOY_DIR_IMAGE}/wrapup.sh \
		     ${DEPLOY_DIR_IMAGE}/marketing.tar \
		     ${DEPLOY_DIR_IMAGE}/toradexlinux.png \
		     $uboot_files \
		     ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic.gz
    ln -sf ${IMAGE_NAME}.swupdate_tezi.tar ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.swupdate_tezi.tar
}
do_image_swupdate_tezi[dirs] += "${WORKDIR}/image-json ${DEPLOY_DIR_IMAGE}"
do_image_swupdate_tezi[cleandirs] += "${WORKDIR}/image-json"
do_image_swupdate_tezi[prefuncs] += "rootfs_swupdate_tezi_json"
IMAGE_TYPEDEP:swupdate_tezi[vardepsexclude] = "SRCDATE"
