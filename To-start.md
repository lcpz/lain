All you have to do to include the module:

	local lain = require("lain")

Some widgets require a terminal, lain default is `xterm`, but can be changed:

	lain.widgets.terminal = "urxvtc"

or

	lain.widgets.terminal = terminal

providing you have something like this:

    terminal = "urxvtc"

in your `rc.lua`.

`terminal` may also be a lua function that accepts one parameter.
Something like this:

	function footerm(cmd)
           -- elaborate cmd
	end

	lain.widgets.terminal = footerm
