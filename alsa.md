[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows and controls alsa volume with a textbox.

	volume = lain.widgets.alsa()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 5
`channel` | Mixer channel | string | "Master" 
`settings` | User settings | function | empty function

`settings` can be fed with the following variables:

Variable | Meaning | Type | Values
--- | --- | --- | ---
volume.level | Self explained | int | 0-100
volume.status | Device status | string | "on", "off"

### output table

Variable | Meaning | Type
--- | --- | --- 
`widget` | The widget | `wibox.widget.textbox`
`notify` | Force update `widget` | function

You can control the widget with key bindings like these:

    -- Volume control
    awful.key({ altkey }, "Up",
    function ()
        awful.util.spawn("amixer sset Master 1%+")
        volume.notify()
    end),
    awful.key({ altkey }, "Down",
    function ()
        awful.util.spawn("amixer sset Master 1%-")
        volume.notify()
    end),
    awful.key({ altkey }, "m",
    function ()
        awful.util.spawn("amixer set Master playback toggle")
        volume.notify()
    end),
    awful.key({ altkey, "Control" }, "m", 
    function ()
        awful.util.spawn("amixer set Master playback 100%", false )
        volume.notify()
    end),

where `altkey = "Mod1"`.