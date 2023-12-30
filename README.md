# debian-preseed

This is a project for developing and testing debian preseeds.  The result is an iso patched with a preseed and a bootloader that will automatically execute it.  The result machine has keyed root ssh enabled with hostname "debian-unconfigured".  If anyone else uses this, you will want to edit the preseed to land your own ssh key.

# rapid testing

Preseeding is notoriously fragile and time consuming.  Provided is a Makefile that knows how to test the iso via qemu:

```
cp raid.cfg preseed.cfg # <- choose a mode first
make
```

On modern hardware, it takes 2-3 minutes to run a complete install.  To rinse and repeat: `make clean && make`.

Provided are two 'modes'.  single_disk.cfg and raid.cfg.  Before building, cp one of these to `preseed.cfg`; that is what the makefile looks for.

Unlike some other methods, we do not mount the iso for modification or leave this directory, so building the iso does not require root.

_catch..._

kvm accelerated qemu requires you are in the libvirt group:

```
$ groups
... libvirt
```

Debian packages required to build:

```
libarchive-tools pigz xorriso genisoimage syslinux-utils qemu-system
```

Or alternatively on nixOS:

```
nix-shell .
```

or more concisely:

```
nix-shell . --run 'make sata_single'
```
