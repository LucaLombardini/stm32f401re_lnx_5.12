#! /bin/bash

REF_KERNEL="vmlinux"

if [ -z "$1" ]; then
	REF_KERNEL="$REF_KERNEL.old"
else
	if [[ "$1" == -* ]]; then
		REF_KERNEL="$REF_KERNEL.$(echo $1 | sed 's/-//')"
		echo "$REF_KERNEL"
		if [ ! -f "./build/stm32f401re/$REF_KERNEL" ]; then
			exit -2
		fi
	else
		exit -1
	fi
fi

echo -e "Renaming the vmlinux binary to vmlinux.old..."

mv build/stm32f401re/vmlinux build/stm32f401re/vmlinux.old

echo -e "Done"

echo -e "Compiling the kernel"

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C build/stm32f401re -j4

if [ $? -eq 0 ]; then
	echo -e "Done"
	echo -e "New kernel size"
	size build/stm32f401re/vmlinux
	echo -e "Bloat-o-meter gain calculation"
	scripts/bloat-o-meter build/stm32f401re/"$REF_KERNEL" build/stm32f401re/vmlinux
	echo -e "\e[1m\e[32mDone!\e[0m"
else
	echo -e "\e[31m\e[31mERROR: compilation failed!\e[0m"
	echo -e "Restoring previous vmlinux name..."
	mv build/stm32f401re/vmlinux.old build/stm32f401re/vmlinux
	echo -e "Done"
fi


