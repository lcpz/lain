[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows memory status (in MiB) in a textbox.

	mymem = lain.widgets.mem()


The function takes a table as an optional argument. That table may
contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`refresh_timeout` | Refresh timeout seconds | int | 10
`show_swap` | Show amount of used swap space? | boolean | false
`show_total` | Show amout of total memory? | boolean | false
`header` | Text to show before value | string | " Mem "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"
`footer` | Text to show after value | string | "MB"

**Note**: `footer` color is `color`.