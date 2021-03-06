test: vm

src.iso:
	wget https://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-dvd/debian-testing-amd64-DVD-1.iso -O src.iso

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
	if [ -f seeded.iso ] ; then rm -vrf seeded.iso ; fi
	if [ -d iso_extract ] ; then chmod +w -R iso_extract && rm -vrf iso_extract ; fi
	if [ -f d1.img ] ; then rm d1.img ; fi
	if [ -f d2.img ] ; then rm d2.img ; fi

d1.img:
	fallocate -l 4g d1.img

d2.img:
	fallocate -l 8g d2.img

vm: seeded.iso d1.img d2.img
	qemu-system-x86_64 -m size=4g -smp cpus=4 -enable-kvm -drive file=seeded.iso,if=ide,format=raw -drive file=d1.img,if=ide,format=raw -drive file=d2.img,if=ide,format=raw -boot menu=on
