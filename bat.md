[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows in a textbox the remaining time and percentage capacity of your laptop battery, as well as
the current wattage.

Displays a notification when battery is low or critical.

	mybattery = lain.widgets.bat()

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`battery` | Identifier of the battery | string | "BAT0"
`show_all` | Show all values (true), or only remaining capacity (false) | boolean | false
`refresh_timeout` | Refresh timeout seconds | int | 30
`header` | Text to show before value | string | " Bat "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"
`footer` | Text to append after value | string | " "
`shadow` | Hide the widget when battery is not present | boolean | false

**Note**: `footer` can be markup text.