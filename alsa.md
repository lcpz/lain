Shows and controls alsa volume with a textbox.

	myvolume = lain.widgets.alsa()

* Left click: Launch `alsamixer` in your `terminal`.
* Right click: Mute/unmute.
* Scroll wheel: Increase/decrase volume.

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`channel` | Mixer channel | string | "Master" 
`step` | Step at which volume is increased/decreased | string | "1%"
`header` | Text to show before value | string | " Vol "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"

and outputs the following table:

Variable | Meaning | Type
--- | --- | --- 
`widget` | The widget | `wibox.widget.textbox`
`channel` | Alsa channel | string
`step` | Increase/decrease step | string
`notify` | Update `widget` | function

Finally, you can control the widget with key bindings like these:

        -- Volume control
        awful.key({ altkey }, "Up",
        function ()
            awful.util.spawn("amixer sset " .. volume.channel .. " " .. volume.step .. "+")
            volume.notify()
        end),
        awful.key({ altkey }, "Down",
        function ()
            awful.util.spawn("amixer sset " .. volume.channel .. " " .. volume.step .. "-")
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