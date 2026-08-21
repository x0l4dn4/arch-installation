# arch-installation

Arch installation guide for a working environment focus in cybersecurity Encryption + LVM + BTRFS + Wayland + Niri. 


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






