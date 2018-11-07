#!/bin/sh

#Описание
#  Добавление в КФС библиотеки boost

#Эффект
#  Добавляет в КФС часть компонентов boost, которые мы используем в своих проектах.

# Переменные из вызывающего скрипта
# CUR_DIR
# CHROOT_DIR


echo "<== Boost: Install packages (1/3)"
echo '#!/bin/bash' > $CHROOT_DIR/install.sh
echo 'apt update  > /dev/null'  >> $CHROOT_DIR/install.sh
echo 'apt install -y libboost-system1.62.0 libboost-thread1.62.0 \
libboost-date-time1.62.0 libboost-chrono1.62.0 libboost-filesystem1.62.0 libboost-test1.62.0 \
libboost-timer1.62.0 libboost-log1.62.0' >> $CHROOT_DIR/install.sh
echo 'exit' >> $CHROOT_DIR/install.sh

# Запустить скрипт в chroot
cat $CHROOT_DIR/install.sh
chmod +x $CHROOT_DIR/install.sh
cat << EOF | chroot $CHROOT_DIR /bin/bash
/install.sh
EOF
rm $CHROOT_DIR/install.sh

#----------------------------------------------------------------------  
#  Validate
#----------------------------------------------------------------------  
echo "<== Boost: Validate (2/3)"
CHECK_FILES="$CHROOT_DIR/usr/lib/arm-linux-gnueabihf/libboost_system.so.1.62.0"
files=($(echo $CHECK_FILES | tr "," "\n"))
# Check package existence
for f in "${files[@]}"
do
	echo "$f"
	if [ ! -f $f ]; then
		echo "File $f not found!"
		exit 1
	fi
done


#----------------------------------------------------------------------  
#  Cleanup
#----------------------------------------------------------------------  
echo "<== Boost: Cleanup (3/3)"
echo '#!/bin/bash' > $CHROOT_DIR/clean.sh
echo 'apt-get clean' >> $CHROOT_DIR/clean.sh
cat $CHROOT_DIR/clean.sh
chmod +x $CHROOT_DIR/clean.sh
cat << EOF | chroot $CHROOT_DIR /bin/bash
/clean.sh
EOF
rm $CHROOT_DIR/clean.sh

exit 0
