General usage
-------------

Every widget is output by a `function`.

For some widgets, `function` returns a `wibox.widget.textbox`, for others a table to be used for notification and update purposes.

Every widget may take either a table or a list of variables as argument.

If it takes a table, you have to define a function variable called `settings` in it, in order to make your customizations.

To markup the textbox, call `widget:set_markup(...)` within `settings`.

You can feed `set_markup` with predefined arguments, see the sections for all the details.

`widget` is a textbox, so you can threat it like any other `wibox.widget.textbox`.

Here follows an example: 

    mycpu = lain.widgets.cpu({
        timeout = 4,
        settings = function()
            widget:set_markup("Cpu " .. cpu_now.usage)
        end
    })

If you want to see more complex applications, check [awesome-copycats](https://github.com/copycat-killer/awesome-copycats).

Index
-----

- [alsa](https://github.com/copycat-killer/lain/wiki/alsa)
- [alsabar](https://github.com/copycat-killer/lain/wiki/alsabar)
- [bat](https://github.com/copycat-killer/lain/wiki/bat)
- [borderbox](https://github.com/copycat-killer/lain/wiki/borderbox)
- [calendar](https://github.com/copycat-killer/lain/wiki/calendar)
- [cpu](https://github.com/copycat-killer/lain/wiki/cpu)
- [fs](https://github.com/copycat-killer/lain/wiki/fs)
- [imap](https://github.com/copycat-killer/lain/wiki/imap)
- [maildir](https://github.com/copycat-killer/lain/wiki/maildir)
- [mem](https://github.com/copycat-killer/lain/wiki/mem)
- [mpd](https://github.com/copycat-killer/lain/wiki/mpd)
- [net](https://github.com/copycat-killer/lain/wiki/net)
- [sysload](https://github.com/copycat-killer/lain/wiki/sysload)
- [temp](https://github.com/copycat-killer/lain/wiki/temp)
- [yawn](https://github.com/copycat-killer/lain/wiki/yawn)

Users contributed
----------------

- [task](https://github.com/copycat-killer/lain/wiki/task)
- [tpbat](https://github.com/copycat-killer/lain/wiki/tpbat)