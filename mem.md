[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows memory status (in MiB) in a textbox.

	mymem = lain.widgets.mem()


The function takes a table as an optional argument. That table may
contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 10
`settings` | User settings | function | empty function

`settings` can use the strings `used` (memory used MB) and `swapused` (swap used MB).

### output

A textbox.