# arch-installation

Arch installation guide for a working environment focus in cybersecurity Encryption + LVM + BTRFS + Wayland + Niri. 

For a post-installation guide see: [arch-installation/post-installation.md](https://github.com/x0l4dn4/arch-installation/blob/main/post-installation.md)

> This guide is currently a draft, not a complete guide.


**todo: Create a canvas and separate each header 2 into articles.**

**todo: Create an index**


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


**todo: How to configure static IP address and DNS servers post-installation**

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

**todo: Really understand about stratum and how can date can affect TLS certifcates.**

*This is quite verbose, may I move it to the post-installation?.*

The live system needs accurate time to prevent package signature verification failures and TLS certificate errors. The `systemd-timesyncd` service is enabled by default in the live environment and time will be synchronized automatically once a connection to the internet is established.

Use `timedatectl`(1) to ensure the system clock is synchronized:


Linux hosts have two times to consider: **system time and RTC time**. RTC stands for *real-time clock*, which is a name for the system hardware clock.

> The hardware clock runs continuously, even when the computer is turned off, *powered by the battery on the system motherboard*.

The RTC’s primary function is to keep the time when a connection to a time server is not available. It is a simple quartz crystal oscillator (usually running at 32.768 kHz), often called a Real-Time Clock (RTC) or CMOS clock, powered by a small coin-cell battery.

Years ago, there was no Internet to connect to a time server, so the only time a computer had available was the internal clock.

Operating systems had to rely on the *RTC* at boot time, and the user had to manually set the system time using the hardware BIOS configuration interface to ensure it was correct.

The system time is the time known by the operating system. It is the time you see on the GUI clock on your desktop, in the output from the date command, in timestamps for logs, and in file access, modify, and change times.

### NTP

`NTP` is the *Network Time Protocol* that is used by computers worldwide to **synchronize their times** with Internet standard reference clocks via a hierarchy of NTP servers.

#### NTP Server Hierarchy

The NTP server hierarchy is built in layers called **strata**. Each stratum is a layer of NTP servers. *The primary servers are at stratum 1*, and they are connected directly to various national time services at stratum 0 via satellite, radio, or even modems over phone lines in some cases.


> Those time services at stratum 0 may be an **atomic clock**, a radio receiver that is tuned to the signals broadcast by an atomic clock, or a GPS receiver using the highly accurate clock signals broadcast by GPS satellites.


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


See also:  

[systemd-timesyncd.service(8) - Linux manual page](https://man7.org/linux/man-pages/man8/systemd-timesyncd.service.8.html)

[Synchronize time using timedatectl and timesyncd - Ubuntu Server documentation](https://ubuntu.com/server/docs/how-to/networking/timedatectl-and-timesyncd/)

[David Both - systemd for Linux SysAdmins](https://link.springer.com/book/10.1007/979-8-8688-1328-3)


