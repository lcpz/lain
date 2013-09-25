[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Attaches a [taskwarrior](http://taskwarrior.org/projects/show/taskwarrior) notification to a widget, and lets to add/search tasks from the promptbox.

    lain.widgets.contrib.task:attach(widget, args)

`args` is an optional table which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`font_size` | Calendar font size | int | 12
`fg` | Calendar foreground color | string | `beautiful.fg_normal`
`bg` | Calendar background color | string | `beautiful.bg_normal`
`position` | Calendar position | string | "top_right"
`timeout` | Notification timeout seconds | int | 7

`position` possible values are defined [here](http://awesome.naquadah.org/doc/api/modules/naughty.html#notify).

Notification will show the output of `task` command.

You can call the notification with a key binding like this:

    awful.key({ modkey, altkey }, "t", lain.widgets.task.show),

where ``altkey = "Mod1"``.

And you can prompt to add/search a task with key bindings like these:

    awful.key({ modkey,         }, "t", lain.widgets.contrib.task.prompt_add),
    awful.key({ modkey, "Shift" }, "t", lain.widgets.contrib.task.prompt_search),