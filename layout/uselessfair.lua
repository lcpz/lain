
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014,      projektile                 
      * (c) 2013,      Luke Bonham                
      * (c) 2012,      Josh Komoroske             
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local beautiful = require("beautiful")
local ipairs    = ipairs
local math      = { ceil = math.ceil, sqrt = math.sqrt }
local tonumber  = tonumber

local uselessfair = {}

local function fair(p, orientation)
    -- A useless gap (like the dwm patch) can be defined with
    -- beautiful.useless_gap_width.
    local useless_gap = tonumber(beautiful.useless_gap_width) or 0
    if useless_gap < 0 then useless_gap = 0 end

    -- A global border can be defined with
    -- beautiful.global_border_width.
    local global_border = tonumber(beautiful.global_border_width) or 0
    if global_border < 0 then global_border = 0 end

    -- Themes border width requires an offset.
    local bw = tonumber(beautiful.border_width) or 0

    -- get our orientation right.
    local wa = p.workarea
    local cls = p.clients

    wa.height = wa.height - ((global_border * 2) + (bw * 2))
    wa.width = wa.width - ((global_border * 2) + (bw * 2))

    if #cls > 0 then
        local cells = math.ceil(math.sqrt(#cls))
        local strips = math.ceil(#cls / cells)

        local cell = 0
        local strip = 0
        for k, c in ipairs(cls) do
            local g = {}
            -- Save actual grid index for use in the useless_gap
            -- routine.
            local this_x = 0
            local this_y = 0
            if ( orientation == "east" and #cls > 2 )
            or ( orientation == "south" and #cls <= 2 ) then
                if #cls < (strips * cells) and strip == strips - 1 then
                    g.width = wa.width / (cells - ((strips * cells) - #cls))
                else
                    g.width = wa.width / cells
                end
                g.height = wa.height / strips

                this_x = cell
                this_y = strip

                g.x = wa.x + cell * g.width + global_border
                g.y = wa.y + strip * g.height + global_border

            else
                if #cls < (strips * cells) and strip == strips - 1 then
                    g.height = wa.height / (cells - ((strips * cells) - #cls))
                else
                    g.height = wa.height / cells
                end
                g.width = wa.width / strips

                this_x = strip
                this_y = cell

                g.x = wa.x + strip * g.width + global_border
                g.y = wa.y + cell * g.height + global_border

            end

            -- Useless gap.
            if useless_gap > 0
            then
                -- All clients tile evenly.
                g.width = g.width - useless_gap
                g.x = g.x + (useless_gap / 2)
                g.height = g.height - useless_gap
                g.y = g.y + (useless_gap / 2)

            end
            -- End of useless gap.

            c:geometry(g)

            cell = cell + 1
            if cell == cells then
                cell = 0
                strip = strip + 1
            end
        end
    end
end

--- Horizontal fair layout.
-- @param screen The screen to arrange.
uselessfair.horizontal = {}
uselessfair.horizontal.name = "uselessfairh"
function uselessfair.horizontal.arrange(p)
    return fair(p, "east")
end

-- Vertical fair layout.
-- @param screen The screen to arrange.
uselessfair.name = "uselessfair"
function uselessfair.arrange(p)
    return fair(p, "south")
end

return uselessfair
