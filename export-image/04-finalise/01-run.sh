#!/bin/bash -e

IMG_FILE="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.img"
INFO_FILE="${STAGE_WORK_DIR}/${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.info"
SYSROOT_DIR="${STAGE_WORK_DIR}/sysroot"

# mkdir -p ${SYSROOT_DIR}/usr/{bin/X11,include,local/lib,lib/arm-linux-gnueabihf}
# mkdir -p ${SYSROOT_DIR}/lib/arm-linux-gnueabihf
# mkdir -p ${SYSROOT_DIR}/opt/vc/lib
# mkdir -p ${SYSROOT_DIR}/{etc,bin}
#
# cp -r  ${ROOTFS_DIR}/usr/lib/arm-linux-gnueabihf/* ${SYSROOT_DIR}/usr/lib/arm-linux-gnueabihf
# cp -r	${ROOTFS_DIR}/etc/* ${SYSROOT_DIR}/etc
# cp -r	${ROOTFS_DIR}/bin/* ${SYSROOT_DIR}/bin
# cp  	${ROOTFS_DIR}/usr/bin/* ${SYSROOT_DIR}/usr/bin/
# cp  	${ROOTFS_DIR}/usr/bin/X11/* ${SYSROOT_DIR}/usr/bin/X11
# cp -r	${ROOTFS_DIR}/usr/include/* ${SYSROOT_DIR}/usr/include
# cp -r	${ROOTFS_DIR}/usr/local/lib/* ${SYSROOT_DIR}/usr/local/lib
# cp -r	${ROOTFS_DIR}/opt/vc/lib/* ${SYSROOT_DIR}/opt/vc/lib
# cp -r	${ROOTFS_DIR}/lib/arm-linux-gnueabihf/* ${SYSROOT_DIR}/lib/arm-linux-gnueabihf
# # cp -r	${ROOTFS_DIR}/lib/* ${SYSROOT_DIR}/lib

on_chroot << EOF
/etc/init.d/fake-hwclock stop
hardlink -t /usr/share/doc
EOF

if [ -d ${ROOTFS_DIR}/home/pi/.config ]; then
	chmod 700 ${ROOTFS_DIR}/home/pi/.config
fi

rm -f ${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache
rm -f ${ROOTFS_DIR}/usr/sbin/policy-rc.d
rm -f ${ROOTFS_DIR}/usr/bin/qemu-arm-static
if [ -e ${ROOTFS_DIR}/etc/ld.so.preload.disabled ]; then
        mv ${ROOTFS_DIR}/etc/ld.so.preload.disabled ${ROOTFS_DIR}/etc/ld.so.preload
fi

rm -f ${ROOTFS_DIR}/etc/apt/sources.list~
rm -f ${ROOTFS_DIR}/etc/apt/trusted.gpg~

rm -f ${ROOTFS_DIR}/etc/passwd-
rm -f ${ROOTFS_DIR}/etc/group-
rm -f ${ROOTFS_DIR}/etc/shadow-
rm -f ${ROOTFS_DIR}/etc/gshadow-

rm -f ${ROOTFS_DIR}/var/cache/debconf/*-old
rm -f ${ROOTFS_DIR}/var/lib/dpkg/*-old

rm -f ${ROOTFS_DIR}/usr/share/icons/*/icon-theme.cache

rm -f ${ROOTFS_DIR}/var/lib/dbus/machine-id

true > ${ROOTFS_DIR}/etc/machine-id

ln -nsf /proc/mounts ${ROOTFS_DIR}/etc/mtab

for _FILE in $(find ${ROOTFS_DIR}/var/log/ -type f); do
	true > ${_FILE}
done

rm -f "${ROOTFS_DIR}/root/.vnc/private.key"

update_issue $(basename ${EXPORT_DIR})
install -m 644 ${ROOTFS_DIR}/etc/rpi-issue ${ROOTFS_DIR}/boot/issue.txt
install files/LICENSE.oracle ${ROOTFS_DIR}/boot/


cp "$ROOTFS_DIR/etc/rpi-issue" "$INFO_FILE"

firmware=$(zgrep "firmware as of" "$ROOTFS_DIR/usr/share/doc/raspberrypi-kernel/changelog.Debian.gz" | \
	head -n1 | \
	sed  -n 's|.* \([^ ]*\)$|\1|p')

printf "\nFirmware: https://github.com/raspberrypi/firmware/tree/%s\n" "$firmware" >> "$INFO_FILE"

kernel=$(curl -s -L "https://github.com/raspberrypi/firmware/raw/$firmware/extra/git_hash")
printf "Kernel: https://github.com/raspberrypi/linux/tree/%s\n" "$kernel" >> "$INFO_FILE"

uname=$(curl -s -L "https://github.com/raspberrypi/firmware/raw/$firmware/extra/uname_string7")
printf "Uname string: %s\n" "$uname" >> "$INFO_FILE"

printf "\nPackages:\n">> "$INFO_FILE"
dpkg -l --root "$ROOTFS_DIR" >> "$INFO_FILE"

ROOT_DEV=$(mount | grep "${ROOTFS_DIR} " | cut -f1 -d' ')

unmount ${ROOTFS_DIR}
zerofree -v ${ROOT_DEV}

unmount_image ${IMG_FILE}

mkdir -p ${DEPLOY_DIR}

rm -f ${DEPLOY_DIR}/image_${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.zip

pushd ${STAGE_WORK_DIR} > /dev/null
zip ${DEPLOY_DIR}/image_${IMG_DATE}-${IMG_NAME}${IMG_SUFFIX}.zip $(basename ${IMG_FILE})
# zip -r ${DEPLOY_DIR}/sysroot.zip $(basename ${SYSROOT_DIR})
popd > /dev/null

cp "$INFO_FILE" "$DEPLOY_DIR"
