test: vm

iso_src:
	wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.2.0-amd64-netinst.iso -O iso_src

iso_extract: iso_src
	mkdir -p iso_extract
	bsdtar -C iso_extract -xf iso_src

iso_seeded: iso_extract
	hash gunzip cpio pigz genisoimage
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
	xorriso -as mkisofs -o iso_seeded \
          -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot \
          -boot-load-size 4 -boot-info-table iso_extract

clean:
	if [ -f iso_seeded ] ; then rm -vrf iso_seeded ; fi
	if [ -d iso_extract ] ; then chmod +w -R iso_extract && rm -vrf iso_extract ; fi

d1.img:
	dd if=/dev/zero of=d1.img bs=1M count=4096

d2.img:
	dd if=/dev/zero of=d2.img bs=1M count=4096

vm: iso_seeded d1.img d2.img
	qemu-system-x86_64 -m size=1g -smp cpus=2 -enable-kvm --cdrom iso_seeded -drive file=d1.img,if=ide,format=raw -drive file=d2.img,if=ide,format=raw -boot menu=on
