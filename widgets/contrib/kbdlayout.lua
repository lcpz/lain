
local newtimer     = require("lain.helpers").newtimer
local wibox        = require("wibox")

local string       = { match = string.match }
local io           = { popen = io.popen }

local setmetatable = setmetatable

local function worker (args)
   local kbdlayout    = {}
   kbdlayout.widget   = wibox.widget.textbox('')

   local settings     = args.settings or function () end
   local layouts      = args.layouts
   local idx          = 1
   
   local function run_settings (layout, variant)
      widget = kbdlayout.widget
      kbdlayout_now = { layout=layout, variant=variant }
      settings()
   end
   
   function kbdlayout.update ()
      local file   = assert(io.popen('setxkbmap -query'))
      local status = file:read('*all')
      file:close()

      run_settings(string.match(status, "layout:%s*([^\n]*)%s*"),
		   string.match(status, "variant:%s*([^\n]*)%s*"))
   end

   function kbdlayout.set (i)
      idx = ((i - 1) % #layouts) + 1 -- Make sure to wrap around as needed.
      local to_execute = 'setxkbmap ' .. layouts[idx].layout

      if layouts[idx].variant then
	 to_execute = to_execute .. ' ' .. layouts[idx].variant
      end

      if os.execute(to_execute) then
	 run_settings(layouts[idx].layout, layouts[idx].variant)
      end
   end

   function kbdlayout.next ()
      kbdlayout.set(idx + 1)
   end

   function kbdlayout.prev ()
      kbdlayout.set(idx - 1)
   end

   newtimer("kbdlayout", args.timeout or 10, kbdlayout.update)
   return setmetatable(kbdlayout, { __index = kbdlayout.widget })
end

return setmetatable({}, { __call = function (_, ...) return worker(...) end })
