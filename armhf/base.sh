#!/bin/sh

#Описание
#  Подготовка хоста. Установка и настройка основных пакетов и пользователя.

#Эффект
#  Создает в хосте папку $CHROOT_DIR 
#  Добаляет в chroot базовую систему
#  Настраивает базовую систему
#  Добавляет основные пакеты (ssh,net-tools, text editors...)
#  Выполняет базовые настройки системы (локали, TZ, ...)

# Переменные из вызывающего скрипта
# CUR_DIR
# CHROOT_DIR


# Настройка окружения для АРМ
echo "<== Base: Prepare chroot (1/7)"
rm -rf $CHROOT_DIR 
mkdir -p $CHROOT_DIR 
debootstrap --arch=armhf --foreign stretch $CHROOT_DIR
cp /usr/bin/qemu-arm-static $CHROOT_DIR/usr/bin/ 

#----------------------------------------------------------------------  
# Установка системы для АРМ
#----------------------------------------------------------------------  
# Создать скрипт для установки АРМовых пакетов и настройки параметров внутри chroot
echo '#!/bin/bash' > $CHROOT_DIR/install.sh
echo 'export distro=stretch' >> $CHROOT_DIR/install.sh
echo 'export LANG=C'  >> $CHROOT_DIR/install.sh
echo '/debootstrap/debootstrap --second-stage ' >> $CHROOT_DIR/install.sh
echo 'apt update  > /dev/null'  >> $CHROOT_DIR/install.sh
echo 'apt upgrade -y'  >> $CHROOT_DIR/install.sh
echo 'apt install -y --allow-unauthenticated ssh tar tzdata locales nano vim net-tools usbutils' >> $CHROOT_DIR/install.sh
echo 'exit' >> $CHROOT_DIR/install.sh

# Запустить скрипт в chroot
cat $CHROOT_DIR/install.sh
chmod +x $CHROOT_DIR/install.sh
echo "<== Base: Install ARM packages (2/7)"
cat << EOF | chroot $CHROOT_DIR /bin/bash
/install.sh
EOF
rm $CHROOT_DIR/install.sh

#----------------------------------------------------------------------  
# конфигурация армовых пакетов и окружения
#----------------------------------------------------------------------  
# Настройка ssh (настраиваем АРМ, но из хоста)
echo "<== Base: Configure ARM packages (3/7)"
# Настройка пользователей SSH. Сохраняем оригинальный конфиг, т.к. он может потребоваться на сл. этапах
cp $CHROOT_DIR/etc/ssh/sshd_config $CHROOT_DIR/etc/ssh/sshd_config.orig
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' $CHROOT_DIR/etc/ssh/sshd_config 

# Имя машины
echo "base" > $CHROOT_DIR/etc/hostname

# Добавить поддержку языков
echo "<== Base: Locales setup (4/7)"
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' $CHROOT_DIR/etc/locale.gen
sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' $CHROOT_DIR/etc/locale.gen
echo 'LANG=en_US.UTF-8' > $CHROOT_DIR/etc/locale.conf

# Создать скрипт для настройки ползователя, локалей, времени и служб внутри chroot
echo '#!/bin/bash' > $CHROOT_DIR/setup.sh
echo 'echo "root:root" | chpasswd' >> $CHROOT_DIR/setup.sh
echo 'locale-gen' >>  $CHROOT_DIR/setup.sh
echo 'rm /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime' >> $CHROOT_DIR/setup.sh 
echo 'systemctl disable apt-daily-upgrade.timer' >> $CHROOT_DIR/setup.sh 
echo 'systemctl disable apt-daily.timer' >> $CHROOT_DIR/setup.sh 

cat $CHROOT_DIR/setup.sh
chmod +x $CHROOT_DIR/setup.sh

# Второй этап настройки АРМового окружения
echo "<== Base: Apply configs for ARM packages (5/7)"
cat << EOF | chroot $CHROOT_DIR /bin/bash
/setup.sh
EOF
rm $CHROOT_DIR/setup.sh

#----------------------------------------------------------------------  
#  Validate
#----------------------------------------------------------------------  
echo "<== Base: Validate (6/7)"
CHECK_FILES="$CHROOT_DIR/sbin/ifconfig,$CHROOT_DIR/etc/ssh/sshd_config"
files=($(echo $CHECK_FILES | tr "," "\n"))
# Check package existence
for f in "${files[@]}"
do
	if [ ! -f $f ]; then
		echo "File $f not found!"
		exit 1
	fi
done


#----------------------------------------------------------------------  
#  Cleanup
#----------------------------------------------------------------------  
echo "<== Base: Cleanup (7/7)"
echo '#!/bin/bash' > $CHROOT_DIR/clean.sh
echo 'apt-get clean' >> $CHROOT_DIR/clean.sh
echo 'exit' >> $CHROOT_DIR/clean.sh
cat $CHROOT_DIR/clean.sh
chmod +x $CHROOT_DIR/clean.sh
cat << EOF | chroot $CHROOT_DIR /bin/bash
/clean.sh
EOF
rm $CHROOT_DIR/clean.sh

exit 0
