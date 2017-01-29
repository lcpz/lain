
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local textbox      = require("wibox.widget.textbox")
local setmetatable = setmetatable

-- Template for custom asynchronous widgets
-- lain.widgets.abase

local function worker(args)
    local abase     = {}
    local args      = args or {}
    local timeout   = args.timeout or 5
    local nostart   = args.nostart or false
    local stoppable = args.stoppable or false
    local cmd       = args.cmd
    local settings  = args.settings or function() widget:set_text(output) end

    abase.widget = args.widget or textbox()

    function abase.update()
        helpers.async(cmd, function(f)
            output = f
            if output ~= abase.prev then
                widget = abase.widget
                settings()
                abase.prev = output
            end
        end)
    end

    abase.timer = helpers.newtimer(cmd, timeout, abase.update, nostart, stoppable)

    return abase
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
