
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local wibox        = require("wibox")
local setmetatable = setmetatable

-- Basic template for custom widgets
-- lain.widgets.base

local function worker(args)
    local base      = helpers.make_widget_textbox()
    local args      = args or {}
    local timeout   = args.timeout or 5
    local nostart   = args.nostart or false
    local stoppable = args.stoppable or false
    local cmd       = args.cmd or ""
    local settings  = args.settings or function() end

    base.widget = wibox.widget.textbox()

    function base.update()
        output = helpers.read_pipe(cmd)
        if output ~= base.prev then
            widget = base.widget
            settings()
            base.prev = output
        end
    end

    base.timer = helpers.newtimer(cmd, timeout, base.update, nostart, stoppable)

    return setmetatable(base, { __index = base.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
