[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Attaches a calendar notification to a widget.

    lain.widgets.calendar:attach(widget, args)

- Left click: switch to previous month.
- Right click: switch to next month.

`args` is an optional table which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`icons` | Path to calendar icons | string | [lain/icons/cal/white](https://github.com/copycat-killer/lain/tree/master/icons/cal/white)
`font_size` | Calendar font size | int | 12
`fg` | Calendar foreground color | string | `beautiful.fg_normal`
`bg` | Calendar background color | string | `beautiful.bg_normal`
`position` | Calendar position | string | "top_right"

`position` possible values are defined [here](http://awesome.naquadah.org/doc/api/modules/naughty.html#notify).

Notification will show an icon displaying current day, and formatted output
from ``cal`` with current day highlighted.

You can call the notification with a key binding like this:

    awful.key({ altkey }, "c", function () lain.widgets.calendar:show(7) end),

where ``altkey = "Mod1"`` and ``show`` argument is an optional integer, meaning timeout seconds.

**Note that** this widget exploits ``cal`` to do the alignment, in order to avoid more dozens of code lines, but this requires that your system font is monospaced.