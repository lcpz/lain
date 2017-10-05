
--[[

     Licensed under GNU General Public License v2
      * (c) 2016,      Henrik Antonsson
      * (c) 2015,      Joerg Jaspert
      * (c) 2014,      projektile
      * (c) 2013,      Luke Bonham
      * (c) 2010-2012, Peter Hofmann

--]]
--
local naughty = require("naughty")      -- notification library

local function dp(words)
    naughty.notify({
        preset = naughty.config.presets.normal,
        title = "Debug Message",
        text = words,
        width = 400
    })
end

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
    local nbrFirstSlaves  = floor((#cls - 1) / 2)
    local nbrSecondSlaves = floor((#cls - 0) / 2)

    local slaveFirstDim, slaveSecondDim = 0, 0

    -- Calculate dimensions of the L and R slaves
    if nbrFirstSlaves  > 0 then
        slaveFirstDim  = floor(wa.height / nbrFirstSlaves)
    end
    if nbrSecondSlaves > 0 then
        slaveSecondDim = floor(wa.height / nbrSecondSlaves)
    end

    -- Calculate dimensions of Main
    g.height = math.max(wa.height, 1)
    g.width  = math.max(mainwid, 1)
    g.x = wa.x + slaveLwid
    g.y = wa.y
    p.geometries[c] = g

    -- Auxiliary windows.
    if #cls <= 1 then
        return
    end

    for i = 2,#cls do
        local c = cls[i]
        local g = {}

        -- Work out the row of the client
        local index = i - 1
        local rowIndex = 0

        -- Is it on the left or right?
        if index <= nbrSecondSlaves then
            rowIndex = index
        else
            rowIndex = index - nbrSecondSlaves
        end

        if index <= nbrSecondSlaves then
            -- right slave
            g.x = wa.x + slaveLwid + mainwid
            g.y = wa.y + (rowIndex-1) * slaveSecondDim

            g.width = slaveRwid

            -- if last slave in right row use remaining space for that slave
            if rowIndex == nbrSecondSlaves then
                g.height = wa.y + wa.height - g.y
            else
                g.height = slaveSecondDim
            end
        else
            -- left slave
            g.x = wa.x
            g.y = wa.y + (rowIndex-1) * slaveFirstDim

            g.width = slaveLwid

            -- if last slave in left row use remaining space for that slave
            if rowIndex == nbrFirstSlaves then
                g.height = wa.y + wa.height - g.y
            else
                g.height = slaveFirstDim
            end
        end

        g.width = math.max(g.width, 1)
        g.height = math.max(g.height, 1)

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
