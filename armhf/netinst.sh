#!/bin/sh

#Описание
# Загружает образ Debian с оф. сайта
# Извлекает КФС установщика
# Сохраняет извлеченную КФС + 
# КФС пережатую в формате u-boot'а

#Эффект
#  На выходе получаем 2 файла:
#  initrd.gz - оригинальный файл из образа
#  initrd.uboot - пережатый файл
#  В процессе работа создает временную папку и монтирует
#  в нее ISO
# Переменные из вызывающего скрипта
# CUR_DIR
# CHROOT_DIR

IMAGE=debian-9.5.0-armhf-netinst.iso
INITRD_UBOOT=initrd.uboot

echo "<== Netinst: Prepare (1/5)"
rm -rf ${CHROOT_DIR} 
mkdir -p ${CHROOT_DIR} 
mkdir ${CHROOT_DIR}/mnt

echo "<== Netinst: Download (2/5)"
wget -P ${CHROOT_DIR} https://cdimage.debian.org/debian-cd/current/armhf/iso-cd/${IMAGE}

echo "<== Netinst: Create image (3/5)"
mount ${CHROOT_DIR}/${IMAGE} ${CHROOT_DIR}/mnt
cp ${CHROOT_DIR}/mnt/debian/install/netboot/initrd.gz ${CHROOT_DIR}
mkimage -A arm -O linux -T ramdisk -C gzip -d ${CHROOT_DIR}/initrd.gz ${CHROOT_DIR}/${INITRD_UBOOT}

echo "<== Netinst: Cleanup (4/5)"
rm ${CHROOT_DIR}/${IMAGE}
umount ${CHROOT_DIR}/mnt
rmdir ${CHROOT_DIR}/mnt

echo "<== Netinst: Validate (5/5)"
[ -s  ${CHROOT_DIR}/${INITRD_UBOOT} ] || exit 1

exit 0

