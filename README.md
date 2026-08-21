# arch-installation

Arch installation guide for a working environment focus in cybersecurity Encryption + LVM + BTRFS + Wayland + Niri. 

For a post-installation guide see: [arch-installation/post-installation.md](https://github.com/x0l4dn4/arch-installation/blob/main/post-installation.md)

> [!WARNING]
> This guide is currently a draft, not a complete guide.


todo:
- [ ] Create a canvas and separate each header 2 into articles.
- [ ] Create an index.


## Keyboard and fonts



`localectl` controls the system **locale** and keyboard layout settings.

The default console keymap is en-US.



You can list the available layouts with



```bash

localectl list-keymaps

```



To set the keyboard layout, pass its name to `loadkeys`.



```bash

loadkeys de-latin1

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

`iwd` automatically stores network passphrases in the `/var/lib/iwd` directory and uses them to *auto-connect* in the future. 

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

[gettingstarted with iwd](https://archive.kernel.org/oldwiki/iwd.wiki.kernel.org/gettingstarted.html)


## Manage time

todo:
- [ ] Really understand about stratum and how can date can affect TLS certificates.


*This is quite verbose, may I move it to the post-installation?.*

The live system needs accurate time to prevent package signature verification failures and TLS certificate errors. The `systemd-timesyncd` service is enabled by default in the live environment and time will be synchronized automatically once a connection to the internet is established.

Use `timedatectl`(1) to ensure the system clock is synchronized:


Linux hosts have two times to consider: **system time and RTC time**. RTC stands for *real-time clock*, which is a name for the system hardware clock.
> [!NOTE]
> The hardware clock runs continuously, even when the computer is turned off, *powered by the battery on the system motherboard*.

The RTC’s primary function is to keep the time when a connection to a time server is not available. It is a simple quartz crystal oscillator (usually running at 32.768 kHz), often called a Real-Time Clock (RTC) or CMOS clock, powered by a small coin-cell battery.

Years ago, there was no Internet to connect to a time server, so the only time a computer had available was the internal clock.

Operating systems had to rely on the *RTC* at boot time, and the user had to manually set the system time using the hardware BIOS configuration interface to ensure it was correct.

The system time is the time known by the operating system. It is the time you see on the GUI clock on your desktop, in the output from the date command, in timestamps for logs, and in file access, modify, and change times.

### NTP

`NTP` is the *Network Time Protocol* that is used by computers worldwide to **synchronize their times** with Internet standard reference clocks via a hierarchy of NTP servers.

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
timedatectl set-timezone America/Los_Angeles
```


*System clock synchronized: yes* means the system believes it has acquired a trustworthy network time synchronization.

*NTP service: active* means a time-sync service is enabled, but not necessarily that it has successfully contacted a server yet.

`systemd-timesyncd.service` contacts a remote NTP server and disciplines the local system clock. Despite the name, **it implements SNTP**, a simpler subset of full NTP, rather than a full NTP daemon. That makes it small and convenient for desktops, laptops, VMs, and many general-purpose systems


When enabled, set-ntp true enables and starts the first available network-time synchronization service. When disabled, it stops and disables recognized time-sync services.


###### See also:  

[systemd-timesyncd.service(8) - Linux manual page](https://man7.org/linux/man-pages/man8/systemd-timesyncd.service.8.html)

[Synchronize time using timedatectl and timesyncd - Ubuntu Server documentation](https://ubuntu.com/server/docs/how-to/networking/timedatectl-and-timesyncd/)

[David Both - systemd for Linux SysAdmins](https://link.springer.com/book/10.1007/979-8-8688-1328-3)


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

`fdisk`: Create a partition and use the t command to change its partition type to EFI System using the alias **uefi**.

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
sudo cryptsetup open /dev/sda1 myvol
```

That creates the decrypted block device in `/dev/mapper/myvol`

Now you can either create a filesystem directly on it, for example `mkfs.ext4 /dev/mapper/myvol; or

make it an LVM physical volume and create separate root and swap logical volumes inside it.

##### LVM setup


create an LVM physical volume and volume group:

```bash
sudo pvcreate /dev/mapper/myvol
sudo vgcreate vg0 /dev/mapper/myvol
```

Then create logical volumes for swap and root. Example: 8 GiB swap and all remaining space for root:


```bash
sudo lvcreate -L 8G -n swap vg0
sudo lvcreate -l 100%FREE -n root vg0
```

You will get devices similar to:

```bash
/dev/vg0/root
/dev/vg0/swap
```

Now create the filesystem and swap area

```bash
sudo mkfs.ext4 /dev/vg0/root
sudo mkswap /dev/vg0/swap
```

Mount and enable them during the installation

```bash
sudo mount /dev/vg0/root /mnt
sudo swapon /dev/vg0/swap
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
