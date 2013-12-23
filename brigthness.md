[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows the current level of screen brightness.

	mybrightness = lain.widgets.contrib.brightness()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`backlight` | Card managing backlight | `acpi_video0` 
`timeout` | Refresh timeout seconds | int | 5
`settings` | User settings | function | empty function

`settings` can use the string `brightness_now`, which indicates the current brightness level.

### output table

Variable | Meaning | Type
--- | --- | ---
`widget` | The textbox | `wibox.widget.textbox`
`update` | The notification | function

You can control the widget with key bindings like these: [TODO]