Check new mails over IMAP protocol.

Dependencies:

- Python3

New mails are notified through a notification like this:

	+---------------------------------------------------+
	| +---+                                             |
	| |\ /| donald@disney.org has 3 new messages        |
	| +---+                                             |
	|       Latest From: Mickey Mouse <boss@disney.org> |
    |       Subject: Re: pay raise                      |
    |                                                   |
    |       Not after what you did yesterday.           |
    |       Daisy told me everything [...]              |
	|                                                   |
	+---------------------------------------------------+

Text will be cut if the mail is too long.

	myimapcheck = lain.widgets.imap(args)

The function takes a table as argument. Required table parameters are:

Variable | Type
--- | --- 
`server` | string
`mail` | string
`password` | string

while the optional are:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`port` | IMAP port | int | 993
`refresh_timeout` | Refresh timeout seconds | int | 60
`header` | Text to show before value | string | " Mail "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color_newmail` | New mail value color | string | `beautiful.fg_focus` or "#FFFFFF"
`color_nomail` | No mail value color | string | `beautiful.fg_normal` or "#FFFFFF"
`mail_encoding` | Mail character encoding | string | autodetected
`maxlen` | Maximum chars to display in notification | int | 200
`app` | Mail program to spawn on click | string | "mutt"
`shadow` | Hide widget when there are no mails | boolean | false
`is_plain` | Define whether `password` is a plain password (true) or a function that retrieves it (false) | boolean | false

Let's focus better on `is_plain`.

You can just set your password like this:

    args.is_plain = false
    args.password = "mypassword"

and you'll have the same security provided by `~/.netrc`

**Or** you can use a keyring, like [python keyring](https://pypi.python.org/pypi/keyring):

    args.password = "keyring get password"

When `is_plain == false`, it *executes* `password` before using it, so you can also use whatever password fetching solution you want.

You can also define your custom icon for the naughty notification. Just set `lain_mail_notify` into `theme.lua`.