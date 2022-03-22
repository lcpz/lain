--[[

     Lain
     Layouts, widgets and utilities for Awesome WM

     Widgets section

     Licensed under GNU General Public License v2
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local wrequire     = require(tostring(...):match(".*lain") .. ".helpers").wrequire
local setmetatable = setmetatable

local widget = { _NAME = tostring(...):match(".*lain") .. ".widget" }

return setmetatable(widget, { __index = wrequire })
