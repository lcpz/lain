
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
-- lain.widget.contrib.kblayout

local function factory(args)
    local kbdlayout        = { widget = wibox.widget.textbox() }
    local args             = args or {}
    local layouts          = args.layouts or {}
    local settings         = args.settings or function () end
    local add_us_secondary = true
    local timeout          = args.timeout or 5
    local idx              = 1

    if args.add_us_secondary == false then add_us_secondary = false end

    local function kbd_run_settings(layout, variant)
        kbdlayout_now = {
            layout  = string.match(layout, "[^,]+"), -- Make sure to match the primary layout only.
            variant = variant
        }
        widget = kbdlayout.widget
        settings()
    end

    function kbdlayout.update()
        helpers.async("setxkbmap -query", function(status)
            kbd_run_settings(string.match(status, "layout:%s*([^\n]*)"),
            string.match(status, "variant:%s*([^\n]*)"))
        end)
    end

    function kbdlayout.set(i)
        if #layouts == 0 then return end
        idx = ((i - 1) % #layouts) + 1 -- Make sure to wrap around as needed.
        local to_execute = "setxkbmap " .. layouts[idx].layout

        if add_us_secondary and not string.match(layouts[idx].layout, ",?us,?") then
            to_execute = to_execute .. ",us"
        end

        if layouts[idx].variant then
            to_execute = to_execute .. " " .. layouts[idx].variant
        end

        if execute(to_execute) then
            kbd_run_settings(layouts[idx].layout, layouts[idx].variant)
        end
   end

   function kbdlayout.next() kbdlayout.set(idx + 1) end
   function kbdlayout.prev() kbdlayout.set(idx - 1) end

   -- Mouse bindings
   kbdlayout.widget:buttons(awful.util.table.join(
                              awful.button({ }, 1, function () kbdlayout.next() end),
                              awful.button({ }, 3, function () kbdlayout.prev() end)))

   helpers.newtimer("kbdlayout", timeout, kbdlayout.update)

   return kbdlayout
end

return factory
