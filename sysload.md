Show the current system load in a textbox.

	mysysload = lain.widgets.systemload()

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`show_all` | Show all the three values (true), or only the first one (false) | boolean | false
`refresh_timeout` | Refresh timeout seconds | int | 5
`header` | Text to show before value | string | " Load "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"
`app` | Proc program to spawn on click | string | "top"