

## Examples

awk '$3 > 0 { print $1, $2 * $3 }' data.txt # If column is greater than zero print the first column and the product of the second and third column
awk '$3 == 0 { print $1 }' data.txt # If 3 column is 0 print the first column
