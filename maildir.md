[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows maildirs status in a textbox.

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

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 60
`mailpath` | Path to your maildir | string | "~/Mail"
`settings` | User settings | function | empty function

`settings` can use the string `newmail`, which format will be something like defined above, or "no mail".

### output

A textbox.