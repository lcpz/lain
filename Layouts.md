Currently, there are **8** layouts.

    lain/layout
    .
    |-- termfair
    |-- centerfair
    |-- cascade
    |-- cascadetile
    |-- centerwork
    |-- uselessfair
    |-- uselesspiral
    `-- uselesstile

Just add your favourites to ``layouts`` table:

    layouts =
    {
        ...
        lain.layout.termfair,
        lain.layout.uselesstile,
        ...
    }

Or set them on specific tags like this:

	awful.layout.set(lain.layout.uselessfair, tags[1][7])

How do layouts work?
=========================

termfair
--------

I do a lot of work on terminals. The common tiling algorithms usually
maximize windows, so you'll end up with a terminal that has about 200
columns or more. That's way too much. Have you ever read a manpage in a
terminal of this size?

This layout restricts the size of each window. Each window will have the
same width but is variable in height. Furthermore, windows are
left-aligned. The basic workflow is as follows (the number above the
screen is the number of open windows, the number in a cell is the fixed
number of a client):

	     (1)                (2)                (3)
	+---+---+---+      +---+---+---+      +---+---+---+
	|   |   |   |      |   |   |   |      |   |   |   |
	| 1 |   |   |  ->  | 2 | 1 |   |  ->  | 3 | 2 | 1 |  ->
	|   |   |   |      |   |   |   |      |   |   |   |
	+---+---+---+      +---+---+---+      +---+---+---+

	     (4)                (5)                (6)
	+---+---+---+      +---+---+---+      +---+---+---+
	| 4 |   |   |      | 5 | 4 |   |      | 6 | 5 | 4 |
	+---+---+---+  ->  +---+---+---+  ->  +---+---+---+
	| 3 | 2 | 1 |      | 3 | 2 | 1 |      | 3 | 2 | 1 |
	+---+---+---+      +---+---+---+      +---+---+---+

The first client will be located in the left column. When opening
another window, this new window will be placed in the left column while
moving the first window into the middle column. Once a row is full,
another row above it will be created.

Default number of columns and rows are respectively taken from `nmaster`
and `ncol` values in `awful.tag`, but you can set your own.

For example, this sets `termfair` to 3 columns and at least 1 row:

    lain.layout.termfair.nmaster = 3
    lain.layout.termfair.ncol = 1

centerfair
----------

Similar to `termfair`, but with fixed number of vertical columns. Cols are centerded until there is nmaster columns, then windows are stacked in the slave columns, with at most ncol clients per column if possible.

            (1)                (2)                (3)
       +---+---+---+      +-+---+---+-+      +---+---+---+
       |   |   |   |      | |   |   | |      |   |   |   |
       |   | 1 |   |  ->  | | 1 | 2 | | ->   | 1 | 2 | 3 |  ->
       |   |   |   |      | |   |   | |      |   |   |   |
       +---+---+---+      +-+---+---+-+      +---+---+---+

            (4)                (5)
       +---+---+---+      +---+---+---+
       |   |   | 3 |      |   | 2 | 4 |
       + 1 + 2 +---+  ->  + 1 +---+---+
       |   |   | 4 |      |   | 3 | 5 |
       +---+---+---+      +---+---+---+

Like `termfair`, default number of columns and rows are respectively taken from `nmaster`
and `ncol` values in `awful.tag`, but you can set your own.

For example:

    lain.layout.centerfair.nmaster = 3
    lain.layout.centerfair.ncol = 1

cascade
-------

Cascade all windows of a tag.

You can control the offsets by setting those two variables:

	lain.layout.cascade.cascade_offset_x = 64
	lain.layout.cascade.cascade_offset_y = 16

The following reserves space for 5 windows:

	lain.layout.cascade.nmaster = 5

That is, no window will get resized upon the creation of a new window,
unless there's more than 5 windows.

cascadetile
-----------

Similar to `awful.layout.suit.tile` layout, however, clients in the slave
column are cascaded instead of tiled.

Left column size can be set, otherwise is controlled by `mwfact` of the
tag. Additional windows will be opened in another column on the right.
New windows are placed above old windows.

Whether the slave column is placed on top of the master window or not is
controlled by the value of `ncol`. A value of 1 means "overlapping slave column"
and anything else means "don't overlap windows".

Usage example:

	lain.layout.cascadetile.cascade_offset_x = 2
	lain.layout.cascadetile.cascade_offset_y = 32
	lain.layout.cascadetile.extra_padding = 5
    lain.layout.cascadetile.nmaster = 5
    lain.layout.ncol = 1

`extra_padding` reduces the size of the master window if "overlapping
slave column" is activated. This allows you to see if there are any
windows in your slave column.

Setting `cascade_offset_x` to a very small value or even 0 is reccommended to avoid wasting space.

centerwork
----------

You start with one window, centered horizontally:

	+--------------------------+
	|       +----------+       |
	|       |          |       |
	|       |          |       |
	|       |          |       |
	|       |   MAIN   |       |
	|       |          |       |
	|       |          |       |
	|       |          |       |
	|       |          |       |
	|       +----------+       |
	+--------------------------+

This is your main working window. You do most of the work right here.
Sometimes, you may want to open up additional windows. They're put in
the following four slots:

	+--------------------------+
	| +---+ +----------+ +---+ |
	| |   | |          | |   | |
	| | 0 | |          | | 1 | |
	| |   | |          | |   | |
	| +---+ |   MAIN   | +---+ |
	| +---+ |          | +---+ |
	| |   | |          | |   | |
	| | 2 | |          | | 3 | |
	| |   | |          | |   | |
	| +---+ +----------+ +---+ |
	+--------------------------+

Yes, the number "four" is fixed. In total, you can only have five open
windows with this layout. Additional windows are not managed and set to
floating mode. **This is intentional**.

You can set the order of the four auxiliary windows. This is the default
configuration:

	lain.layout.centerwork.top_left = 0
	lain.layout.centerwork.top_right = 1
	lain.layout.centerwork.bottom_left = 2
	lain.layout.centerwork.bottom_right = 3

This means: The bottom left slot will be occupied by the third window
(not counting the main window). Suppose you want your windows to appear
in this order:

	+--------------------------+
	| +---+ +----------+ +---+ |
	| |   | |          | |   | |
	| | 3 | |          | | 0 | |
	| |   | |          | |   | |
	| +---+ |   MAIN   | +---+ |
	| +---+ |          | +---+ |
	| |   | |          | |   | |
	| | 2 | |          | | 1 | |
	| |   | |          | |   | |
	| +---+ +----------+ +---+ |
	+--------------------------+

This would require you to use these settings:

	lain.layout.centerwork.top_left = 3
	lain.layout.centerwork.top_right = 0
	lain.layout.centerwork.bottom_left = 2
	lain.layout.centerwork.bottom_right = 1

*Please note:* If you use Awesome's default configuration, navigation in
this layout may be very confusing. How do you get from the main window
to satellite ones depends on the order in which the windows are opened.
Thus, use of `awful.client.focus.bydirection()` is suggested.
Here's an example:

	globalkeys = awful.util.table.join(
        ...
	    awful.key({ modkey }, "j",
	        function()
	            awful.client.focus.bydirection("down")
	            if client.focus then client.focus:raise() end
	        end),
	    awful.key({ modkey }, "k",
	        function()
	            awful.client.focus.bydirection("up")
	            if client.focus then client.focus:raise() end
	        end),
	    awful.key({ modkey }, "h",
	        function()
	            awful.client.focus.bydirection("left")
	            if client.focus then client.focus:raise() end
	        end),
	    awful.key({ modkey }, "l",
	        function()
	            awful.client.focus.bydirection("right")
	            if client.focus then client.focus:raise() end
	        end),
	    ...
	)

uselessfair, uselesspiral & uselesstile
---------------------------------------
These are duplicates of the stock `fair`, `spiral` and `tile` layouts.

However, "useless gaps" (see below) have been added.

Useless gaps
============

Useless gaps are gaps between windows. They are "useless" because they
serve no special purpose despite increasing overview. I find it easier
to recognize window boundaries if windows are set apart a little bit.

The `uselessfair` layout, for example, looks like this:

	+================+
	#                #
	#  +---+  +---+  #
	#  | 1 |  |   |  #
	#  +---+  |   |  #
	#         | 3 |  #
	#  +---+  |   |  #
	#  | 2 |  |   |  #
	#  +---+  +---+  #
	#                #
	+================+

All of lain layouts provide useless gaps. To set the width of the gaps,
you have to add an item called `useless_gap_width` in your `theme.lua`.
If it doesn't exist, the width will default to 0.
Example:

	theme.useless_gap_width = 10

What about layout icons?
========================

They are located in ``lain/icons/layout``.

To use them, add lines to your ``theme.lua`` like this:

	theme.lain_icons         = os.getenv("HOME") .. "/.config/awesome/lain/icons/layout/default/"
	theme.layout_termfair    = theme.lain_icons .. "termfairw.png"
	theme.layout_cascade     = theme.lain_icons .. "cascadew.png"
	theme.layout_cascadetile = theme.lain_icons .. "cascadetilew.png"
	theme.layout_centerwork  = theme.lain_icons .. "centerworkw.png"

Credits goes to [Nicolas Estibals](https://github.com/nestibal) for creating
layout icons for default theme.

You can use them as a template for your custom versions.

[<- home](https://github.com/copycat-killer/lain/wiki)