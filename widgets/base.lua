
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
    local base     = {}
    local args     = args or {}
    local timeout  = args.timeout or 1
    local cmd      = args.cmd or ""
    local settings = args.settings or function() end

    base.widget = wibox.widget.textbox('')
    helpers.set_map(cmd, '')

    function base.update()
        output = helpers.read_pipe(cmd)

        if helpers.get_map(cmd) ~= output then
            widget = base.widget
            settings()
            helpers.set_map(cmd, output)
        end
    end

    helpers.newtimer(cmd, timeout, base.update)

    return setmetatable(base, { __index = base.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
