[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows the current system load.

	mysysload = lain.widgets.sysload()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 5
`settings` | User settings | function | empty function

`settings` can use strings `load_1`, `load_5` and `load_15`, which are loadavg over 1, 5, and 15 minutes.

### output

A textbox.