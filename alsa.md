[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows and controls alsa volume with a textbox.

	volumewidget = lain.widgets.alsa()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 5
`channel` | Mixer channel | string | "Master" 
`settings` | User settings | function | empty function

`settings` can use the following variables:

Variable | Meaning | Type | Values
--- | --- | --- | ---
volume_now.level | Self explained | int | 0-100
volume_now.status | Device status | string | "on", "off"

### output table

Variable | Meaning | Type
--- | --- | --- 
`widget` | The widget | `wibox.widget.textbox`
`update` | Update `widget` | function

You can control the widget with key bindings like these:

    -- Volume control
    awful.key({ altkey }, "Up",
    function ()
        awful.util.spawn("amixer set Master 1%+")
        volumewidget.update()
    end),
    awful.key({ altkey }, "Down",
    function ()
        awful.util.spawn("amixer set Master 1%-")
        volumewidget.update()
    end),
    awful.key({ altkey }, "m",
    function ()
        awful.util.spawn("amixer set Master playback toggle")
        volumewidget.update()
    end),
    awful.key({ altkey, "Control" }, "m", 
    function ()
        awful.util.spawn("amixer set Master playback 100%", false )
        volumewidget.update()
    end),

where `altkey = "Mod1"`.