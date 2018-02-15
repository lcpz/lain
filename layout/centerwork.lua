--[[

     Licensed under GNU General Public License v2
      * (c) 2016,      Henrik Antonsson
      * (c) 2015,      Joerg Jaspert
      * (c) 2014,      projektile
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local floor, max, screen = math.floor, math.max, screen

local centerwork = {
    name       = "centerwork",
    horizontal = { name = "centerworkh" }
}

local function arrange(p, layout)
    local t   = p.tag or screen[p.screen].selected_tag
    local wa  = p.workarea
    local cls = p.clients

    if #cls == 0 then return end

    local c, g = cls[1], {}

    -- Main column, fixed width and height
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

    if layout.name == "centerwork" then -- vertical
        if nbrFirstSlaves  > 0 then slaveFirstDim  = floor(wa.height / nbrFirstSlaves) end
        if nbrSecondSlaves > 0 then slaveSecondDim = floor(wa.height / nbrSecondSlaves) end

        g.height = wa.height
        g.width  = mainwid

        g.x = wa.x + slaveLwid
        g.y = wa.y
    else -- horizontal
        if nbrFirstSlaves  > 0 then slaveFirstDim  = floor(wa.width / nbrFirstSlaves) end
        if nbrSecondSlaves > 0 then slaveSecondDim = floor(wa.width / nbrSecondSlaves) end

        g.height  = mainhei
        g.width = wa.width

        g.x = wa.x
        g.y = wa.y + slaveThei
    end

    g.width  = max(g.width, 1)
    g.height = max(g.height, 1)

    p.geometries[c] = g

    -- Auxiliary clients
    if #cls <= 1 then return end
    for i = 2, #cls do
        local c, g = cls[i], {}
        local idxChecker, dimToAssign

        local rowIndex = floor(i/2)

        if layout.name == "centerwork" then
            if i % 2 == 0 then -- left slave
                g.x     = wa.x
                g.y     = wa.y + (rowIndex - 1) * slaveFirstDim
                g.width = slaveLwid

                idxChecker, dimToAssign = nbrFirstSlaves, slaveFirstDim
            else -- right slave
                g.x     = wa.x + slaveLwid + mainwid
                g.y     = wa.y + (rowIndex - 1) * slaveSecondDim
                g.width = slaveRwid

                idxChecker, dimToAssign = nbrSecondSlaves, slaveSecondDim
            end

            -- if last slave in row, use remaining space for it
            if rowIndex == idxChecker then
                g.height = wa.y + wa.height - g.y
            else
                g.height = dimToAssign
            end
        else
            if i % 2 == 0 then -- top slave
                g.x      = wa.x + (rowIndex - 1) * slaveFirstDim
                g.y      = wa.y
                g.height = slaveThei

                idxChecker, dimToAssign = nbrFirstSlaves, slaveFirstDim
            else -- bottom slave
                g.x      = wa.x + (rowIndex - 1) * slaveSecondDim
                g.y      = wa.y + slaveThei + mainhei
                g.height = slaveBhei

                idxChecker, dimToAssign = nbrSecondSlaves, slaveSecondDim
            end

            -- if last slave in row, use remaining space for it
            if rowIndex == idxChecker then
                g.width = wa.x + wa.width - g.x
            else
                g.width = dimToAssign
            end
        end

        g.width  = max(g.width, 1)
        g.height = max(g.height, 1)

        p.geometries[c] = g
    end
end

function centerwork.arrange(p)
    return arrange(p, centerwork)
end

function centerwork.horizontal.arrange(p)
    return arrange(p, centerwork.horizontal)
end

return centerwork
