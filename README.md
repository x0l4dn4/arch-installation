# arch-installation

Arch installation guide for a working environment focus in cybersecurity



**todo: Create a canvas and separate each header 2 into articles.**
**todo: Create an index**



```bash

cat /etc/os-release

```



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
