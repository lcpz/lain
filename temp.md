[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Show the current core temperature in a textbox.

Reads from `/sys/class/thermal`, so value is expressed in Celsius.

	mytemp = lain.widgets.temp()

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`refresh_timeout` | Refresh timeout seconds | int | 5
`header` | Text to show before value | string | " Temp "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"
`footer` | Text to show after value | string | "C "