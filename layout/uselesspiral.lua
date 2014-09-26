
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014       projektile                 
      * (c) 2013       Luke Bonham                
      * (c) 2009       Uli Schlachter             
      * (c) 2008       Julien Danjolu             
                                                  
--]]

local beautiful = require("beautiful")
local ipairs    = ipairs
local tonumber  = tonumber
local math      = require("math")

local uselesspiral = {}

local function spiral(p, spiral)
    -- A useless gap (like the dwm patch) can be defined with
    -- beautiful.useless_gap_width.
    local useless_gap = tonumber(beautiful.useless_gap_width) or 0
    if useless_gap < 0 then useless_gap = 0 end

    -- A global border can be defined with
    -- beautiful.global_border_width
    local global_border = tonumber(beautiful.global_border_width) or 0
    if global_border < 0 then global_border = 0 end

    -- Themes border width requires an offset
    local bw = tonumber(beautiful.border_width) or 0

    -- get our orientation right
    local wa = p.workarea
    local cls = p.clients
    local n = #cls -- number of windows total; k = which window number

    wa.height = wa.height - ((global_border * 2) + (bw * 2))
    wa.width = wa.width - ((global_border * 2) + (bw * 2))

    local static_wa = wa

    for k, c in ipairs(cls) do
        if k < n then
            if k % 2 == 0 then
                wa.height = (wa.height / 2)
            else
                wa.width = (wa.width / 2)
            end
        end

        if k % 4 == 0 and spiral then
            wa.x = wa.x - wa.width
        elseif k % 2 == 0 or
            (k % 4 == 3 and k < n and spiral) then
            wa.x = wa.x + wa.width
        end

        if k % 4 == 1 and k ~= 1 and spiral then
            wa.y = wa.y - wa.height
        elseif k % 2 == 1 and k ~= 1 or
            (k % 4 == 0 and k < n and spiral) then
            wa.y = wa.y + wa.height
        end

            local wa2 = {}
            wa2.x = wa.x + (useless_gap / 2) + global_border
            wa2.y = wa.y + (useless_gap / 2) + global_border
            wa2.height = wa.height - (useless_gap / 2)
            wa2.width = wa.width - (useless_gap / 2)

        -- Useless gap.
        if useless_gap > 0
        then
            -- Top and left clients are shrinked by two steps and
            -- get moved away from the border. Other clients just
            -- get shrinked in one direction.

            top = false
            left = false

            if wa2.y == static_wa.y then
               top = true
            end

            if wa2.x == static_wa.x then
               left = true
            end

            if top then
                wa2.height = wa2.height - useless_gap
                wa2.y = wa2.y - (useless_gap / 2)
            else
                wa2.height = wa2.height - (useless_gap / 2)
            end

            if left then
                wa2.width = wa2.width - useless_gap
                wa2.x = wa2.x - (useless_gap / 2)
            else
                wa2.width = wa2.width - (useless_gap / 2)
            end
        end
        -- End of useless gap.

        c:geometry(wa2)
    end
end

--- Dwindle layout
uselesspiral.dwindle = {}
uselesspiral.dwindle.name = "uselessdwindle"
function uselesspiral.dwindle.arrange(p)
    return spiral(p, false)
end

--- Spiral layout
uselesspiral.name = "uselesspiral"
function uselesspiral.arrange(p)
    return spiral(p, true)
end

return uselesspiral
