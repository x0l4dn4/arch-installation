## Stream editor

It is called `sed` because is a *stream editor*, is perfect for applying a series of edits to a number of lines in files.

Sed is a non-interactive stream-oriented editor. As input flows through the program and is directed to the standard output.

Sed works by interpreting a script specifying the actions to be performed to the input.

It offers facilities such as *search and replace* that can be applied globally to a single file or a group of files.

Sed also has the ability to be used as an editing *filter*. You could process an input file and send the output to another program.


> You can trace the lineage of awk to sed and grep to `ed`, the original UNIX line editor. The underlying line editor of vi is `ex` which in turn is a superset of the features in `ed`.

The global command makes all lines that match the regular expression the object of the specified command.

> `sed` commands are *implicitly global*. That is, `sed` applies a command to every line of the file.

To replace a string for another string

```bash
[adress]s/pattern/replacement/flag
```

> An address represents the number of a line in the buffer. ed maintains a current address which is typically supplied to commands as the default address when none is specified. When a file is first read, the current address is set to the address of the last line of the file. In general, the current address is set to the address of the last line affected by a command.


>[!Warning]
>If the input file and output redirection point to the same file, the shell truncates the file before sed can read it.

1. Shell opens file.txt for output

The `>` operator opens the file in write mode, which truncates it to zero bytes immediately.

2. Shell starts `sed`

`sed` begins executing and tries to read `file.txt`.

3. `sed` reads an empty file

The original contents are already gone, so there is nothing to transform or write to standard output.

```bash
sed -i 's/World/Universe/' file.txt
sed -i.bak 's/World/Universe/' file.txt # backup before modification
```

The `-i` option tells `sed` to *edit the file in place*.
