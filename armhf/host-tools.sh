#!/bin/sh

#Описание
#  Подготовка хоста. 
#Эффект
#  Добавляет в хост пакеты для сборки rootfs (qemu, debootstrap,...)

# Переменные из вызывающего скрипта
# CUR_DIR
# CHROOT_DIR

#----------------------------------------------------------------------  
# Настройка хоста
#----------------------------------------------------------------------  
echo "<== Host: Prepare (1/2)"
echo "Working directory: $CHROOT_DIR"
apt update > /dev/null && \
apt install -y sed gzip debootstrap bsdtar qemu qemu-user-static qemu-system-arm debian-ports-archive-keyring > /dev/null

#----------------------------------------------------------------------  
#  Validate
#----------------------------------------------------------------------  
echo "<== Host: Validate (2/2)"
CHECK_FILES="/usr/bin/qemu-arm-static"
files=($(echo $CHECK_FILES | tr "," "\n"))
# Check package existence
for f in "${files[@]}"
do
	if [ ! -f $f ]; then
		echo "File $f not found!"
		exit 1
	fi
done


exit 0
