
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016,      Henrik Antonsson           
      * (c) 2015,      Joerg Jaspert              
      * (c) 2014,      projektile                 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local tonumber = tonumber
local math     = { floor = math.floor }
local scr      = require("awful.screen")

local centerwork = {
    name         = "centerwork",
    horizontal   = { name = "centerworkh" }
}

local function do_centerwork(p, orientation)
    -- Screen.
    local wa  = p.workarea
    local cls = p.clients
    local ta = scr.focused().selected_tag

    if not ta then return end

    if #cls <= 0 then return end

    -- Useless gaps.
    local useless_gap = p.useless_gap or 0

    local c = cls[1]
    local g = {}

    -- Main column, fixed width and height.
    local mwfact          = ta.master_width_factor
    local mainhei         = math.floor(wa.height * mwfact)
    local mainwid         = math.floor(wa.width * mwfact)
    local slavewid        = wa.width - mainwid
    local slaveLwid       = math.floor(slavewid / 2)
    local slaveRwid       = slavewid - slaveLwid
    local slavehei        = wa.height - mainhei
    local slaveThei       = math.floor(slavehei / 2)
    local slaveBhei       = slavehei - slaveThei
    local nbrFirstSlaves  = math.floor(#cls / 2)
    local nbrSecondSlaves = math.floor((#cls - 1) / 2)

    local slaveFirstDim, slaveSecondDim = 0, 0

    if orientation == "vertical" then
        if nbrFirstSlaves  > 0 then slaveFirstDim  = math.floor(wa.height / nbrFirstSlaves) end
        if nbrSecondSlaves > 0 then slaveSecondDim = math.floor(wa.height / nbrSecondSlaves) end

        g.height = wa.height - 2*useless_gap - 2*c.border_width
        g.width  = mainwid - 2*c.border_width

        g.x = wa.x + slaveLwid
        g.y = wa.y + useless_gap
    else
        if nbrFirstSlaves  > 0 then slaveFirstDim  = math.floor(wa.width / nbrFirstSlaves) end
        if nbrSecondSlaves > 0 then slaveSecondDim = math.floor(wa.width / nbrSecondSlaves) end

        g.height  = mainhei - 2*c.border_width
        g.width = wa.width - 2*useless_gap - 2*c.border_width

        g.x = wa.x + useless_gap
        g.y = wa.y + slaveThei
    end

    if g.width  < 1 then g.width  = 1 end
    if g.height < 1 then g.height = 1 end

    c:geometry(g)

    -- Auxiliary windows.
    if #cls <= 1 then return end
    for i = 2,#cls do
        local c = cls[i]
        local g = {}

        local rowIndex = math.floor(i/2)

        if orientation == "vertical" then
            if i % 2 == 0 then
                -- left slave
                g.x = wa.x + useless_gap
                g.y = wa.y + useless_gap + (rowIndex-1)*slaveFirstDim

                g.width = slaveLwid - 2*useless_gap - 2*c.border_width

                -- if last slave in left row use remaining space for that slave
                if rowIndex == nbrFirstSlaves then
                    g.height = wa.y + wa.height - g.y - useless_gap - 2*c.border_width
                else
                    g.height = slaveFirstDim - useless_gap - 2*c.border_width
                end
            else
                -- right slave
                g.x = wa.x + slaveLwid + mainwid + useless_gap
                g.y = wa.y + useless_gap + (rowIndex-1)*slaveSecondDim

                g.width = slaveRwid - 2*useless_gap - 2*c.border_width

                -- if last slave in right row use remaining space for that slave
                if rowIndex == nbrSecondSlaves then
                    g.height = wa.y + wa.height - g.y - useless_gap - 2*c.border_width
                else
                    g.height = slaveSecondDim - useless_gap - 2*c.border_width
                end
            end
        else
            if i % 2 == 0 then
                -- top slave
                g.x = wa.x + useless_gap + (rowIndex-1)*slaveFirstDim
                g.y = wa.y + useless_gap

                g.height = slaveThei - 2*useless_gap - 2*c.border_width

                -- if last slave in top row use remaining space for that slave
                if rowIndex == nbrFirstSlaves then
                    g.width = wa.x + wa.width - g.x - useless_gap - 2*c.border_width
                else
                    g.width = slaveFirstDim - useless_gap - 2*c.border_width
                end
            else
                -- bottom slave
                g.x = wa.x + useless_gap + (rowIndex-1)*slaveFirstDim
                g.y = wa.y + slaveThei + mainhei + useless_gap

                g.height = slaveBhei - 2*useless_gap - 2*c.border_width

                -- if last slave in bottom row use remaining space for that slave
                if rowIndex == nbrSecondSlaves then
                    g.width = wa.x + wa.width - g.x - useless_gap - 2*c.border_width
                else
                    g.width = slaveSecondDim - useless_gap - 2*c.border_width
                end

            end
        end

        if g.width  < 1 then g.width  = 1 end
        if g.height < 1 then g.height = 1 end

        c:geometry(g)
    end
end


function centerwork.horizontal.arrange(p)
    return do_centerwork(p, "horizontal")
end

function centerwork.arrange(p)
    return do_centerwork(p, "vertical")
end

return centerwork
