[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows in a textbox the average CPU usage percent for a given amount of time.

	mycpuusage = lain.widgets.cpu()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 10
`settings` | User settings | function | empty function

### output

A textbox.