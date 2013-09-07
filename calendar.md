Attaches a calendar to a ``widget``.

    lain.widgets.calendar:attach(mywidget)

- Left click: switch to previous month.
- Right click: switch to next month.

Optionally you can call the function with background and foreground colors arguments, both or just one:

    lain.widgets.calendar:attach(mytextclock, "#FFFFFF", "#000000")
    -- or
    lain.widgets.calendar:attach(mytextclock, "#FFFFFF")
    -- or
    lain.widgets.calendar:attach(mytextclock, nil, "#000000")

Notification will show an icon displaying current day, and formatted output
from ``cal`` with current day highlighted.

Calendar icons are placed in [lain/icons/cal](https://github.com/copycat-killer/lain/tree/master/icons/cal), default set being ``white``.

You can add your own set, and tell lain to use it like this:

    lain.widgets.calendar.icons_dir = lain.widgets.icons_dir .. "cal/myicons"

also, you can set notification font size:

    lain.widgets.calendar.font_size = 14

default is 12.

Finally, you can call the notification with a key binding like this:

    awful.key({ altkey }, "c", function () lain.widgets.calendar:show(7) end),

where ``altkey = "Mod1"`` and ``show`` argument is an optional integer, meaning timeout seconds.