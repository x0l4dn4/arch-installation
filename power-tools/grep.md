
The `grep` utility is a line-editing command that has been extracted from `ed` editor and made available as an external program. It's name is derived from the global `ed` command

```bash
g/re/p # global regular expression print
```

It takes a regular expression as argument and uses it as the _address_ of lines to print.

```bash
grep 'david' students
```

It will print **all the lines** that contains the regular expression _david_. Hence, the `g` of global in the name.

