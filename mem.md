[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows memory status (in MiB) in a textbox.

	mymem = lain.widgets.mem()

# input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 3
`settings` | User settings | function | empty function

`settings` can use the strings `mem_now.used` (memory used MB) and `mem_now.swapused` (swap used MB).

### output

A textbox.