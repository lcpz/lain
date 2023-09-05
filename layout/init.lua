--[[

     Lain
     Layouts, widgets and utilities for Awesome WM

     Layouts section

     Licensed under GNU General Public License v2
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local requirePrefix = tostring(...):match(".*lain") or ""
if requirePrefix then
	requirePrefix = requirePrefix .. "."
end

local wrequire     = require(requirePrefix .. "helpers").wrequire
local setmetatable = setmetatable

local layout       = { _NAME = requirePrefix .. "layout" }

return setmetatable(layout, { __index = wrequire })
