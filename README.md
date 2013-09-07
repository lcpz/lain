VAin agaIN
==========

Author: Luke Bonham <dada [at] archlinux [dot] info>

Source: https://github.com/copycat-killer/vain

Version: 1.9.9

Release version: 2.0

**Please note**: until release version, this documentation will be not updated.

Foreword
--------

Based on a port of [awesome-vain](https://github.com/vain/awesome-vain), this
costantly evolving module provides new layouts, a set of widgets and
utility functions in order to improve Awesome usability and configurability.

This work is licensed under [GNU GPLv2 License](http://www.gnu.org/licenses/gpl-2.0.html).
Installation
============

Simply clone this repository into your Awesome directory.

Widgets
=======

systemload
----------

Show the current system load in a textbox. Read it directly from
`/proc/loadavg`.

	mysysload = vain.widgets.systemload()

A click on the widget will call `htop` in your `terminal`.

The function takes a table as an optional argument. That table may
contain:

* `.refresh_timeout`: Default to 10 seconds.
* `.show_all`: Show all three values (`true`) or only the first one (`false`). Default to `false`.
* `.color`: Default to beautiful.bg_normal or "#FFFFFF".

cpu
--------

Shows the average CPU usage percent for a given amount of time.

	mycpuusage = vain.widgets.cpu()

A click on the widget will call `htop` in your `terminal`.

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`refresh_timeout` | Refresh timeout seconds | int | 10
`header` | Text to show before value | string | " Vol "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"
`footer` | Text to show after value | string | "%"

**Note**: `footer` color is `color`.

memusage
--------

Show used memory and total memory in MiB.

	mymem = vain.widgets.mem()


The function takes a table as an optional argument. That table may
contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`refresh_timeout` | Refresh timeout seconds | int | 10
`show_swap` | Show amount of used swap space? | boolean | false
`show_total` | Show amout of total memory? | boolean | false
`header` | Text to show before value | string | " Vol "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color` | Value color | string | `beautiful.fg_focus` or "#FFFFFF"
`footer` | Text to show after value | string | "MB"

**Note**: `footer` color is `color`.

mailcheck
---------
Checks maildirs and shows the result in a textbox.
Maildirs are structured as follows:

	~/Mail
	.
	|-- arch
	|   |-- cur
	|   |-- new
	|   `-- tmp
	|-- gmail
	|   |-- cur
	|   |-- new
	|   `-- tmp
	.
	.
	.

therefore `mailcheck` checks whether there are files in the `new`
directories. To do so, it calls `find`. If there's new mail, the textbox
will say something like "mail: bugs(3), system(1)", otherwise it says
"no mail".

	mymailcheck = vain.widgets.mailcheck("/path/to/my/maildir")

The function takes a table as an optional argument. That table may
contain:

* `.mailprogram`: Your favourite mail program. Clicking on the widget will
  spawn it. Default is `mutt`.
* `.refresh_timeout`: Default to 60 seconds.
* `.mailpath`: Path to your maildir, default is `~/Mail`.
* `.ignore_boxes`: Another table which lists boxes (just the last part,
  like `lists`) to ignore. Default to an empty table.
* `.initial_update`: Check for mail when starting Awesome (`true`) or
  wait for the first refresh timeout (`false`)? Default to `false`.
* `.header_text`: Text to show along with output, default is "Mail".
* `.header_text_color`: Default to "#9E9E9E".
* `.color_newmail`: Default to "#D4D4D4".
* `.color_nomail`: Default to "#9E9E9E".
* `.shadow`: Hides widget when there are no mails. Default is `false`.

imapcheck
---------

Check new mails over imap protocol.

Dependencies:

* Python3

Since [luasec](https://github.com/brunoos/luasec/) is still not officially
supported in lua 5.2, writing a pure lua solution would have meant too many
hacks and dependencies, resulting in a very big and not efficient-proven submodule.

That's why I chose Python.

Python offers [imaplib](http://docs.python.org/2/library/imaplib.html), a simple yet powerful IMAP4 client library which provides encrypted communication over SSL sockets.

Basically, `imapcheck` calls ``vain/scripts/checkmail`` and parse its output in a widget. New mails are also notified through Naughty, with a popup like this:

	+---------------------------------------------------+
	| +---+                                             |
	| |\ /| donald@disney.org has 3 new messages        |
	| +---+                                             |
	|       Latest From: Mickey Mouse <boss@disney.org> |
    |       Subject: Re: Vacation Day                   |
    |                                                   |
    |       Not after what you did yesterday.           |
    |       Daisy told me everything [...]              |
	|                                                   |
	+---------------------------------------------------+

Text will be cut if the mail is too long.

	myimapcheck = vain.widgets.mailcheck(args)

The function takes a table as argument. Required table parameters are:

* `.server`: You email server. Example: `imap.gmail.com`.
* `.mail`: Your email.
* `.password`: Your email password.

while the optional are:

* `.port`: Imap port. Default is `993`.
* `.refresh_timeout`: Default to 60 seconds.
* `.notify_timeout`: Notification timeout. Default to 8 seconds.
* `.notify_position`: Notification position. Default is "top_left". Check
  [Naughty position parameter](http://awesome.naquadah.org/doc/api/modules/naughty.html) for a list of other possible values.
* `.mailprogram`: Your favourite mail program. Clicking on the widget will
  spawn it. Default is `mutt`.
* `.mail_encoding`: If you wish to set an encoding. Default is `nil`.
* `.initial_update`: Check for mail when starting Awesome (`true`) or
  wait for the first refresh timeout (`false`)? Default to `false`.
* `.header_text`: Text to show along with output, default is "Mail".
* `.header_text_color`: Default to "#9E9E9E".
* `.color_newmail`: Default to "#D4D4D4".
* `.color_nomail`: Default to "#9E9E9E".
* `.shadow`: Hides widget when there are no mails. Default is `false`.
* `.maxlen`: Maximum mail length. If mail is longer, it will be cut. Default is
  `100`.
* `.is_plain`: Define whether `.password` field is a plain password (`true`) or a function that retrieves it (`false`). Default to `false`.

Let's focus better on `.is_plain` parameter.

You can just easily set your password like this:

    args.is_plain = false
    args.password = "mypassword"

and you'll have the same security provided by `~/.netrc`. (In this case, it's
better to set your `rc.lua` permissions to 700 or 600)

**Or**, you can use a keyring, like gnome's:

    args.password = "gnome-keyring-query get password"

(`gnome-keyring-query` is not in gnome-keyring pkg, you have to download it
separately)

or the very light [python keyring](https://pypi.python.org/pypi/keyring).

When `.is_plain` is `false`, it *executes* `.password` before using it, so you can also use whatever password fetching solution you want.

You can also define your icon for the naughty notification. Just set `vain_mail_notify` into your ``theme.lua``.



mpd
---

Provides a `table` with 2 elements:

* `table["widget"]` is a textbox displaying current song in play.

* `table["force"]` is a function to *force* the widget to update, exactly
  like `vicious.force()`.

Also, a notification is shown when a new song is playing.

Dependencies:

* libnotify
* imagemagick


    mpdwidget = vain.widgets.mpd()
    ...
    right_layout:add(mpdwidget["widget"])

The function takes a table as an optional argument. That table may
contain:

* `.password`: Mpd password. Default is unset.
* `.host`: Mpd host. Default is "127.0.0.1" (localhost).
* `.port`: Mpd port. Default is "6600".
* `.music_dir`: Your music directory. Default is "~/Music". If you have to
  change this, be sure to write the absolute path.
* `.refresh_timeout`: Widget refresh timeout. Default is `1`.
* `.notify_timeout`: Notification timeout. Default is `5`.
* `.color_artist`: Artist name color. Default is `#9E9E9E`.
* `.color_song`: Song name color. Default is `#EBEBFF`.
* `.musicplr`: Your favourite music player. Clicking on the widget will spawn
  it. Default is `ncmpcpp`.
* `.shadow`: Hides widget when no song is playing. Default is `false`.

You can use `table["force"]` to make your mpd keybindings immediate.
Example usage:

    globalkeys = awful.util.table.join(
    ...
        -- Music control
        awful.key({ altkey, "Control" }, "Up", function ()
                                                  awful.util.spawn_with_shell( "mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle", false )
                                                  mpdwidget["force"]()
                                               end),
        awful.key({ altkey, "Control" }, "Down", function ()
                                                  awful.util.spawn_with_shell( "mpc stop || ncmpcpp stop || ncmpc stop || pms stop", false )
                                                  mpdwidget["force"]()
                                                 end ),
        awful.key({ altkey, "Control" }, "Left", function ()
                                                  awful.util.spawn_with_shell( "mpc prev || ncmpcpp prev || ncmpc prev || pms prev", false )
                                                  mpdwidget["force"]()
                                                 end ),
        awful.key({ altkey, "Control" }, "Right", function ()
                                                  awful.util.spawn_with_shell( "mpc next || ncmpcpp next || ncmpc next || pms next", false )
                                                  mpdwidget["force"]()
                                                  end ),

net
---

Monitors network interfaces and shows current traffic in a textbox. If
the interface is not present or if there's not enough data yet, you'll
see `wlan0: -` or similar.  Otherwise, the current traffic is shown in
kilobytes per second as `eth0: ↑(00,010.2), ↓(01,037.8)` or similar.

	neteth0 = vain.widgets.net()

The function takes a table as an optional argument. That table may
contain:

* `.iface`: Default to `eth0`.
* `.refresh_timeout`: Default to 2 seconds.
* `.color`: Default to beautiful.bg_normal or "#FFFFFF".

gitodo
------

This is an integration of [gitodo](https://github.com/vain/gitodo) into
Awesome.

	todolist = vain.widgets.gitodo()

The function takes a table as an optional argument. That table may
contain:

* `.refresh_timeout`: Default to 120 seconds.
* `.initial_update`: Check for todo items when starting Awesome (`true`)
  or wait for the first refresh timeout (`false`)? Default to `true`.

`beautiful.gitodo_normal` is used as the color for non-outdated items,
`beautiful.gitodo_warning` for those items close to their deadline and
`beautiful.gitodo_outdated` is the color of outdated items.



Utility functions
=================

I'll only explain the more complex functions. See the source code for
the others.

menu\_clients\_current\_tags
----------------------------

Similar to `awful.menu.clients()`, but this menu only shows the clients
of currently visible tags. Use it like this:

	globalkeys = awful.util.table.join(
	    ...
	    awful.key({ "Mod1" }, "Tab", function()
	        awful.menu.menu_keys.down = { "Down", "Alt_L", "Tab", "j" }
	        awful.menu.menu_keys.up = { "Up", "k" }
	        vain.util.menu_clients_current_tags({ width = 350 }, { keygrabber = true })
	    end),
	    ...
	)

magnify\_client
---------------

Set a client to floating and resize it in the same way the "magnifier"
layout does it. Place it on the "current" screen (derived from the mouse
position). This allows you to magnify any client you wish, regardless of
the currently used layout. Use it with a client keybinding like this:

	clientkeys = awful.util.table.join(
		...
		awful.key({ modkey, "Control" }, "m", vain.util.magnify_client),
		...
	)

If you want to "de-magnify" it, just reset the clients floating state to
`false` (hit `Mod4`+`CTRL`+`Space`, for example).

niceborder\_{focus, unfocus}
----------------------------

By default, your `rc.lua` contains something like this:

	client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
	client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

You can change it to this:

	client.connect_signal("focus", vain.util.niceborder_focus(c))
	client.connect_signal("unfocus", vain.util.niceborder_unfocus(c))

Now, when a client is focused or unfocused, Awesome will look up its
nice value in `/proc/<pid>/stat`. If it's less than 0, the client is
classified as "high priority"; if it's greater than 0, the client is
classified as "low priority". If it's equal to 0, nothing special
happens.

This requires to define additional colors in your `theme.lua`. For example:

	theme.border_focus_highprio  = "#FF0000"
	theme.border_normal_highprio = "#A03333"

	theme.border_focus_lowprio   = "#3333FF"
	theme.border_normal_lowprio  = "#333366"

tag\_view\_nonempty
------------------------------

This function lets you jump to the next/previous non-empty tag.
It takes two arguments:

* `direction`: `1` for next non-empty tag, `-1` for previous.
* `sc`: Screen in which the taglist is. Default is `mouse.screen` or `1`. This
  argument is optional.

Usage example:

	globalkeys = awful.util.table.join(
		...
        -- Non-empty tag browsing
        awful.key({ altkey }, "Left", function () vain.util.tag_view_nonempty(-1)
    end),
        awful.key({ altkey }, "Right", function () vain.util.tag_view_nonempty(1) end),
        ...

prompt\_rename\_tag
-------------------

This function enables you to dynamically rename the current tag you have
focused.
Usage example:

	globalkeys = awful.util.table.join(
	    ..
        -- Dynamic tag renaming
		awful.key({ modkey, "Shift" }, "r", function () vain.util.prompt_rename_tag(mypromptbox) end),
		...

Credits goes to [minism](https://bbs.archlinux.org/viewtopic.php?pid=1315135#p1315135).
