
> [!WARNING]
> This guide is not completed yet. It is currently a draft.

todo:
- [ ] Getting BlackArch repos
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

See also:

[David Both - systemd for Linux SysAdmins - Chapter 12 Using systemd-resolved Name Service](https://link.springer.com/chapter/10.1007/979-8-8688-1328-3_12)

[systemd.service — Service unit configuration](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html)
