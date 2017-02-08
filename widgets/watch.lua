
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local textbox      = require("wibox.widget.textbox")
local setmetatable = setmetatable

-- Template for asynchronous watcher widgets
-- lain.widgets.watch

local function worker(args)
    local watch     = {}
    local args      = args or {}
    local timeout   = args.timeout or 5
    local nostart   = args.nostart or false
    local stoppable = args.stoppable or false
    local cmd       = args.cmd
    local settings  = args.settings or function() widget:set_text(output) end

    watch.widget = args.widget or textbox()

    function watch.update()
        helpers.async(cmd, function(f)
            output = f
            if output ~= watch.prev then
                widget = watch.widget
                settings()
                watch.prev = output
            end
        end)
    end

    watch.timer = helpers.newtimer(cmd, timeout, watch.update, nostart, stoppable)

    return watch
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
