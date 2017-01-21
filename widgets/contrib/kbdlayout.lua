
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2015, Dario Gjorgjevski               
                                                  
--]]

local helpers      = require("lain.helpers")

local awful        = require("awful")
local wibox        = require("wibox")

local string       = { format = string.format,
                       match  = string.match }
local execute      = os.execute

local setmetatable = setmetatable

-- Keyboard layout switcher
-- lain.widgets.contrib.kblayout

local function worker(args)
   local kbdlayout        = {}
   local layouts          = args.layouts
   local settings         = args.settings or function () end
   local add_us_secondary = true
   local timeout          = args.timeout or 5
   local idx              = 1

   if args.add_us_secondary == false then add_us_secondary = false end

   kbdlayout.widget = wibox.widget.textbox()

   -- Mouse bindings
   kbdlayout.widget:buttons(awful.util.table.join(
                              awful.button({ }, 1, function () kbdlayout.next() end),
                              awful.button({ }, 3, function () kbdlayout.prev() end)))

   local function run_settings(layout, variant)
      kbdlayout_now = {
          layout  = string.match(layout, "[^,]+"), -- Make sure to match the primary layout only.
          variant = variant
      }
      widget = kbdlayout.widget
      settings()
   end

   function kbdlayout.update()
      helpers.async(string.format("%s -c 'setxkbmap -query'", awful.util.shell),
      function(status)
          run_settings(string.match(status, "layout:%s*([^\n]*)"),
          string.match(status, "variant:%s*([^\n]*)"))
      end)
   end

   function kbdlayout.set(i)
      idx = ((i - 1) % #layouts) + 1 -- Make sure to wrap around as needed.
      local to_execute = "setxkbmap " .. layouts[idx].layout

      if add_us_secondary and not string.match(layouts[idx].layout, ",?us,?") then
         to_execute = to_execute .. ",us"
      end

      if layouts[idx].variant then
         to_execute = to_execute .. " " .. layouts[idx].variant
      end

      if execute(to_execute) then
         run_settings(layouts[idx].layout, layouts[idx].variant)
      end
   end

   function kbdlayout.next()
      kbdlayout.set(idx + 1)
   end

   function kbdlayout.prev()
      kbdlayout.set(idx - 1)
   end

   helpers.newtimer("kbdlayout", timeout, kbdlayout.update)

   return setmetatable(kbdlayout, { __index = kbdlayout.widget })
end

return setmetatable({}, { __call = function (_, ...) return worker(...) end })
