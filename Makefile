test: vm

iso:
	wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.2.0-amd64-netinst.iso -O iso

d1.img:
	dd if=/dev/zero of=d1.img bs=1M count=4096

d2.img:
	dd if=/dev/zero of=d2.img bs=1M count=4096

vm: iso d1.img d2.img
	qemu-system-x86_64 -m size=1g -smp cpus=2 -enable-kvm --cdrom iso -drive file=d1.img,if=ide,format=raw -drive file=d2.img,if=ide,format=raw -boot menu=on
