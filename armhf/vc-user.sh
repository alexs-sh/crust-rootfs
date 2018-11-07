#!/bin/sh

#Описание
#  Добавление пользователя volcano

#Эффект
#  Создает пользователя volcano ( пароль:volcano)
#  Добаляет пользователя в группы systemd-journal,plugdev,netdev,sudo,dip
#  Добавляет пакет sudo

# Создать установочный скрипт
echo "<== VC User: Install packages (1/4)"
echo '#!/bin/bash' > $CHROOT_DIR/install.sh
echo 'apt update  > /dev/null'  >> $CHROOT_DIR/install.sh
echo 'apt install -y sudo' >> $CHROOT_DIR/install.sh
echo 'exit 0' >> $CHROOT_DIR/install.sh

# Запустить скрипт в chroot
cat $CHROOT_DIR/install.sh
chmod +x $CHROOT_DIR/install.sh
cat << EOF | chroot $CHROOT_DIR /bin/bash
/install.sh
EOF
rm $CHROOT_DIR/install.sh

# Создать  настроечный скрипт
echo "<== VC User: Configure packages (2/4)"
echo '#!/bin/bash' > $CHROOT_DIR/setup.sh
echo 'useradd -m -g users -G systemd-journal,plugdev,netdev,sudo,dip -s /bin/bash volcano' >> $CHROOT_DIR/setup.sh
echo 'echo "volcano:volcano" | chpasswd' >> $CHROOT_DIR/setup.sh
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
echo "<== VC User: Validate (3/4)"
cat $CHROOT_DIR/etc/group | grep volcano || exit 1
CHECK_FILES="$CHROOT_DIR/usr/bin/sudo"
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
echo "<== VC User: Cleanup (4/4)"
echo '#!/bin/bash' > $CHROOT_DIR/clean.sh
echo 'apt-get clean' >> $CHROOT_DIR/clean.sh
cat $CHROOT_DIR/clean.sh
chmod +x $CHROOT_DIR/clean.sh
cat << EOF | chroot $CHROOT_DIR /bin/bash
/clean.sh
EOF
rm $CHROOT_DIR/clean.sh

exit 0






