
> [!WARNING]
> This guide is not completed yet. It is currently a draft.

todo:
- [ ] Getting BlackArch repos
- [ ] Undertand timeshift for snapshots
- [ ] Package management, dependencies broken
- [ ] Build from source
- [ ] Paru 
- [ ] Setting manual IP and DNS servers


```bash

cat /etc/os-release

```


## Network configuration

`systemd-networkd` is a system daemon that manages network configurations. It detects and configures network devices as they appear; it can also create virtual network devices.

```bash
sudo systemctl enable --now systemd-networkd # Start it now an enable it to start at boot.
```

NetworkManager 

```bash
sudo systemctl enable --now networkmanager
nmcli device wifi list
nmcli device wifi connect 'SSID' password 'password'
nmcli device status
```
When connected verify it will autoconnect after reboot.

```bash
nmcli -f connection.autoconnect connection show 'SSID'
# connection.autoconnect: yes 
```
If it says `connection.autoconnect: no`, enable it.

```bash
sudo nmcli connection modify "SSID" connection.autoconnect yes
```


### Static IP

To assign a persistent static IP and DNS using systemd, use `systemd-networkd` for the interface configuration and `systemd-resolved` for name resolution.


## Changing DNS

`systemd-resolved` is a systemd service that provides network name resolution to local applications via a D-Bus interface

The browser needs an IP address for `www.example.com`. It may first consult its own DNS cache; otherwise, it asks the operating system resolver.

On Linux, the resolver normally follows the **hosts: order** in `/etc/nsswitch.conf`


```bash
passwd:files
shadow:files
group:files
hosts:files myhostname dns
bootparams:files
```

Look at the *hosts* entry. The first entry is “**files**” which means that the resolver is to *search first the local database*. The database isn’t explicitly specified here, but it is the `/etc/hosts` file.

If a match is not found, the resolver moves on to the next entry which is "**myhostname**." This provides *name resolution for the locally configured system hostname* as contained in the `$HOSTNAME` environment variable.

> [!IMPORTANT]
> Because all of these entries are sequence-sensitive, if an entry is found for a hostname in the `/etc/hosts` database, that takes precedent over any other, later entries


If no match exists, query DNS (dns).

The DNS resolver configuration generally comes from `/etc/resolv.conf`, directly or via a local component such as systemd-resolved. 

#### /etc/hosts



#### /etc/resolv.conf


#### /etc/nsswitch.conf

As its name implies, the nsswitch, short for **Name Service Switch** is used to define the database sources and order in which name-service information is obtained.


The systemd-resolved.service provides name resolution services 


sudo resolvectl dns enp3s0 1.1.1.1 1.0.0.1
sudo resolvectl domain enp3s0 '~.'

###### See also:

[David Both - systemd for Linux SysAdmins - Chapter 12 Using systemd-resolved Name Service](https://link.springer.com/chapter/10.1007/979-8-8688-1328-3_12)

[systemd.service — Service unit configuration](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html)


## Desktop

At the bottom of any graphical display mechanism is the `framebuffer`, a chunk of memory that the graphics hardware reads and transmits to the screen for display.

A few individual bytes in the `framebuffer` *represent each pixel of the display*, so the idea is that if you want to change the way something looks, you *need to write new values* to the framebuffer memory.

One problem that a windowing system must solve is how to manage writing to the framebuffer.

Windows (or sets of windows) belong to *individual processes*, doing all of their graphics updates independently. So if the user is allowed to move windows around and overlap some on top of others, how does an application know where to draw its graphics, and how do you make sure that one application isn’t allowed to overwrite the graphics of other windows?

### The X Window System

The approach that the X Window System takes is to have a server (called the X server) that acts as a sort of “kernel” of the desktop to *manage everything* from rendering windows to configuring displays to handling input from devices, such as keyboards and mouse.

The X server doesn’t dictate the way anything should act or appear. Instead, X client programs handle the user interface.

Basic X client applications, such as terminal windows and web browsers, *make connections to the X server and ask to draw windows*.

In response, the X server figures out where to place the windows and where to render client graphics, and it takes a certain amount of responsibility for rendering graphics to the framebuffer. The X server also channels input to a client when appropriate.

Because it acts as an **intermediary for everything, the X server can be a significant bottleneck**. In addition, it includes a lot of functionality that’s no longer used, and it’s also quite old, dating back to the 1980s.



 ### Wayland

Unlike X, Wayland is significantly **decentralized** by design. There’s no large display server managing the framebuffer for a number of graphical clients, and there’s no centralized authority for rendering graphics.

Instead, each client gets its own memory buffer (think of this as sort of a **sub-framebuffer**) for its own window, and a piece of software called a `compositor` *combines all of the clients’ buffers* into the necessary form for copying to the screen’s framebuffer.




###### See also

[Brian Ward - How Linux Works, 3rd Edition Chapter 14 | No Starch Press - ](https://nostarch.com/howlinuxworks3)


### Niri

Basic installation for now.

```bash
sudo pacman -Syu niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk alacritty dms-shell-niri matugen cava qt6-multimedia-ffmpeg

systemctl --user add-wants niri.service dms
```
###### See also

[Alacritty Arch wiki](https://wiki.archlinux.org/title/Alacritty)


#### Change font in terminal

If you're using Alacritty, the terminal font size is configured in its config file.

```bash
~/.config/alacritty/alacritty.toml
```

To the set the font modify `family` and the `size`

```bash
[font]
size = 16.0

[font.normal]
family = "JetBrainsMono Nerd Font"
style = "Regular"

``` 

You can see which fonts are installed with `fc-list`


### Audio 

Check if pipewire is installed

```bash
pacman -Qs 'pipewire|wireplumber'
```

You should have at least 

```bash
pipewire
pipewire-pulse
wireplumber
```

If not, install it

```bash
sudo pacman -S pipewire pipewire-pulse wireplumber
```

Then, enable the service

```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

###### See also


[Sound system Arch wiki ](https://wiki.archlinux.org/title/Sound_system)

[PipeWire Arch wiki](https://wiki.archlinux.org/title/PipeWire)

[WirePlumber Arch wiki](https://wiki.archlinux.org/title/WirePlumber)

### Bluetooth devices

Bluetooth is a standard for the short-range wireless interconnection of cellular phones, computers, and other electronic devices. In Linux, the canonical implementation of the Bluetooth protocol stack is `BlueZ`

#### Installation

Install the `bluez` package, providing the Bluetooth protocol stack.

Install the `bluez-utils` package, providing the bluetoothctl utility.

```bash
pacman -S bluez bluez-utils
```

> Optionally install `bluez-deprecated-tools` to have the deprecated BlueZ tools as well.


The generic Bluetooth driver is the `btusb` kernel module.

Check whether that module is loaded. If it is not, then load the module.

Kernel modules are pieces of code that can be loaded and unloaded into the kernel upon demand.

They *extend the functionality of the kernel without the need to reboot* the system. 


```bash
lsmod bluez
```

Start/enable bluetooth.service.

```bash
systemctl enable  bluetooth --now
```

> [Warning]
> Some Bluetooth adapters are bundled with a Wi-Fi card (e.g. older Intel Centrino cards). These require that the Wi-Fi card is firstly enabled (typically a keyboard shortcut on a laptop) in order to make the Bluetooth adapter visible to the kernel.


> [Warning]
> Some Bluetooth cards (e.g. Broadcom) conflict with the network adapter. Thus, you need to make sure that your Bluetooth device gets connected before the network service boot.

###### See also

[Bluetooth Arch wiki](https://wiki.archlinux.org/title/Bluetooth)

[Bluetooth headset Arch wiki](https://wiki.archlinux.org/title/Bluetooth_headset)

### Black Arch repositories

BlackArch Linux is compatible with existing/normal Arch installations. *It acts as an unofficial user repository*. 

First, download the official setup script **as root**

```bash
curl -O https://blackarch.org/strap.sh

# Verify the SHA1 sum
echo 00688950aaf5e5804d2abebb8d3d3ea1d28525ed strap.sh | sha1sum -c
```
Then, just execute it and update the repos

```bash
chmod +x strap.sh && sudo ./strap.sh

sudo pacman -Sy
```

You may now install tools from the blackarch repository.

```bash
# List all of the available tools
sudo pacman -Sgg | grep blackarch | cut -d' ' -f2 | sort -u

# See the blackarch categories 
sudo pacman -Sg | grep blackarch

# To install a category of tools
sudo pacman -S blackarch-category
```

###### See also

[Black arch official check out for changes](https://blackarch.org/downloads.html#install-repo)



