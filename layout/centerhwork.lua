
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

    -- Themes border width requires an offset
    local bw = tonumber(beautiful.border_width) or 0

    -- Screen.
    local wa = p.workarea
    local cls = p.clients

    -- Borders are factored in.
    wa.height = wa.height - ((global_border * 2) + (bw * 2))
    wa.width = wa.width - ((global_border * 2) + (bw * 2))

    -- Width of main column?
    local t = awful.tag.selected(p.screen)
    local mwfact = awful.tag.getmwfact(t)

    if #cls > 0
    then
        -- Main column, fixed width and height.
        local c = cls[#cls]
        local g = {}
        local mainwid  = wa.width
        local mainhei  = math.floor(wa.height * mwfact)
        local slavewid = math.floor(wa.width / 2 )
        local slavehei = math.floor((wa.height - mainhei) / 2)

        g.height = mainhei - 2 * useless_gap
        g.width  = wa.width
        g.x = wa.x + useless_gap + global_border
        g.y = wa.y + slavehei + global_border

        c:geometry(g)

        -- Auxiliary windows.
        if #cls > 1
        then
            local at = 0
            for i = (#cls - 1),1,-1
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
                g.width  = slavewid - 2 * useless_gap
                g.height = slavehei - 2 * useless_gap

                if at == centerhwork.top_left
                then
                    -- top left
                    g.x = wa.x + useless_gap + global_border
                    g.y = wa.y + useless_gap + global_border
                elseif at == centerhwork.top_right
                then
                    -- top right
                    g.x = wa.x + slavewid + 2 * useless_gap + global_border
                    g.y = wa.y + useless_gap + global_border
                elseif at == centerhwork.bottom_left
                then
                    -- bottom left
                    g.x = wa.x + useless_gap + global_border
                    g.y = wa.y + mainhei + slavehei + useless_gap + global_border
                elseif at == centerhwork.bottom_right
                then
                    -- bottom right
                    g.x = wa.x + slavewid + 2 * useless_gap + global_border
                    g.y = wa.y + mainhei + slavehei + useless_gap + global_border
                end

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
