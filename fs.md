[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows disk space usage for a set partition.

Displays a notification when the partition is full or has low space.

    mypartition = lain.widgets.fs()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds -| int | 600
`partition` | Partition to monitor | string | "/"
`settings` | User settings | function | empty function

`settings` can use the following `partition` related float values: `used` and `available`, `size_mb`, `size_gb`.

It can also use value strings in these formats:

    fs_info[p .. "used_p"]
    fs_info[p .. "avail_p"]
    fs_info[p .. "size_mb"]
    fs_info[p .. "size_gb"]

where `p` is the last column of `df` command ("/", "/home", "/boot", ...).

This means you can set the widget for a certain partition, but you can look up at others too.

Finally, `settings` can modify `fs_notification_preset` table too. This table will be the preset for the naughty notifications. Check [here](http://awesome.naquadah.org/doc/api/modules/naughty.html#notify) for the list of variables it can contain. Default definition:

    fs_notification_preset = { fg = beautiful.fg_normal }

### output table

Variable | Meaning | Type
--- | --- | ---
`widget` | The widget | `wibox.widget.textbox`
`show` | The notification | function

You can display the notification with a key binding like this:

    awful.key({ altkey }, "h", function () mypartition.show(7) end),

where ``altkey = "Mod1"`` and ``show`` argument is an optional integer, meaning timeout seconds.