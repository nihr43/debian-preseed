src.iso:
	wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.0.0-amd64-netinst.iso -O src.iso

iso_extract: src.iso
	mkdir -p iso_extract
	bsdtar -C iso_extract -xf src.iso

seeded.iso: iso_extract
	hash cpio pigz genisoimage isohybrid
	chmod +w -R iso_extract/boot
	cat grub.cfg > iso_extract/boot/grub/grub.cfg
	chmod -w -R iso_extract/boot
	chmod +w -R iso_extract/isolinux
	cat isolinux.cfg > iso_extract/isolinux/isolinux.cfg
	chmod -w -R iso_extract/isolinux
	chmod +w -R iso_extract/install.amd/
	pigz -d iso_extract/install.amd/initrd.gz
	echo preseed.cfg | cpio -H newc -o -A -F iso_extract/install.amd/initrd
	pigz iso_extract/install.amd/initrd
	chmod -w -R iso_extract/install.amd/
	chmod +w iso_extract/md5sum.txt
	find iso_extract/ -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > iso_extract/md5sum.txt
	chmod -w iso_extract/md5sum.txt
	chmod +w iso_extract/isolinux/isolinux.bin
	xorriso -as mkisofs -iso-level 3 -o seeded.iso \
          -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot \
          -boot-load-size 4 -boot-info-table iso_extract
	isohybrid seeded.iso

clean:
	rm -vrf seeded.iso
	if [ -d iso_extract ] ; then chmod +w -R iso_extract && rm -vrf iso_extract ; fi
	rm -f d0.img d1.img

d0.img:
	fallocate -l 4g d0.img

d1.img:
	fallocate -l 4g d1.img

qemu_common=qemu-system-x86_64 -m size=8g -smp cpus=8 -enable-kvm -cdrom seeded.iso -boot menu=on

sata_raid: seeded.iso d0.img d1.img
	$(qemu_common) -drive file=d0.img,if=ide,format=raw -drive file=d1.img,if=ide,format=raw

nvme_single: seeded.iso d0.img d1.img
	$(qemu_common) -drive file=d0.img,if=none,id=nvme0,format=raw -device nvme,serial=aabbccee,drive=nvme0

# firmware image /usr/share/qemu/OVMF.fd is provided by debian package ovmf
uefi: seeded.iso d0.img d1.img
	$(qemu_common) -bios /usr/share/qemu/OVMF.fd
