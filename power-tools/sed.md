## Stream editor

It is called `sed` because is a *stream editor*, is perfect for applying a series of edits to a number of lines in files.

Sed is a non-interactive stream-oriented editor. As input flows through the program and is directed to the standard output.

Sed works by interpreting a script specifying the actions to be performed to the input.

It offers facilities such as *search and replace* that can be applied globally to a single file or a group of files.

Sed also has the ability to be used as an editing *filter*. You could process an input file and send the output to another program.


> You can trace the lineage of awk to sed and grep to `ed`, the original UNIX line editor. The underlying line editor of vi is `ex` which in turn is a superset of the features in `ed`.



The global command makes all lines that match the regular expression the object of the specified command.


