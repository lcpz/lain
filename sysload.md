[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Show the current system load in a textbox.

	mysysload = lain.widgets.sysload()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 5
`settings` | User settings | function | empty function

`settings` can use strings `a`, `b` and `c`, which are loadavg over 1, 5, and 15 minutes.

### output

A textbox.