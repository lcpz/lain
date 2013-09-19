[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Creates a thin wibox at a position relative to another wibox.

This allows to create "borders" for your wiboxes.

	lain.widget.borderbox(relbox, s, args)

`relbox` and `s` (an integer being screen number) are required arguments, `args` is an optional table
which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`position` | Position of the additional box | string | "above"
`color` | Color of the additional box | string | `#FFFFFF`
`size` | Size in pixels of the additional box | int | 1

Possible values for `.position`: `top`, `bottom`, `left` and `right`.

### Example usage

Think of this as a wibox:

	[======================]

If `args.position = "above"`, then you'll get an additional wibox below
the existing one:

	________________________
	[======================]

It'll match position and size of the existing wibox.

If your main wiboxes are stored in a table called `mywibox` (one wibox
for each screen) and are located at the bottom of your screen, then this
adds a borderbox on top of them:

    -- Layout section
	for s = 1, screen.count() do
        ...

	    -- Most likely, you'll want to do this as well:
	    awful.screen.padding(screen[s], "bottom")

	    -- Create the box and place it above the existing box.
	    lain.widgets.borderbox(mywibox[s], s, { position = "above" } )

        ...
	end