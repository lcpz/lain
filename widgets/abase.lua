
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Luke Bonham                     
                                                  
--]]

local helpers = require("lain.helpers")
local async   = require("lain.asyncshell")
local wibox   = require("wibox")

local setmetatable = setmetatable

-- Basic template for custom widgets
-- Asynchronous version
-- lain.widgets.abase

local function worker(args)
    local abase    = {}
    local args     = args or {}
    local timeout  = args.timeout or 1
    local cmd      = args.cmd or ""
    local settings = args.settings or function() end

    abase.widget = wibox.widget.textbox('')
    helpers.set_map(cmd, '')

    function abase.update()
        async.request(cmd, function(f)
            output = f

            if helpers.get_map(cmd) ~= output then
                widget = abase.widget
                settings()
                helpers.set_map(cmd, output)
            end
        end)
    end

    helpers.newtimer(cmd, timeout, abase.update)

    return setmetatable(abase, { __index = abase.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
