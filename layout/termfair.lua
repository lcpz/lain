
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014,      projektile                 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local tag       = require("awful.tag")
local beautiful = require("beautiful")
local math      = { ceil  = math.ceil,
                    floor = math.floor,
                    max   = math.max }
local tonumber  = tonumber

local termfair  = { name = "termfair" }

function termfair.arrange(p)
    -- Layout with fixed number of vertical columns (read from nmaster).
    -- New windows align from left to right. When a row is full, a now
    -- one above it is created. Like this:

    --        (1)                (2)                (3)
    --   +---+---+---+      +---+---+---+      +---+---+---+
    --   |   |   |   |      |   |   |   |      |   |   |   |
    --   | 1 |   |   |  ->  | 2 | 1 |   |  ->  | 3 | 2 | 1 |  ->
    --   |   |   |   |      |   |   |   |      |   |   |   |
    --   +---+---+---+      +---+---+---+      +---+---+---+

    --        (4)                (5)                (6)
    --   +---+---+---+      +---+---+---+      +---+---+---+
    --   | 4 |   |   |      | 5 | 4 |   |      | 6 | 5 | 4 |
    --   +---+---+---+  ->  +---+---+---+  ->  +---+---+---+
    --   | 3 | 2 | 1 |      | 3 | 2 | 1 |      | 3 | 2 | 1 |
    --   +---+---+---+      +---+---+---+      +---+---+---+

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

    -- Screen.
    local wa = p.workarea
    local cls = p.clients

    -- Borders are factored in.
    wa.height = wa.height - ((global_border * 2) + (bw * 2))
    wa.width = wa.width - ((global_border * 2) + (bw * 2))

    -- How many vertical columns?
    local t = tag.selected(p.screen)
    local num_x = termfair.nmaster or tag.getnmaster(t)

    -- Do at least "desired_y" rows.
    local desired_y = termfair.ncol or tag.getncol(t)

    if #cls > 0
    then
        local num_y = math.max(math.ceil(#cls / num_x), desired_y)
        local cur_num_x = num_x
        local at_x = 0
        local at_y = 0
        local remaining_clients = #cls
        local width = math.floor(wa.width / num_x)
        local height = math.floor(wa.height / num_y)

        -- We start the first row. Left-align by limiting the number of
        -- available slots.
        if remaining_clients < num_x
        then
            cur_num_x = remaining_clients
        end

        -- Iterate in reversed order.
        for i = #cls,1,-1
        do
            -- Get x and y position.
            local c = cls[i]
            local this_x = cur_num_x - at_x - 1
            local this_y = num_y - at_y - 1

            -- Calc geometry.
            local g = {}
            if this_x == (num_x - 1)
            then
                g.width = wa.width - (num_x - 1) * width - useless_gap
            else
                g.width = width - useless_gap
            end
            if this_y == (num_y - 1)
            then
                g.height = wa.height - (num_y - 1) * height - useless_gap
            else
                g.height = height - useless_gap
            end

            g.x = wa.x + this_x * width + global_border
            g.y = wa.y + this_y * height + global_border

            if useless_gap > 0
            then
                -- All clients tile evenly.
                g.x = g.x + (useless_gap / 2)
                g.y = g.y + (useless_gap / 2)

            end
            c:geometry(g)
            remaining_clients = remaining_clients - 1

            -- Next grid position.
            at_x = at_x + 1
            if at_x == num_x
            then
                -- Row full, create a new one above it.
                at_x = 0
                at_y = at_y + 1

                -- We start a new row. Left-align.
                if remaining_clients < num_x
                then
                    cur_num_x = remaining_clients
                end
            end
        end
    end
end

return termfair
