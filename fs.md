Shows disk space usage for a set partition.

Displays a notification when the partition is full or has low space.

    mypartition = lain.widgets.fs()

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`partition` | Partition to monitor | string | "/"
`refresh_timeout` | Refresh timeout seconds | int | 600
`header` | Text to show before value | string | " Hdd "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"
`footer` | Text to show after value | string | "%"
`shadow` | Hide the widget if `partition` < 90 | boolean | false

**Note**: `footer` color is `color`.

`lain.widgets.fs` outputs the following table:

Variable | Meaning | Type
--- | --- | ---
`widget` | The widget | `wibox.widget.textbox`
`show` | The notification | function

You can display a notification of current disk space usage with a key binding like this:

    awful.key({ altkey }, "h", function () mypartition.show(7) end),

where ``altkey = "Mod1"`` and ``show`` argument is an optional integer, meaning timeout seconds.