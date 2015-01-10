
--[[

     Licensed under GNU General Public License v2
      * (c) 2014,      projektile, worron
      * (c) 2013,      Luke Bonham
      * (c) 2012,      Josh Komoroske
      * (c) 2010-2012, Peter Hofmann

--]]

local beautiful = require("beautiful")
local ipairs    = ipairs
local math      = { ceil = math.ceil, sqrt = math.sqrt, floor = math.floor, max = math.max }
local tonumber  = tonumber

local uselessfair = {}

-- Transformation functions
local function swap(geometry)
    return { x = geometry.y, y = geometry.x, width = geometry.height, height = geometry.width }
end

-- Client geometry correction depending on useless gap and window border
local function size_correction(c, geometry, useless_gap)
    geometry.width  = math.max(geometry.width  - 2 * c.border_width - useless_gap, 1)
    geometry.height = math.max(geometry.height - 2 * c.border_width - useless_gap, 1)
    geometry.x = geometry.x + useless_gap / 2
    geometry.y = geometry.y + useless_gap / 2
end

-- Main tiling function
local function fair(p, orientation)

    -- Theme vars
    local useless_gap = beautiful.useless_gap_width or 0
    local global_border = beautiful.global_border_width or 0

    -- Aliases
    local wa = p.workarea
    local cls = p.clients

    -- Nothing to tile here
    if #cls == 0 then return end

    -- Workarea size correction depending on useless gap and global border
    wa.height = wa.height - 2 * global_border - useless_gap
    wa.width  = wa.width -  2 * global_border - useless_gap
    wa.x = wa.x + useless_gap / 2 + global_border
    wa.y = wa.y + useless_gap / 2 + global_border

    -- Geometry calculation
    local row, col = 0, 0

    local rows = math.ceil(math.sqrt(#cls))
    local cols = math.ceil(#cls / rows)

    for i, c in ipairs(cls) do
        local g = {}

        -- find tile orientation for current client and swap geometry if need
        local need_swap = (orientation == "east" and #cls <= 2) or (orientation == "south" and #cls > 2)
        local area = need_swap and swap(wa) or wa

        -- calculate geometry
        if #cls < (cols * rows) and row == cols - 1 then
            g.width = area.width / (rows - ((cols * rows) - #cls))
        else
            g.width = area.width / rows
        end

        g.height = area.height / cols
        g.x = area.x + col * g.width
        g.y = area.y + row * g.height

        -- turn back to real if geometry was swapped
        if need_swap then g = swap(g) end

        -- window size correction depending on useless gap and window border
        size_correction(c, g, useless_gap)

        -- set geometry
        c:geometry(g)

        -- update tile grid coordinates
        col = i % rows
        row = math.floor(i / rows)
    end
end

-- Layout constructor
local function construct_layout(name, direction)
    return {
        name = name,
        -- @p screen The screen number to tile
        arrange = function(p) return fair(p, direction) end
    }
end

-- Build layouts with different tile direction
uselessfair.vertical   = construct_layout("uselessfair", "south")
uselessfair.horizontal = construct_layout("uselessfairh", "east")

-- Module aliase
uselessfair.arrange = uselessfair.vertical.arrange
uselessfair.name = uselessfair.vertical.name

return uselessfair
