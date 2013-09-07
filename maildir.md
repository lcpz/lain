Checks your maildirs.

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

therefore the widget checks whether there are files in the `new` directories.
If there's new mails, the textbox will say something like "mail: bugs(3), system(1)", otherwise it says
"no mail".

	mymaildir = lain.widgets.maildir("/path/to/my/maildir")

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`mailpath` | Path to your maildir | string | "~/Mail"
`ignore_boxes` | A list of boxes to ignore | table | empty table
`refresh_timeout` | Refresh timeout seconds | int | 60
`header` | Text to show before value | string | " Mail "
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color_newmail` | New mail value color | string | `beautiful.fg_focus` or "#FFFFFF"
`color_nomail` | No mail value color | string | `beautiful.fg_normal` or "#FFFFFF"
`app` | Mail program to spawn on click | string | "mutt"| boolean | false
`shadow` | Hide widget when there are no mails | boolean | false