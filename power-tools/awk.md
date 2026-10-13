
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

## Examples

```bash
awk '$3 > 0 { print $1, $2 * $3 }' data.txt
# If column is greater than zero print the first column and the product of the second and third column
```

```bash
awk '$3 == 0 { print $1 }' data.txt
# If 3 column is 0 print the first column
```
