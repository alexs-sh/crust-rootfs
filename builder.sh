#!/bin/bash
TARGET_OS=debian9
echo "OS: ${TARGET_OS}"
echo "ARCH: ${TARGET_ARCH}"
echo "PACKAGES: ${TARGET_PACKAGES}"
echo "DIR: ${TARGET_BUILD_DIR}"

if [ -z ${TARGET_ARCH} ]; then
	echo "Please specify target ARCH. Example: TARGET_ARCH=armhf"
	exit 1
fi;

if [ -z ${TARGET_PACKAGES} ]; then
	echo "Please specify target packages. Example: TARGET_PACKAGES=base"
	exit 1
fi;

if [ -z ${TARGET_BUILD_DIR} ]; then
	echo "Please specify build directory. Example TARGET_BUILD_DIR=/chroot"
	exit 1
fi;


export CUR_DIR="$(pwd)"
export CHROOT_DIR=${TARGET_BUILD_DIR}/${TARGET_OS}-${TARGET_ARCH}

packages=($(echo ${TARGET_PACKAGES} | tr "," "\n"))
# Check package existence
for p in "${packages[@]}"
do
	if [ ! -f ${TARGET_ARCH}/${p}.sh ]; then
		echo "Package ${p} not found!"
		exit 1
	fi
done

# Execute package installer
for p in "${packages[@]}"
do
	echo -e "Process package '${p}'"
	/bin/bash $(pwd)/${TARGET_ARCH}/${p}.sh || exit 1
done

echo "Builder finished. Please visit ${CHROOT_DIR}"
exit 0
