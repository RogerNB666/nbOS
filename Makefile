all:
	cd boot && make && cd ../
	cd scripts && ./build.sh && cd ../
	cd app && ./build.sh && cd ../
	#
	cp -r ./syscfg/* ./image || true
	#
	mkdir ./image/root/boot
	mkdir ./image/root/efi
	#
	mkdir -p ./image/root/root/lib/modules/linux-5.13.12
	./scripts/copy_ko.run ./src/linux-5.13.12 ./image/root/root/lib/modules/linux-5.13.12
	#
	mkdir ./image/initrd_install/lib
	cp ./src/linux-5.13.12/drivers/ata/libahci.ko ./image/initrd_install/lib
	cp ./src/linux-5.13.12/drivers/ata/ahci.ko ./image/initrd_install/lib
	cp ./src/linux-5.13.12/drivers/nvme/host/nvme-core.ko ./image/initrd_install/lib
	cp ./src/linux-5.13.12/drivers/nvme/host/nvme.ko ./image/initrd_install/lib
	cp ./src/linux-5.13.12/drivers/usb/storage/usb-storage.ko ./image/initrd_install/lib
	cp ./src/linux-5.13.12/fs/fat/msdos.ko ./image/initrd_install/lib
	cp ./src/linux-5.13.12/fs/nls/nls_iso8859-1.ko ./image/initrd_install/lib
	#
	cp -r ./image/initrd_install/lib ./image/initrd
	#
	dd if=/dev/urandom of=./install/rootid count=1 bs=16
	#
	cp ./install/rootid ./image/initrd_install/bootid
	#
	cp -r ./image/initrd ./image/root/initrd
	#
	./scripts/gencpio.run ./image/initrd_install ./image/boot/initrd-5.13.12
	#
	cp ./src/linux-5.13.12/arch/x86/boot/bzImage ./image/boot/vmlinuz-5.13.12
	cp ./src/linux-5.13.12/arch/x86/boot/bzImage ./image/root/boot/vmlinuz-5.13.12
	#
	cp ./boot/boot.conf ./image/boot
	cp ./boot/boot.conf.main ./image/root/boot/boot.conf
	cp ./boot/background.bin ./image/boot
	cp ./boot/background.bin ./image/root/boot
	cp ./boot/bootx64.efi ./image/root/efi
	#
	cd install && ./mkimage.sh && cd ../
	#
	printf "\033[1m\033[32m./install/install.img is ready.\033[0m\n"
clean:
	cd boot && make clean && cd ../
	cd scripts && ./clean.sh && cd ../
	cd app && ./clean.sh && cd ../
	rm -rf image/boot/*
	rm -rf image/root/*
	rm -rf image/initrd/*
	rm -rf image/initrd_install/*
	rm -f install/install.img install/bootid install/rootid
