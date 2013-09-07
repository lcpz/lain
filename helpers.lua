
--[[
                                                      
     Licensed under GNU General Public License v2     
      * (c) 2013,      Luke Bonham                    
      * (c) 2010-2012, Peter Hofmann                  
      * (c) 2010,      Adrian C. <anrxc@sysphere.org> 
                                                      
--]]

local awful  = require("awful")
local debug  = require("debug")
local pairs  = pairs
local rawget = rawget

-- Lain helper functions for internal use
-- lain.helpers
local helpers = {}

helpers.lain_dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
helpers.icons_dir   = helpers.lain_dir .. 'icons/'
helpers.scripts_dir = helpers.lain_dir .. 'scripts/'

-- {{{ Modules loader

function helpers.wrequire(table, key)
    local module = rawget(table, key)
    return module or require(table._NAME .. '.' .. key)
end

-- }}}

-- {{{
-- If lain.terminal is a string, e.g. "xterm", then "xterm -e " .. cmd is
-- run. But if lain.terminal is a function, then terminal(cmd) is run.

function helpers.run_in_terminal(cmd)
    if type(terminal) == "function"
    then
        terminal(cmd)
    elseif type(terminal) == "string"
    then
        awful.util.spawn(terminal .. ' -e ' .. cmd)
    end
end

-- }}}

-- {{{ Format units to one decimal point

function helpers.uformat(array, key, value, unit)
    for u, v in pairs(unit) do
        array["{"..key.."_"..u.."}"] = string.format("%.1f", value/v)
    end
    return array
end

-- }}}

-- {{{ Read the first line of a file or return nil.

function helpers.first_line(f)
    local fp = io.open(f)
    if not fp
    then
        return nil
    end

    local content = fp:read("*l")
    fp:close()
    return content
end

-- }}}

-- {{{ A map utility

helpers.map_table = {}

function helpers.set_map(element, value)
    helpers.map_table[element] = value
end

function helpers.get_map(element)
    return helpers.map_table[element]
end

-- }}}

return helpers
