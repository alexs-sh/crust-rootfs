#!/bin/sh

#Описание
#  Установка и настройка сети (с поддержкой NetworkManager'а)

#Эффект
#  Добавляет NetworkManager, задает параметры подключения по умолчанию 
#  Т.к. в процессе настройки будут применены дефолтные значения IP, шлюзов и т.п. (которые вряд ли будут подходить под настройку сети хоста), 
#  работа apt из chroot будет невозможна. Данный шаг следует выполнять последним. Если после настройки сети, необходимо изменить перечень пакетов, то сборку следует начинать с самого начала, с пакета base

#Из вызывающего скрипта
#CHROOT_DIR

echo "<== NetworkManager: Prepare for installation (1/6)"
# Будем ставить NetworkManager -> следует удалить настройки от базовой системы
echo "# Do not edit! Use NetworkManager instead" > $CHROOT_DIR/etc/network/interfaces

# Создать установочный скрипт
echo "<== NetworkManager: Install packages (2/6)"
echo '#!/bin/bash' > $CHROOT_DIR/install.sh
echo 'apt update  > /dev/null'  >> $CHROOT_DIR/install.sh
echo 'apt install -y network-manager' >> $CHROOT_DIR/install.sh
echo 'exit 0' >> $CHROOT_DIR/install.sh

# Запустить скрипт в chroot
cat $CHROOT_DIR/install.sh
chmod +x $CHROOT_DIR/install.sh
cat << EOF | chroot $CHROOT_DIR /bin/bash
/install.sh
EOF
rm $CHROOT_DIR/install.sh

echo "<== NetworkManager: Add defauls configs (3/6)"
# Добавление деф. конфигов для NetworkManager'a
echo '[connection]' > $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'id=Wired connection 1' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'uuid=37fe85e9-abf9-42de-93fc-e0de47dc4007' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'type=ethernet' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'permissions=' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1

echo '[ethernet]' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'mac-address-blacklist=' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1

echo '[ipv4]' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'address1=192.168.1.28/24' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'dns=192.168.1.1;' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'dns-search=' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'method=manual' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1

echo '[ipv6]' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'addr-gen-mode=stable-privacy' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'dns-search=' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
echo 'method=ignore' >> $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
chmod g-r $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1
chmod o-r $CHROOT_DIR/etc/NetworkManager/system-connections/Wired\ connection\ 1


# Создать  настроечный скрипт
echo "<== NetworkManager: Configure packages (4/6)"
echo '#!/bin/bash' > $CHROOT_DIR/setup.sh
echo 'rm -f /etc/resolv.conf' >> $CHROOT_DIR/setup.sh
echo 'ln -s /var/run/NetworkManager/resolv.conf /etc/resolv.conf' >> $CHROOT_DIR/setup.sh
echo 'exit 0' >> $CHROOT_DIR/setup.sh

# Запустить скрипт в chroot
cat $CHROOT_DIR/setup.sh
chmod +x $CHROOT_DIR/setup.sh
cat << EOF | chroot $CHROOT_DIR /bin/bash
/setup.sh
EOF
rm $CHROOT_DIR/setup.sh

#----------------------------------------------------------------------  
#  Validate
#----------------------------------------------------------------------  
echo "<== NetworkManager: Validate (5/6)"
CHECK_FILES="$CHROOT_DIR/usr/bin/nmtui,$CHROOT/etc/resolv.conf"
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
echo "<== NetworkManager: Cleanup (6/6)"
echo '#!/bin/bash' > $CHROOT_DIR/clean.sh
echo 'apt-get clean' >> $CHROOT_DIR/clean.sh
cat $CHROOT_DIR/clean.sh
chmod +x $CHROOT_DIR/clean.sh
cat << EOF | chroot $CHROOT_DIR /bin/bash
/clean.sh
EOF
rm $CHROOT_DIR/clean.sh

exit 0
