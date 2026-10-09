# s06 · Associative arrays & reading input

**Track:** Shell scripting · **Level:** Intermediate · **File:** `wordfreq.sh`

## Spec

```
wordfreq.sh [-n N] [FILE]
```
Print the `N` (default **10**) most frequent words in `FILE` - or **stdin** if no file (or `-`) is given.

- A word is a run of **letters a-z**, case-insensitive (`The`, `the`, `THE` are the same word).
  Everything else separates words, so `It's` -> `it` + `s`.
- Output lines are `COUNT WORD`, sorted by count (highest first), ties alphabetically.
- `-n` must be a positive integer, otherwise usage + exit **2**. A missing file -> error + exit **1**.

Example (`fixtures/text.txt`):
```
$ wordfreq.sh -n 3 fixtures/text.txt
6 the
3 dog
3 fox
```

## Concepts

`declare -A` · `${!arr[@]}` · reading stdin vs a file (`exec < "$file"` or `"${file:--}"`)
· `tr -cs 'A-Za-z' '\n'` · `getopts` basics · *bonus:* do it once in pure bash and once as a
pipeline (`tr | sort | uniq -c | sort`) and time both on a big file.
