# arch-installation

Arch installation guide for a working environment focus in cybersecurity Encryption + LVM + BTRFS + Wayland + Niri. 

For a post-installation guide see: [arch-installation/post-installation.md](https://github.com/x0l4dn4/arch-installation/blob/main/post-installation.md)

> [!WARNING]
> The guide covers the full installation and can be used as is, though it's currently still a draft.


todo:
- [ ] Create a canvas and separate each header 2 into articles.
- [ ] Create an index.
- [ ] Create a web-version.


## Keyboard and fonts

todo:
- [ ] Add what is locale.

`localectl` controls the system **locale** and keyboard layout settings. The default console keymap is `en-US`.

```bash

localectl list-keymaps # List the available keymaps.

```


To set the keyboard layout, pass its name to `loadkeys`.

```bash

loadkeys dvorak-ca-fr

```

#### Console fonts


Console fonts are located in `/usr/share/kbd/consolefonts/ `and can likewise be set with `setfont` omitting the path and file extension.

```bash

setfont ter-132b

```

###### See also:


[localectl(1) - Linux manual page](https://man7.org/linux/man-pages/man1/localectl.1.html)

[loadkeys(1) — Arch manual pages](https://man.archlinux.org/man/loadkeys.1)

[Linux console - ArchWiki](https://wiki.archlinux.org/title/Linux\_console#Fonts)

[setfont(8) — Arch manual pages](https://man.archlinux.org/man/setfont.8)


## Connect to the Internet


todo:
- [ ] How to configure static IP address and DNS servers post-installation

Wi-Fi—authenticate to the wireless network using `iwctl`.

`iwd` automatically stores network passphrases in the `/var/lib/iwd/ssid.psk` directory and uses them to *auto-connect* in the future. 

```bash
iwctl

[iwd] device list #If you don't know your wireless device name.

[iwd] device name set-property Powered on  # It it is powered off
[iwd] adapter adapter set-property Powered on

# Then, to initiate a scan for networks

[iwd] station name scan

# You can then list all available networks

[iwd] station name get-networks

# Finally, to connect to a network:

[iwd] station name connect SSID

# If network is hidden

[iwd] station name connect-hidden SSID


```



###### See also:

[iwd - ArchWiki](https://wiki.archlinux.org/title/Iwd#iwctl)

[Getting started with iwd](https://archive.kernel.org/oldwiki/iwd.wiki.kernel.org/gettingstarted.html)


## Manage time

todo:
- [ ] Really understand about stratum and how can date can affect TLS certificates.
- [ ] Hardware clock

~~This is quite verbose, may I move it to the post-installation?.~~

> [!IMPORTANT]
> The live system needs accurate time to prevent package signature verification failures and TLS certificate errors.

 The `systemd-timesyncd` service is enabled by default in the live environment and time will be synchronized automatically once a connection to the internet is established.

Use `timedatectl` to ensure the system clock is synchronized:

> [!CAUTION]
> Commands only affected the live ISO environment, not your installed system, later when chroot we must set the time again.

Linux hosts have two times to consider: **system time and RTC time**. RTC stands for *real-time clock*, which is a name for the system hardware clock.
> [!NOTE]
> The hardware clock runs continuously, even when the computer is turned off, *powered by the battery on the system motherboard*.

The RTC’s primary function is to keep the time when a connection to a time server is not available. It is a simple quartz crystal oscillator (usually running at 32.768 kHz), often called a Real-Time Clock (RTC) or CMOS clock, powered by a small coin-cell battery.

Years ago, there was no Internet to connect to a time server, so the only time a computer had available was the internal clock.

Operating systems had to rely on the *RTC* at boot time, and the user had to manually set the system time using the hardware BIOS configuration interface to ensure it was correct.

The system time is the time known by the operating system. It is the time you see on the GUI clock on your desktop, in the output from the date command, in timestamps for logs, and in file access, modify, and change times.

### NTP

`NTP` is the *Network Time Protocol* that is used by computers worldwide to **synchronize their times** with Internet standard reference clocks via a hierarchy of NTP servers.

```bash
timedatectl set-ntp true
```

#### NTP Server Hierarchy

The NTP server hierarchy is built in layers called **strata**. Each stratum is a layer of NTP servers. *The primary servers are at stratum 1*, and they are connected directly to various national time services at stratum 0 via satellite, radio, or even modems over phone lines in some cases.Those time services at stratum 0 may be an **atomic clock**.


To prevent time requests from time servers lower in the hierarchy, that is, with a higher stratum number, from overwhelming the primary reference servers, there are several thousand public NTP stratum 2 servers that are open and available for all to use.


#### NTP implementation

The original NTP implementation is `ntpd`, the NTP daemon, and it has been joined by two newer ones, `chronyd` and `systemd-timesyncd`. All three keep the local host’s time synchronized with an NTP time server. 


The `systemd-timesync` service is intended to be a replacement for `chrony` as a tool for managing NTP services. It uses a new command, `timedatectl`, to manage NTP.


```bash
systemctl enable --now systemd-timesyncd
```


This command returns the local time for your host, the UTC time, and the RTC time.


Set the time zone for the computer. Usually, you set a computer’s time zone during the installation procedure and never need to change it. However, there are times it is necessary to change the time zone, and there are a couple of tools to help. Linux uses time zone files to define the local time zone in use by the host. These binary files are located in the `/usr/share/zoneinfo` directory.


```bash
timedatectl list-timezones | column
timedatectl set-timezone Europe/Prague
```


*System clock synchronized: yes* means the system believes it has acquired a trustworthy network time synchronization.

*NTP service: active* means a time-sync service is enabled, but not necessarily that it has successfully contacted a server yet.

`systemd-timesyncd.service` contacts a remote NTP server and disciplines the local system clock. Despite the name, **it implements SNTP**, a simpler subset of full NTP, rather than a full NTP daemon. That makes it small and convenient for desktops, laptops, VMs, and many general-purpose systems


When enabled, set-ntp true enables and starts the first available network-time synchronization service. When disabled, it stops and disables recognized time-sync services.

###### See also:  

[systemd-timesyncd.service(8) - Linux manual page](https://man7.org/linux/man-pages/man8/systemd-timesyncd.service.8.html)

[Synchronize time using timedatectl and timesyncd - Ubuntu Server documentation](https://ubuntu.com/server/docs/how-to/networking/timedatectl-and-timesyncd/)

[David Both - systemd for Linux SysAdmins - Chapter 6 Control Your Computer Time and Date with systemd](https://link.springer.com/chapter/10.1007/979-8-8688-1328-3_6)


## Disk partitioning

todo: 
- [ ] Understand LVM, btrfs and its snapshots and subvolumes. Also crypttab

The minimum physical storage unit of a hard disk drive (HDD) is a sector.
The solid state drive (SSD) equivalent is a page.


Software and documentation may sometimes refer to "sectors" and "blocks" interchangeably, regardless of the storage type.

#### EFI partition

The EFI system partition (also called ESP) is an OS-independent partition formatted as FAT that serves as the storage location for UEFI boot loaders, applications, and drivers executed by the UEFI firmware. It is mandatory for UEFI booting.

An ESP contains the boot loaders or kernel images of installed operating systems (which are typically contained in other partitions), device driver files for hardware devices present in a computer and used by the firmware at boot time, system utility programs that are intended to be run before an operating system is booted, and data files such as error logs.

> [!CAUTION]
> The EFI system partition must be a physical partition in the main partition table of the disk, not under LVM or software RAID etc.


UEFI provides *backward compatibility* with legacy systems by reserving the first block (sector) of the partition for compatibility code, effectively creating a legacy boot sector. On legacy BIOS-based systems, the first sector of a partition is loaded into memory, and execution is transferred to this code. UEFI firmware does not execute the code in the MBR, except when booting in legacy BIOS mode through the Compatibility Support Module (CSM)

##### Partition and mounting

`fdisk`: Create a partition and use the `t` command to change its partition type to EFI System using the alias **uefi**.

###### See also:

[Unified Extensible Firmware Interface - ArchWiki](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface#See_also)

[Plumbing UEFI into Linux - YouTube](https://web.archive.org/web/20210721150713/https://www.youtube.com/watch?v=ehs_7I8qMm0)


#### Encrypt the partition

- Device mapper 

Framework provided by the Linux kernel, used to map physical block devices to higher level virtual block devices.

- DM-Crypt

A target used with device mapper that provides transparent encryption. Allows us to create a virtual block device and have all data be encrypted on the fly before being committed to disk
and can decrypt in the same way for reads.

- Lucks

Linux Unified Key Setup provides an efficient user-friendly way to store and manage keys. Without LUCKS, DM-Crypt can be more cumbersome and error prone.

> [!NOTE]
> You first create the encrypted volume, then open the volume, format the unlocked volume and mount it.


```bash
cryptsetup --type luks2 -y -v luksFormat /dev/sda1
```

Specifying --type luks2 is optional on current `cryptsetup` versions because LUKS2 is normally the default, but it makes the intended format unambiguous

| Part       | Meaning                                                                                        |
| ---------- | ---------------------------------------------------------------------------------------------- |
| cryptsetup | Tool that configures encrypted block devices using dm-crypt/LUKS                               |
| -y         | Ask you to enter the new passphrase twice, to catch typos                                      |
| -v         | Verbose mode: prints extra status/progress information                                         |
| luksFormat | Writes a LUKS header to the target device and creates the initial passphrase entry (keyslot 0) |
| /dev/sda1  | The target partition to turn into a LUKS container                                             |


> [!NOTE]
> This command does not yet give you a usable filesystem. It produces an encrypted container. You then unlock it with a mapper name.


```bash
cryptsetup open /dev/sda1 myvol
```

That creates the decrypted block device in `/dev/mapper/myvol`

Now you can either create a filesystem directly on it, for example `mkfs.ext4 /dev/mapper/myvol; or

make it an LVM physical volume and create separate root and swap logical volumes inside it.

##### LVM setup


create an LVM physical volume and volume group:

```bash
pvcreate /dev/mapper/myvol
vgcreate vg0 /dev/mapper/myvol
```

Then create logical volumes for swap and root. Example: 8 GiB swap and all remaining space for root:


```bash
lvcreate -L 8G -n swap vg0
lvcreate -l 100%FREE -n root vg0
```

You will get devices similar to:

```bash
/dev/vg0/root
/dev/vg0/swap
```

Now create the filesystem and swap area

```bash
mkfs.btrfs /dev/vg0/root
mkswap /dev/vg0/swap
mkfs.fat -F32 /dev/sda1 # The EFI partition you created previously.
```

Mount and enable them during the installation

```bash
mount /dev/vg0/root /mnt
swapon /dev/vg0/swap
```


Then  `crypttab` — Configuration for encrypted block devices

btrfs options in fstab


| Option          | Recommendation           | Reason                                                                                                                                                                                                   |
| --------------- | ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| noatime         | Yes                      | Stops writes that only update file access timestamps. This can reduce metadata writes, particularly useful with snapshots. btrfs                                                                         |
| compress=zstd:3 | Yes                      | Transparent Zstandard compression at its default level. It generally offers a strong space-saving/speed balance. Btrfs skips files when compression would not help. wiki.archlinux+1                     |
| discard=async   | Yes, for SSD/NVMe        | Queues and batches TRIM rather than issuing synchronous discards, avoiding the latency cost of synchronous discard. Modern Btrfs enables asynchronous discard by default when supported. man.archlinux+1 |
| rw              | Optional                 | Read-write is already the normal default; including it is harmless but unnecessary.                                                                                                                      |
| subvol=@        | Yes, if using subvolumes | Tells Btrfs which subvolume to mount as /. It is not a performance setting.                                                                                                                              |


##### Btrfs subvolumes

todo:
- [ ] Explain btrfs not just creating subvolumes.

> [!NOTE]
> BTRFS has been part of the mainline Linux Kernel since 2009, which means it is maintained and patched as part of it.

A subvolume is a independently mountable, logical portion of a file tree that behaves much like a physical block device or a distinct filesystem, despite sharing the same underlying storage pool.

Because subvolumes share the same storage pool, directories like `/home` and `/var` can reside on the same physical device while remaining logically isolated.

> [!IMPORTANT]
>  This architecture allows you to apply unique mount options to each subvolume in your `/etc/fstab` file, treating them as if they were independent devices.

Furthermore, **snapshots in Btrfs are simply a special type of subvolume**. Managing subvolumes is handled via the `btrfs subvolume` utility.

> [!TIP]
> btrfs subcommands can be abbreviated to any unique prefix. For example, `btrfs filesystem usage` is also accessible as `btrfs f u`.

To create the subvolumes the btrfs partition must be mounted.

```bash
mount /dev/sda2 /mnt
```

Then, create the desired subvolumes.

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
```

Umount and then mount each subvolume.

```bash
umount /mnt
mount -o "noatime,compress=zstd,discard=async,subvol=@" /dev/sda2 /mnt
mkdir -p /mnt/{home,.snapshots,var/log}
mount -o "noatime,compress=zstd,discard=async,subvol=@home" /dev/sda2 /mnt/home
mount -o "noatime,compress=zstd,discard=async,subvol=@snapshots" /dev/sda2 /mnt/.snapshots
mount -o "noatime,compress=zstd,discard=async,subvol=@var_log" /dev/sda2 /mnt/var/log
mount --mkdir /dev/sda1 /mnt/boot
```

###### See also:

[Device mapper - Wikipedia](https://en.wikipedia.org/wiki/Device_mapper)

[dm-crypt - Wikipedia](https://en.wikipedia.org/wiki/Dm-crypt)

[Partitioning - ArchWiki](https://wiki.archlinux.org/title/Partitioning)

[LVM - ArchWiki](https://wiki.archlinux.org/title/LVM)

[Install Arch Linux on LVM - ArchWiki](https://wiki.archlinux.org/title/Install_Arch_Linux_on_LVM)

[Logical volume management guide - Tutonics](https://tutonics.com/articles/logical-volume-management-guide/)

[Subvolumes — BTRFS documentation](https://btrfs.readthedocs.io/en/latest/Subvolumes.html)


### fstab and crypttab
The function of `/etc/fstab` is to specify the filesystems that should be mounted during startup and the mount points on which they are to be mounted, along with any options that might be necessary.

Each of the filesystem line entries contains six columns of data.

The first column is an **identifier** that identifies the filesystem so that the startup process knows which filesystem to work with in this line. There are multiple ways to identify the filesystem: **UUID**, or Universal Unique IDentifier.

This is an ID that is guaranteed to be unique so that no other partition can have the same one. The UUID is generated when the filesystem is created and is located in the *superblock* for the partition.

```bash
blkid /dev/sda1 # You can see the UUID of a partition
```

You can also identifie a partition using the path to the device special files in the /dev directory. 

Another option would be to use the labels when formatting the filesystem, such as `mkfs.btrfs -L DISK /dev/vg0/root`

```bash
UUID=rsti7bodb9-9d11-tnet /boot vfat defaults 0 2
/dev/mapper/vg0-root    /home   btrfs rw,noatime,compress=zstd:3,ssd,discard=async,subvol=@home 0 1
LABEL=TEMP /tmp ext4 defaults 0 0
```
The filesystem label is also stored in the partition *superblock*.

The second column in the `/etc/fstab `file is the mountpoint on which the filesystem identified by the data in column 1 is mounted. These mountpoints are empty directories to which the filesystem is mounted, if there is data in those directories it won't be available until the partition is unmounted.

The third column specifies the filesystem type such as btrfs, ext4, NTFS, etc.

The fourth column of data in the fstab file is a list of options. The `mount` command has many options, and each option has a default setting.
As an example an option could be: the `noauto` option which means that this filesystem is not automatically mounted during the Linux startup. It can be manually mounted and unmounted after startup. This is ideal for a removable device like a USB memory stick.

> [!CAUTION]
> If a partition is listed in `/etc/fstab` and is not available during startup, the system may fail to boot unless the `nofail` option is specified in the fstab entry.

The last two columns are of numbers. The first number is used by the `dump` command, which is one possible
option for making backups. The `dump` command is rarely used today for backups, so this column is usually ignored. If by some chance someone is still using `dump` to make backups, a 1 in this column means to back up this entire filesystem, and a 0 means to skip this filesystem.

The last column is also numeric. It specifies the sequence in which `fsck` is run against filesystems during startup. Zero (0) means do not run `fsck` on the filesystem. One (1) means to run `fsck` on this filesystem first. The root partition should always checked first.

After you have mounted your partitions you can automatically generate a fstab file with the options of the currently mounted filesystems using the `genfstab` command.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

The `/etc/crypttab` (encrypted device table) file is similar to the `fstab` file and contains a list of encrypted devices to be unlocked during system boot up.

crypttab is read before fstab, so that encrypted devices can be unlocked before the file system inside is mounted.

If you want to mount an encrypted drive at boot time, enter the device's UUID in `/etc/crypttab`. You get the UUID (partition) by using the command `lsblk -f` and adding it to crypttab in the form:

```bash
volume-name UUID=1f958855-a269-458a-8na2-22a45ei65431  none  timeout=200
# The first 2 fields are mandatory, the remaining two are optional.
```

The `volume-name` contains the name of the resulting volume with decrypted data below /dev/mapper
The third field you can specify a key to unlock the device, if  `none` or `-` is present, the password has to be manually entered during system boot.

The last field is for the options separated by commas, refer to the manual to see all the possible options. In this case, `timeout` specifies the timeout for querying for a password. If no unit is specified, seconds is used.

###### See also:

[fstab - Wikipedia](https://en.wikipedia.org/wiki/Fstab)

[fstab - ArchWiki](https://wiki.archlinux.org/title/Fstab)

[genfstab(8) — Arch manual pages](https://man.archlinux.org/man/genfstab.8)

[dm-crypt/System configuration - ArchWiki](https://wiki.archlinux.org/title/Dm-crypt/System_configuration#Mounting_at_boot_time)

[crypttab(5) - Linux manual page](https://www.man7.org/linux/man-pages/man5/crypttab.5.html)

[dm-crypt/System configuration - ArchWiki](https://wiki.archlinux.org/title/Dm-crypt/System_configuration#crypttab)

[systemd-cryptsetup-generator(8) — Arch manual pages](https://man.archlinux.org/man/systemd-cryptsetup-generator.8)

[Security: Disk Encryption | Into the Terminal 66 - YouTube](https://www.youtube.com/watch?v=0DUpbAbup5o&t=797s)


## Install essential packages

Packages to be installed must be downloaded from **mirror servers**, which are defined in `/etc/pacman.d/mirrorlist`. The higher a mirror is placed in the list, the more priority it is given when downloading a package.

On the live system, all HTTPS mirrors are enabled (i.e. uncommented). The topmost worldwide mirror should be fast enough for most people, but you may still want to inspect the file to see if it is satisfactory.

No configuration (except for `/etc/pacman.d/mirrorlist`) gets carried over from the live environment to the installed system.
> [!IMPORTANT]
> The only mandatory package to install is *base*, which does not include all tools from the live installation, so installing more packages is frequently necessary.

`pacstrap` is the primary tool for creating a new arch installation. It performs the following operations:

- Creates the directory structure required for a functional Linux system
- Mounts API filesystems (proc, sys, dev, etc.) into the target root
- Handles pacman keyring initialization or copying from the host
- Installs packages using pacman
- Copies mirrorlist and optionally pacman configuration from the host

`pacstrap` will be used to install packages to the specified new root directory, in this case `/mnt` for now.

```bash
pacstrap -K /mnt base linux linux-firmware # vim sudo cryptsetup lvm2 btrfs-progs man
```

For example, the packages above for a basic installation with the Linux kernel and firmware for common hardware.

> [!TIP]
> This initial package selection in pacstrap only needs to include what is required for the system to boot; all other software can be installed or replaced post-installation.


###### See also:

[Mirrors - ArchWiki](https://wiki.archlinux.org/title/Mirrors)

[pacstrap(8) — Arch manual pages](https://man.archlinux.org/man/pacstrap.8)

[pacstrap | archlinux/arch-install-scripts | DeepWiki](https://deepwiki.com/archlinux/arch-install-scripts/2.3-pacstrap)

## Chroot

`chroot` stands for "change root". It is a system call that changes the root directory of the current running process and its children to a new location in the filesystem.

A chroot environment is sometimes called a *jail*. This is because a process that runs inside a chroot environment is somewhat locked up: that process can access only files that are within the chroot hierarchy.

When you run a command using `chroot`, the system redefines the meaning of any initial slashes (/) in pathnames to the new directory you specify. For that process, the designated path appears as the actual root directory, *preventing it from traversing or accessing files outside* or above that directory. This restricted environment is commonly referred to as a **chroot jail**.

Usages:

- Sandboxing and Isolation: It isolates untrusted applications or services (like web, mail, or DNS servers) so that if they are compromised, the attacker's access is restricted to that specific filesystem subtree.

- User Containment: It restricts remote users (such as in SFTP or web-hosting environments) to their own designated directories.

- System Recovery and Testing: It is used to perform system maintenance, run installer environments, or test new software without affecting the main system.

```bash
arch-chroot -S /mnt
```

###### See also:

[chroot - ArchWiki](https://wiki.archlinux.org/title/Chroot)

[Chroot - Gentoo wiki](https://wiki.gentoo.org/wiki/Chroot)

[BasicChroot - Community Help Wiki](https://help.ubuntu.com/community/BasicChroot)


### Locale, time and hostname

```bash
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc # This sets the hardware clock from system clock.
```



To use the correct region and language specific formatting (like dates, currency, decimal separators), edit `/etc/locale.gen` and uncomment the UTF-8 locales you will be using. For example, `en_US.UTF-8 UTF-8`.

 Generate the locales by running:

```bash
locale-gen
```

Create the `locale.conf` file, and set the `LANG` variable accordingly:

```bash
LANG=en_US.UTF-8
```

If you set the console keyboard layout, make the changes persistent in `vconsole.conf`.

```bash
KEYMAP=de-latin1
```

To assign a consistent, identifiable name to your system (particularly useful in a networked environment), create the hostname file `/etc/hostname`.
Just add a string to the file to set the hostname.

###### See also:

[hwclock(8) — Arch manual pages](https://man.archlinux.org/man/hwclock.8)

[Locale - ArchWiki](https://wiki.archlinux.org/title/Locale)

[Network configuration - ArchWiki](https://wiki.archlinux.org/title/Network_configuration#Set_the_hostname)


### initramfs

The `initramfs` (short for initial RAM filesystem) is a temporary, minimal root filesystem that is loaded into RAM by the bootloader.

> [!NOTE]
> initramfs is a compressed **cpio** archive. **cpio** is an old Unix archive format like TAR and ZIP, but it is easier to decode and so requires less code in the kernel.


To mount your real root filesystem (which resides on your hard drive, SSD, or network storage), the Linux kernel needs the appropriate driver modules (such as SCSI, RAID, or specific filesystem drivers like ext4 or btrfs).

However, because the Linux kernel is modular, these drivers are typically stored as loadable module files on that very same root filesystem.

If the kernel cannot read the disk without the drivers, and it cannot load the drivers because they are on the unmounted disk, the system cannot boot.

`mkinitcpio` is a Bash script used to create `initramfs` images. The primary configuration file for mkinitcpio is `/etc/mkinitcpio.conf`

> [!CAUTION]
> Hooks are scripts that execute in the initial ramdisk. Some hooks that may be required for your system like lvm2, mdadm_udev, and encrypt are NOT enabled by default.

#### Hooks

The `HOOKS` array is the most important setting in the file. Hooks are small scripts describing what will be added to the initramfs image. Some hooks are accompanied by a so-called runtime hook providing startup functionality, such as starting a daemon, or assembling a stacked block device.

Hooks are referred to by their name, and **executed in the order they are listed** in the `HOOKS` array of the configuration file. The recommended order of the hook list should be followed unless you know what you are doing.

For LVM, You must have `lvm2` installed to use this. `lvm2` provides the *lvm2 hook*. If you are running `mkinitcpio` in an arch-chroot for a new installation, **lvm2 must be installed inside the arch-chroot** for `mkinitcpio` to find the lvm2 hook. 

> [!CAUTION]
> If lvm2 only exists outside the arch-chroot, mkinitcpio will output Error: Hook 'lvm2' cannot be found.

In case your root filesystem is on LVM, you will need to enable the appropriate `mkinitcpio hooks`, otherwise your system might not boot.

Enable: `systemd` and `lvm2` for the default systemd-based initramfs.

Edit the file `/etc/mkinitcpio.conf` and insert lvm2 between block and filesystems:

```bash
HOOKS=(base systemd ... block lvm2 filesystems)
```

`dm_crypt` kernel module and the `cryptsetup` tool to the image. You must have `cryptsetup` installed to use this. Add `sd-encrypt` before `lvm2`.

```bash
HOOKS=(base systemd ... block sd-encrypt lvm2 filesystems)
```

The hook `sd-vconsole` provides support for non-US keymaps for typing encryption passwords; it must come before the encrypt hook, otherwise you will need to enter your encryption password using the default US keymap. Set your keymap in `/etc/vconsole.conf`.

The `keyboard` hook needs to be placed before `autodetect` in order to be able to use the keyboard at boot time, for example to unlock an encrypted device when using the sd-encrypt hook.

> [!IMPORTANT]
> Remember to regenerate the initramfs after making any changes to `/etc/mkinitcpio.conf` using `mkinitcpio -P`

###### See also:

[mkinitcpio - ArchWiki](https://wiki.archlinux.org/title/Mkinitcpio#Hook_list)

[Install Arch Linux on LVM - ArchWiki](https://wiki.archlinux.org/title/Install_Arch_Linux_on_LVM#Adding_mkinitcpio_hooks)


## New user and root password

Set a secure password for the `root` user to allow performing administrative actions.

```bash
passwd
```

Create a new user it is a good practice to not be root. (This can be done in the post-installation phase).

```bash
adduser -m user1
passwd user1
usermod -aG wheel,user1 user # Add to the user's group and wheel.
```

Then with `EDITOR=vim visudo` uncomment the line `%wheel ALL=(ALL:ALL) ALL` to allow members of group wheel to execute any command.

###### See also:

[Users and groups - ArchWiki](https://wiki.archlinux.org/title/Users_and_groups#User_management)


## Install Grub

A `boot loader` is a piece of software started by the firmware UEFI or BIOS. It is responsible for *loading the kernel* with the wanted kernel parameters and any external initramfs images.

A `boot manager` presents a menu of boot options, or provides some other way to control the boot process.

First, install the packages `grub` and `efibootmgr`: GRUB is the boot loader while efibootmgr is used by the GRUB installation script to write boot entries to NVRAM.

```bash
pacman -S grub efibootmgr
```

Then install grub in the /boot partition previously mounted. 

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
```
Then make the grub configuration, edit /etc/default/grub and add 

```bash
GRUB_CMDLINE_LINUX="root=/dev/vg0/root rootflags=subvol=@ resume=/dev/vg0/swap" # For hibernation the swap
```

Then create the config file

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

Then exit the chroot and reboot

```bash
exit
umount -R /mnt #  this allows noticing any "busy" partitions.
reboot
```

###### See also:

[Arch boot process - ArchWiki](https://wiki.archlinux.org/title/Arch_boot_process#Boot_loader)

[Unified Extensible Firmware Interface - ArchWiki](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface)


Installation finished!


