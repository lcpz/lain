[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows the current level of screen brightness in a textbox.

	mybrightness = lain.widgets.contrib.brightness()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 5
`backlight` | Backlight video | string | "acpi_video0" 
`settings` | User settings | function | empty function

`settings` can use the following variables:

Variable | Meaning | Type | Values
--- | --- | --- | ---
`brightness_now` | Brightness level | int | 0-100

### output table

Variable | Meaning | Type
--- | --- | --- 
`widget` | The widget | `wibox.widget.textbox`
`update` | Update `widget` | function

You can control the widget with key bindings like these:

    -- Volume control
    awful.key({}, "XF86MonBrightnessUp",
    function ()
        awful.util.spawn("xbacklight -inc 1")
        brightnesswidget.update()
    end),
    awful.key({}, "XF86MonBrightnessDown",
    function ()
        awful.util.spawn("xbacklight -dec 1")
        brightnesswidget.update()
    end),