[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows MPD status in a textbox.

	mpdwidget = lain.widgets.mpd()

Now playing songs are notified like this:

	+--------------------------------------------------------+
	| +-------+                                              |
	| |/^\_/^\| Now playing                                  |
    | |\ O O /| Cannibal Corpse (Hammer Smashed Face) - 1993 |
    | | '.o.' | Hammer Smashed Face (Radio Disney Version)   |
	| +-------+                                              |
	+--------------------------------------------------------+

You need a file like this

     (Front|front|Cover|cover|Art|art|Folder|folder)\.(jpg|jpeg|png|gif)

in the album folder in order to show album art too.

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 1
`password` | MPD password | string | ""
`host` | MPD server | string | "127.0.0.1"
`port` | MPD port | string | "6600"
`music_dir` | Music directory | string | "~/Music"
`cover_size` | Album art notification size | int | 100
`default_art` | Default art | string | ""
`settings` | User settings | function | empty function

`settings` can use `mpd_now` table, which contains the following string values:

- state (possible values: "play", "pause", "stop")
- file
- artist
- title
- album
- date

and can modify `mpd_notification_preset` table, which will be the preset for the naughty notifications. Check [here](http://awesome.naquadah.org/doc/api/modules/naughty.html#notify) for the list of variables it can contain. Default definition:

    mpd_notification_preset = {
       title   = "Now playing",
       timeout = 6,
       text    = string.format("%s (%s) - %s\n%s", mpd_now.artist,
                 mpd_now.album, mpd_now.date, mpd_now.title)
    }

### output table

Variable | Meaning | Type
--- | --- | ---
`widget` | The textbox | `wibox.widget.textbox`
`update` | The notification | function

You can control the widget with key bindings like these:

    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
        function ()
            awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            awful.util.spawn_with_shell("mpc stop || ncmpcpp stop || ncmpc stop || pms stop")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            awful.util.spawn_with_shell("mpc prev || ncmpcpp prev || ncmpc prev || pms prev")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            awful.util.spawn_with_shell("mpc next || ncmpcpp next || ncmpc next || pms next")
            mpdwidget.update()
        end),

where `altkey = "Mod1"`.