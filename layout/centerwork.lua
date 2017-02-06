
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016,      Henrik Antonsson           
      * (c) 2015,      Joerg Jaspert              
      * (c) 2014,      projektile                 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local floor  = math.floor
local screen = screen

local centerwork = {
    name         = "centerwork",
    horizontal   = { name = "centerworkh" }
}

local function do_centerwork(p, orientation)
    local t = p.tag or screen[p.screen].selected_tag
    local wa = p.workarea
    local cls = p.clients

    if #cls == 0 then return end

    local c = cls[1]
    local g = {}

    -- Main column, fixed width and height.
    local mwfact          = t.master_width_factor
    local mainhei         = floor(wa.height * mwfact)
    local mainwid         = floor(wa.width * mwfact)
    local slavewid        = wa.width - mainwid
    local slaveLwid       = floor(slavewid / 2)
    local slaveRwid       = slavewid - slaveLwid
    local slavehei        = wa.height - mainhei
    local slaveThei       = floor(slavehei / 2)
    local slaveBhei       = slavehei - slaveThei
    local nbrFirstSlaves  = floor(#cls / 2)
    local nbrSecondSlaves = floor((#cls - 1) / 2)

    local slaveFirstDim, slaveSecondDim = 0, 0

    if orientation == "vertical" then
        if nbrFirstSlaves  > 0 then slaveFirstDim  = floor(wa.height / nbrFirstSlaves) end
        if nbrSecondSlaves > 0 then slaveSecondDim = floor(wa.height / nbrSecondSlaves) end

        g.height = wa.height
        g.width  = mainwid

        g.x = wa.x + slaveLwid
        g.y = wa.y
    else
        if nbrFirstSlaves  > 0 then slaveFirstDim  = floor(wa.width / nbrFirstSlaves) end
        if nbrSecondSlaves > 0 then slaveSecondDim = floor(wa.width / nbrSecondSlaves) end

        g.height  = mainhei
        g.width = wa.width

        g.x = wa.x
        g.y = wa.y + slaveThei
    end

    if g.width  < 1 then g.width  = 1 end
    if g.height < 1 then g.height = 1 end

    p.geometries[c] = g

    -- Auxiliary windows.
    if #cls <= 1 then return end
    for i = 2,#cls do
        local c = cls[i]
        local g = {}

        local rowIndex = floor(i/2)

        if orientation == "vertical" then
            if i % 2 == 0 then
                -- left slave
                g.x = wa.x
                g.y = wa.y + (rowIndex-1)*slaveFirstDim

                g.width = slaveLwid

                -- if last slave in left row use remaining space for that slave
                if rowIndex == nbrFirstSlaves then
                    g.height = wa.y + wa.height - g.y
                else
                    g.height = slaveFirstDim
                end
            else
                -- right slave
                g.x = wa.x + slaveLwid + mainwid
                g.y = wa.y + (rowIndex-1)*slaveSecondDim

                g.width = slaveRwid

                -- if last slave in right row use remaining space for that slave
                if rowIndex == nbrSecondSlaves then
                    g.height = wa.y + wa.height - g.y
                else
                    g.height = slaveSecondDim
                end
            end
        else
            if i % 2 == 0 then
                -- top slave
                g.x = wa.x + (rowIndex-1)*slaveFirstDim
                g.y = wa.y

                g.height = slaveThei

                -- if last slave in top row use remaining space for that slave
                if rowIndex == nbrFirstSlaves then
                    g.width = wa.x + wa.width - g.x
                else
                    g.width = slaveFirstDim
                end
            else
                -- bottom slave
                g.x = wa.x + (rowIndex-1)*slaveSecondDim
                g.y = wa.y + slaveThei + mainhei

                g.height = slaveBhei

                -- if last slave in bottom row use remaining space for that slave
                if rowIndex == nbrSecondSlaves then
                    g.width = wa.x + wa.width - g.x
                else
                    g.width = slaveSecondDim
                end

            end
        end

        if g.width  < 1 then g.width  = 1 end
        if g.height < 1 then g.height = 1 end

        p.geometries[c] = g
    end
end


function centerwork.horizontal.arrange(p)
    return do_centerwork(p, "horizontal")
end

function centerwork.arrange(p)
    return do_centerwork(p, "vertical")
end

return centerwork
