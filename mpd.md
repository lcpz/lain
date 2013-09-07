[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows MPD status in a textbox.

	mympd = lain.widgets.mpd()

Now playing songs are notified like this:

	+--------------------------------------------------------+
	| +-------+                                              |
	| |/^\_/^\| Now playing                                  |
    | |\ O O /| Cannibal Corpse (Hammer Smashed Face) - 1993 |
    | | '.o.' | Hammer Smashed Face (Radio Disney Version)   |
	| +-------+                                              |
	+--------------------------------------------------------+

Dependencies

- imagemagick

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`password` | MPD password | string | ""
`host` | MPD server | string | "127.0.0.1"
`port` | MPD port | string | "6600"
`music_dir` | Music directory | string | "~/Music"
`refresh_timeout` | Refresh timeout seconds | int | 1
`color_artist` | Artist value color | string | `beautiful.fg_normal` or "#FFFFFF"
`color_song` | Song value color | string | `beautiful.fg_focus` or "#FFFFFF"
`spr` | Separator text between artist and song values | string | " "
`app` | Music program to spawn on click | string | "ncmpcpp"
`shadow` | Hide widget when there are no songs playing | boolean | false 

**Note**: `spr` can be a markup text.

`lain.widgets.mpd` outputs the following table:

Variable | Meaning | Type
--- | --- | ---
`widget` | The textbox | `wibox.widget.textbox`
`notify` | The notification | function

Finally, you can control the widget with key bindings like these:

    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
    function ()
        awful.util.spawn_with_shell( "mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle", false )
        mympd.notify()
     end),
    awful.key({ altkey, "Control" }, "Down",
    function ()
        awful.util.spawn_with_shell( "mpc stop || ncmpcpp stop || ncmpc stop || pms stop", false )
        mympd.notify()
    end),
    awful.key({ altkey, "Control" }, "Left",
    function ()
        awful.util.spawn_with_shell( "mpc prev || ncmpcpp prev || ncmpc prev || pms prev", false )
        mympd.notify()
    end),
    awful.key({ altkey, "Control" }, "Right",
    function ()
        awful.util.spawn_with_shell( "mpc next || ncmpcpp next || ncmpc next || pms next", false )
        mympd.notify()
    end),

where `altkey = "Mod1"`.