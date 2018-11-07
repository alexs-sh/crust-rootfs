#!/bin/sh

#Описание
#  Установка и настройка сети (службы network, без NetworkManager'а)

#Эффект
#  Добавляет дефолтные настройки сети
#  Т.к. в процессе настройки будут применены дефолтные значения IP, шлюзов и т.п. (которые вряд ли будут подходить под настройку сети хоста), 
#  работа apt из chroot будет невозможна. Данный шаг следует выполнять последним. Если после настройки сети, необходимо изменить перечень пакетов, то сборку следует начинать с самого начала, с пакета base

# Переменные из вызывающего скрипта
# CUR_DIR
# CHROOT_DIR


#----------------------------------------------------------------------  
# Настройка адресов
#----------------------------------------------------------------------  
echo "<== Network: Configure (1/1)"
echo "auto lo" > $CHROOT_DIR/etc/network/interfaces 
echo "iface lo inet loopback" >> $CHROOT_DIR/etc/network/interfaces 
echo "auto eth0" >> $CHROOT_DIR/etc/network/interfaces 
echo "iface eth0 inet static" >> $CHROOT_DIR/etc/network/interfaces
echo "    address 192.168.1.28" >> $CHROOT_DIR/etc/network/interfaces 
echo "    netmask 255.255.255.0" >> $CHROOT_DIR/etc/network/interfaces
echo "    gateway 192.168.1.1" >> $CHROOT_DIR/etc/network/interfaces 

# Nameserver (перевод адеросв в IP, например google.com)
echo "search 192.168.1.1" > $CHROOT_DIR/etc/resolv.conf
echo "nameserver 192.168.1.1" >> $CHROOT_DIR/etc/resolv.conf

# Настройка стат. имен в устройстве (ping localhost, ping base)
echo "base" > $CHROOT_DIR/etc/hostname
echo "127.0.0.1 base" > $CHROOT_DIR/etc/hosts
echo "127.0.0.1 localhost" >> $CHROOT_DIR/etc/hosts

exit 0
