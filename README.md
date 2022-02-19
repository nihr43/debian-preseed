# debian-preseed

This is intended for hardware with two drives which are put into md raid.  The result is a machine on the network with keyed root ssh enabled with hostname "debian-unconfigured-...." where "...." are random characters.

_/dev/sda and /dev/sdb are currently hardcoded_

The Makefile knows how to test the iso via qemu:

```
make vm
```

Unlike some other methods, we do not mount the iso for modification or leave this directory, so building the iso does not require sudo.

_catch..._

kvm accelerated qemu requires you are in the libvirt group:

```
$ groups
... libvirt
```
