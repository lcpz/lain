[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

**Please be warned**: this is a temporary solution, since it works fine in normal situations but may causes little freezes if connection is sobbing. I am working on something much more solid.

---

Shows mail status in a textbox over IMAP protocol.

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

Variable | Meaning | Type
--- | --- | ---
`server` | Mail server | string
`mail` | User mail | string
`password` | User password | string

while the optional are:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`port` | IMAP port | int | 993
`timeout` | Refresh timeout seconds | int | 60
`encoding` | Mail character encoding | string | autodetected
`maxlen` | Maximum chars to display in notification | int | 200
`is_plain` | Define whether `password` is a plain password (true) or a function that retrieves it (false) | boolean | false
`settings` | User settings | function

Let's focus better on `is_plain`.

You can just set your password like this:

    args.is_plain = false
    args.password = "mypassword"

and you'll have the same security provided by `~/.netrc`.

**Or** you can use a keyring, like [python keyring](https://pypi.python.org/pypi/keyring):

    args.password = "keyring get password"

When `is_plain == false`, it *executes* `password` before using it, so you can also use whatever password fetching solution you want.

`settings` can use the string `mailcount`, whose possible values are:

- "0"
- "invalid credentials"
- string number

and can modify `notification_preset` table, which will be the preset for the naughty notifications. Check [here](http://awesome.naquadah.org/doc/api/modules/naughty.html#notify) for the list of variables it can contain. Default definition:

    notification _preset = {
       icon = lain/icons/mail.png,
       timeout = 8,
       position = "top_left"
    }

### output 

A textbox.