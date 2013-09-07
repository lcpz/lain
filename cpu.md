[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows in a textbox the average CPU usage percent for a given amount of time.

	mycpuusage = lain.widgets.cpu()

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`refresh_timeout` | Refresh timeout seconds | int | 10
`header` | Text to show before value | string | " Cpu "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"
`footer` | Text to add after value | string | "%"

**Note**: `footer` color is `color`.