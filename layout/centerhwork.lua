
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2015,      Joerg Jaspert              
      * (c) 2014,      projektile                 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local awful     = require("awful")
local beautiful = require("beautiful")
local tonumber  = tonumber

local centerhwork =
{
    name         = "centerhwork",
    top_left     = 0,
    top_right    = 1,
    bottom_left  = 2,
    bottom_right = 3
}

function centerhwork.arrange(p)
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
        local mainhei  = math.floor(wa.height * mwfact)
        local slaveLwid = math.floor(wa.width / 2 )
        local slaveRwid = wa.width - slaveLwid
        local slavehei = wa.height - mainhei
        local slaveThei = math.floor(slavehei / 2)
        local slaveBhei = slavehei - slaveThei
        local Lhalfgap = math.floor(useless_gap / 2)
        local Rhalfgap = useless_gap - Lhalfgap

        g.height = mainhei - 2*c.border_width
        g.width  = wa.width - 2*useless_gap - 2*c.border_width
        g.x = wa.x + useless_gap
        g.y = wa.y + slaveThei

        if g.width < 1 then g.width = 1 end
        if g.height < 1 then g.height = 1 end
        c:geometry(g)

        -- Auxiliary windows.
        if #cls > 1
        then
            local at = 0
            for i = 2,#cls
            do
                -- It's all fixed. If there are more than 5 clients,
                -- those additional clients will float. This is
                -- intentional.
                if at == 4
                then
                    break
                end

                c = cls[i]
                g = {}

                if i - 2 == centerhwork.top_left
                then
                    -- top left
                    g.x = wa.x + useless_gap
                    g.y = wa.y + useless_gap
                    g.width = slaveLwid - useless_gap - Lhalfgap - 2*c.border_width
                    g.height = slaveThei - 2*useless_gap - 2*c.border_width
                elseif i - 2 == centerhwork.top_right
                then
                    -- top right
                    g.x = wa.x + slaveLwid + Rhalfgap
                    g.y = wa.y + useless_gap
                    g.width = slaveRwid - useless_gap - Rhalfgap - 2*c.border_width
                    g.height = slaveThei - 2*useless_gap - 2*c.border_width
                elseif i - 2 == centerhwork.bottom_left
                then
                    -- bottom left
                    g.x = wa.x + useless_gap
                    g.y = wa.y + mainhei + slaveThei + useless_gap
                    g.width = slaveLwid - useless_gap - Lhalfgap - 2*c.border_width
                    g.height = slaveBhei - 2*useless_gap - 2*c.border_width
                elseif i - 2 == centerhwork.bottom_right
                then
                    -- bottom right
                    g.x = wa.x + slaveLwid + Rhalfgap
                    g.y = wa.y + mainhei + slaveThei + useless_gap
                    g.width = slaveRwid - useless_gap - Rhalfgap - 2*c.border_width
                    g.height = slaveBhei - 2*useless_gap - 2*c.border_width
                end

                if g.width < 1 then g.width = 1 end
                if g.height < 1 then g.height = 1 end
                c:geometry(g)

                at = at + 1
            end

            -- Set remaining clients to floating.
            for i = (#cls - 1 - 4),1,-1
            do
                c = cls[i]
                awful.client.floating.set(c, true)
            end
        end
    end
end

return centerhwork
