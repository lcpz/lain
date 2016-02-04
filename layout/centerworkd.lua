
--[[

     Licensed under GNU General Public License v2
      * (c) 2016,      Henrik Antonsson
      * (c) 2014,      projektile
      * (c) 2013,      Luke Bonham
      * (c) 2010-2012, Peter Hofmann

     Based on centerwork.lua
--]]

local awful     = require("awful")
local beautiful = require("beautiful")
local tonumber  = tonumber
local math      = { floor = math.floor }

local centerworkd =
{
    name         = "centerworkd",
}

function centerworkd.arrange(p)
    -- A useless gap (like the dwm patch) can be defined with
    -- beautiful.useless_gap_width .
    local useless_gap = tonumber(beautiful.useless_gap_width) or 0

    -- A global border can be defined with
    -- beautiful.global_border_width
    local global_border = tonumber(beautiful.global_border_width) or 0
    if global_border < 0 then global_border = 0 end

    -- Screen.
    local wa = p.workarea
    local cls = p.clients

    -- Borders are factored in.
    wa.height = wa.height - (global_border * 2)
    wa.width = wa.width - (global_border * 2)
    wa.x = wa.x + global_border
    wa.y = wa.y + global_border

    -- Width of main column?
    local t = awful.tag.selected(p.screen)
    local mwfact = awful.tag.getmwfact(t)

    if #cls > 0
    then
        -- Main column, fixed width and height.
        local c = cls[1]
        local g = {}
        local mainwid = math.floor(wa.width * mwfact)
        local slavewid = wa.width - mainwid
        local slaveLwid = math.floor(slavewid / 2)
        local slaveRwid = slavewid - slaveLwid
        local nbrLeftSlaves = math.floor(#cls / 2)
        local nbrRightSlaves = math.floor((#cls - 1) / 2)

        local slaveLeftHeight = 0
        if nbrLeftSlaves > 0 then slaveLeftHeight = math.floor(wa.height / nbrLeftSlaves) end
        if nbrRightSlaves > 0 then slaveRightHeight = math.floor(wa.height / nbrRightSlaves) end

        g.height = wa.height - 2*useless_gap - 2*c.border_width
        g.width = mainwid - 2*c.border_width
        g.x = wa.x + slaveLwid
        g.y = wa.y + useless_gap

        if g.width < 1 then g.width = 1 end
        if g.height < 1 then g.height = 1 end
        c:geometry(g)

        -- Auxiliary windows.
        if #cls > 1
        then
            for i = 2,#cls
            do
                c = cls[i]
                g = {}

                local rowIndex = math.floor(i/2)

                -- If i is even it should be placed on the left side
                if i % 2 == 0
                then
                    -- left slave
                    g.x = wa.x + useless_gap
                    g.y = wa.y + useless_gap + (rowIndex-1)*slaveLeftHeight

                    g.width = slaveLwid - 2*useless_gap - 2*c.border_width

                    -- if last slave in left row use remaining space for that slave
                    if rowIndex == nbrLeftSlaves
                    then
                        g.height = wa.y + wa.height - g.y - useless_gap - 2*c.border_width
                    else
                        g.height = slaveLeftHeight - useless_gap - 2*c.border_width
                    end
                else
                    -- right slave
                    g.x = wa.x + slaveLwid + mainwid + useless_gap
                    g.y = wa.y + useless_gap + (rowIndex-1)*slaveRightHeight

                    g.width = slaveRwid - 2*useless_gap - 2*c.border_width

                    -- if last slave in right row use remaining space for that slave
                    if rowIndex == nbrRightSlaves
                    then
                        g.height = wa.y + wa.height - g.y - useless_gap - 2*c.border_width
                    else
                        g.height = slaveRightHeight - useless_gap - 2*c.border_width
                    end

                end

                if g.width < 1 then g.width = 1 end
                if g.height < 1 then g.height = 1 end
                c:geometry(g)
            end
        end
    end
end

return centerworkd
