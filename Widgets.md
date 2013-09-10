Every widget is output by a `function`.

Unless otherwise expressly noted, `function` returns a `wibox.widget.textbox`.

This is said because, for some widgets, `function` returns a table to be used for notification and update purposes.

Every widget may take either a table or a list of variables as argument.

If it takes a table, you have to define a function variable called `settings` in it: with this you can markup textboxes using predefined variables and do whatever customization you want.

I'll give an example: 

    mycpu = lain.widgets.cpu({
        timeout = 4,
        settings = function()
            widgets:set_markup("Cpu " .. usage)
        end
    })

check the sections for all the details.

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