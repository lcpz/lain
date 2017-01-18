
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014,      projektile                 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local tag      = require("awful.tag")
local tonumber = tonumber

local cascade = {
    name     = "cascade",
    nmaster  = 0,
    offset_x = 32,
    offset_y = 8,
    tile     = {
        name          = "cascadetile",
        nmaster       = 0,
        ncol          = 0,
        mwfact        = 0,
        offset_x      = 5,
        offset_y      = 32,
        extra_padding = 0
    }
}

local function do_cascade(p, tiling)
    -- Screen.
    local wa  = p.workarea
    local cls = p.clients

    if #cls <= 0 then return end

    -- Useless gaps.
    local useless_gap = p.useless_gap or 0

    if not tiling then
        -- Cascade windows.

        local num_c
        if cascade.nmaster > 0 then
            num_c = cascade.nmaster
        else
            num_c = tag.master_count
        end

        -- Opening a new window will usually force all existing windows to
        -- get resized. This wastes a lot of CPU time. So let's set a lower
        -- bound to "how_many": This wastes a little screen space but you'll
        -- get a much better user experience.
        local how_many = (#cls >= num_c and #cls) or num_c

        local current_offset_x = cascade.offset_x * (how_many - 1)
        local current_offset_y = cascade.offset_y * (how_many - 1)

        -- Iterate.
        for i = 1,#cls,1 do
            local c = cls[i]
            local g = {}

            g.x      = wa.x + (how_many - i) * cascade.offset_x
            g.y      = wa.y + (i - 1) * cascade.offset_y
            g.width  = wa.width - current_offset_x - 2*c.border_width
            g.height = wa.height - current_offset_y - 2*c.border_width

            if g.width  < 1 then g.width  = 1 end
            if g.height < 1 then g.height = 1 end

            c:geometry(g)
        end
    else
        -- Layout with one fixed column meant for a master window. Its
        -- width is calculated according to mwfact. Other clients are
        -- cascaded or "tabbed" in a slave column on the right.

        --         (1)                 (2)                 (3)                 (4)
        --   +----------+---+    +----------+---+    +----------+---+    +----------+---+
        --   |          |   |    |          | 3 |    |          | 4 |    |         +---+|
        --   |          |   | -> |          |   | -> |         +---++ -> |        +---+|+
        --   |  1       | 2 |    |  1      +---++    |  1      | 3 ||    |  1    +---+|+|
        --   |          |   |    |         | 2 ||    |        +---++|    |      +---+|+ |
        --   |          |   |    |         |   ||    |        | 2 | |    |      | 2 |+  |
        --   +----------+---+    +---------+---++    +--------+---+-+    +------+---+---+

        local mwfact
        if cascade.tile.mwfact > 0 then
            mwfact = cascade.tile.mwfact
        else
            mwfact = tag.getmwfact(t)
        end

        -- Make slave windows overlap main window? Do this if ncol is 1.
        local overlap_main
        if cascade.tile.ncol > 0 then
            overlap_main = cascade.tile.ncol
        else
            overlap_main = tag.column_count
        end

        -- Minimum space for slave windows? See cascade.tile.lua.
        local num_c
        if cascade.tile.nmaster > 0 then
            num_c = cascade.tile.nmaster
        else
            num_c = tag.master_count
        end

        local how_many = (#cls - 1 >= num_c and (#cls - 1)) or num_c

        local current_offset_x = cascade.tile.offset_x * (how_many - 1)
        local current_offset_y = cascade.tile.offset_y * (how_many - 1)

        if #cls <= 0 then return end

        -- Main column, fixed width and height.
        local c = cls[1]
        local g = {}
        -- Subtracting the useless_gap width from the work area width here
        -- makes this mwfact calculation work the same as in uselesstile.
        -- Rounding is necessary to prevent the rendered size of slavewid
        -- from being 1 pixel off when the result is not an integer.
        local mainwid = math.floor((wa.width - useless_gap) * mwfact)
        local slavewid = wa.width - mainwid

        if overlap_main == 1 then
            g.width = wa.width - 2*c.border_width

            -- The size of the main window may be reduced a little bit.
            -- This allows you to see if there are any windows below the
            -- main window.
            -- This only makes sense, though, if the main window is
            -- overlapping everything else.
            g.width = g.width - cascade.tile.extra_padding
        else
            g.width = mainwid - 2*c.border_width
        end

        g.height = wa.height - 2*c.border_width
        g.x = wa.x
        g.y = wa.y
        if useless_gap > 0 then
            -- Reduce width once and move window to the right.
            -- Reduce height twice, however.
            g.width = g.width - useless_gap
            g.height = g.height - 2 * useless_gap
            g.x = g.x + useless_gap
            g.y = g.y + useless_gap

            -- When there's no window to the right, add an additional gap.
            if overlap_main == 1 then g.width = g.width - useless_gap end
        end
        if g.width < 1 then g.width = 1 end
        if g.height < 1 then g.height = 1 end
        c:geometry(g)

        -- Remaining clients stacked in slave column, new ones on top.
        if #cls > 1 then
            for i = 2,#cls do
                c = cls[i]
                g = {}
                g.width = slavewid - current_offset_x - 2*c.border_width
                g.height = wa.height - current_offset_y - 2*c.border_width
                g.x = wa.x + mainwid + (how_many - (i - 1)) * cascade.tile.offset_x
                g.y = wa.y + (i - 2) * cascade.tile.offset_y

                if useless_gap > 0 then
                    g.width = g.width - 2 * useless_gap
                    g.height = g.height - 2 * useless_gap
                    g.x = g.x + useless_gap
                    g.y = g.y + useless_gap
                end

                if g.width < 1 then g.width = 1 end
                if g.height < 1 then g.height = 1 end

                c:geometry(g)
            end
        end
    end
end

function cascade.tile.arrange(p)
    return do_cascade(p, true)
end

function cascade.arrange(p)
    return do_cascade(p, false)
end

return cascade
