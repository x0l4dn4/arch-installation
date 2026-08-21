
> [!WARNING]
> This guide is currently a draft, not a complete guide.

todo:
- [ ] Getting BlackArch repos
- [ ] Setting manual IP and DNS servers


```bash

cat /etc/os-release

```



## Static IP

To assign a persistent static IP and DNS using systemd, use `systemd-networkd` for the interface configuration and `systemd-resolved` for name resolution.


## Changing DNS

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

[David Both - systemd for Linux SysAdmins](https://link.springer.com/book/10.1007/979-8-8688-1328-3)

[systemd.service — Service unit configuration](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html)


