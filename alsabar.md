[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows and controls alsa volume with a progressbar.

Dependencies:

- alsa-utils (of course)

Plus tooltips, notifications, and color changes at mute/unmute switch.

	myvolumebar = lain.widgets.alsabar()

* Left click: Launch `alsamixer` in your `terminal`.
* Right click: Mute/unmute.
* Scroll wheel: Increase/decrase volume.

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`width` | Bar width | int | 63
`height` | Bar height | int | 1
`ticks` | Set bar ticks on | boolean | true
`ticks_size` | Ticks size | int | 7
`vertical` | Set the bar vertical | boolean | false
`channel` | Mixer channel | string | "Master" 
`step` | Step at which volume is increased/decreased | string | "5%"
`colors` | Bar colors | table | see **colors**
`notifications` | Notifications settings | table | see **notifications**

### colors

Variable | Meaning | Type | Default
--- | --- | --- | ---
`background` | Bar backgrund color | string | `beautiful.bg_normal`
`mute` | Bar mute color | string | "#EB8F8F"
`unmute` | Bar unmute color | string | "#A4CE8A"

### notifications

Variable | Meaning | Type | Default
--- | --- | --- | ---
`font` | Notifications font | string | The one defined in `beautiful.font`
`font_size` | Notifications font size | string | "11"
`bar_size` | Wibox height | int | 18

It's **crucial** to set `notifications.bar_size` to your `mywibox[s]` height,
**if** you have set it different than default (18). 

`lain.widgets.alsabar` outputs the following table:

Variable | Meaning | Type
--- | --- | ---
`widget` | The widget | `awful.widget.progressbar`
`channel` | Alsa channel | string
`step` | Increase/decrease step | string
`notify` | The notification | function

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