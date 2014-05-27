
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2014, blueluke <http://github.com/blueluke>
                                                   
--]]

local os = os
local awful = require("awful")
local spawn = awful.util.spawn_with_shell

local setmetatable = setmetatable

-- redshift
-- lain.widgets.contrib.redshift
local redshift = {}

local attached = false                       -- true if attached to a widget
local active = false                         -- true if redshift is active            
local running = false                        -- true if redshift was initialized 
local update_fnct = function() end           -- function that is run each time redshift is toggled. See redshift:attach().


local function init()
    -- As there is no way to determine if redshift was previously
    -- toggled off (i.e Awesome on-the-fly restart), kill redshift to make sure
    os.execute("pkill redshift")
    -- Remove existing color adjustment
    spawn("redshift -x")
    -- (Re)start redshift
    spawn("redshift")
    running = true
    active = true
end

function redshift:toggle()
    if running then 
        -- Sending -USR1 toggles redshift (See project website)
        os.execute("pkill -USR1 redshift")
        active = not active
    else 
        init()
    end
    update_fnct()
end

function redshift:off()
    if running and active then
        redshift:toggle()
    end
end

function redshift:on()
    if not active then
        redshift:toggle()
    end
end

function redshift:is_active()
    return active
end

-- Attach to a widget
-- Provides a button which toggles redshift on/off on click
-- @ param widget:  widget to attach to
-- @ param fnct:  function to be run each time redshift is toggled (optional).
--                         Use it to update widget text or icons on status change.
function redshift:attach(widget, fnct)
    update_fnct  = fnct or function() end
    if not attached then
        init()
        attached = true
        update_fnct()
    end
    widget:buttons(awful.util.table.join( awful.button({}, 1, function () redshift:toggle() end) ))
end

return setmetatable(redshift, { _call = function(_, ...) return create(...) end })
