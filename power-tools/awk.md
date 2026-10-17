
## The structure of an AWK program

The parts between the quote characters are programs written in AWK. An Awk program is a sequence of one or more pattern-action statements:

```bash
pattern { action }
pattern { action }
```

The basic operation of Awk is to scan a sequence of input lines, searching for lines that are *matched* by any of the patterns in the program.
The precise meaning of “match” depends on the pattern in question; for patterns like `$3 > 0`, it means “the condition is true.”

> There are only two types of data in Awk: numbers and strings of characters.

Every input line is tested against each of the patterns in turn. For each pattern that matches, the corresponding action is performed.
Then the next line is read and the matching starts over. This continues until all the input lines have been read.

> Since patterns and actions are both optional, actions are enclosed in braces to distinguish them from patterns.

If there is an action with no pattern, for example,`{ print $1 }` then the action, in this case printing the first field, is performed for every input line.

The first field in the current input line is called $1, the second $2, and so forth.

> The entire line is called $0.

Awk counts the **number of fields** in the current input line and stores the count in a built-in variable called `NF`

Awk provides another built-in variable, called `NR`, that counts the **number of lines** (**records**) read so far.

You can also print words in the midst of fields and computed values, by including quoted strings of characters in the list.

```bash
awk '{ print "Name: ", $1, "salary", $2 * $3 }' data.txt
```
In the `print` statement, the text inside the double quotes is printed along with the fields and computed values.

## Formatting output 

The `print` statement is meant for quick and easy output. To format the output exactly the way you want it, you may have to use the `printf` statement. 

```bash
printf( format, value1, value2, ...)
```

The format is a string that contains text to be printed verbatim, interspersed with specifications of how each of the values is to be printed.

A specification is a `%` followed by a few characters that control the format of a value.

The first specification tells how value1 is to be printed, the second how value2 is to be printed, and so on.

Thus, there must be as many `%` specifications in format as values to be printed.

> The `printf` statement is almost the same as the printf function in the standard C library.)

## BEGIN and END

The special pattern `BEGIN` matches before the first line of the first input file is read, and `END` matches after the last line of the last file has been processed.

```bash
BEGIN { print "NAME AGE SALARY"}
      { print $0}
```



------


## Examples

```bash
awk '$3 > 0 { print $1, $2 * $3 }' data.txt
# If column is greater than zero print the first column and the product of the second and third column
```

```bash
awk '$3 == 0 { print $1 }' data.txt
# If 3 column is 0 print the first column
```

```bash
awk { print NF, $1, $NF } data.txt
# Prints the number of fields and the first and last fields of each input line.
```


```bash
awk '{printf ("%s: %s\n", "Name", $1)}' ~/awk/test
# Prints Name followed by a semicolon and the first column of the input file
```
