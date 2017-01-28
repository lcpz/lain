
--[[
                                 
     Licensed under MIT License  
      * (c) 2013, Luke Bonham    
      * (c) 2009, Uli Schlachter 
      * (c) 2009, Majic          
                                 
--]]

local string       = { format = string.format }
local setmetatable = setmetatable

-- Lain markup util submodule
-- lain.util.markup
local markup = { fg = {}, bg = {} }

-- Convenience tags.
function markup.bold(text)      return '<b>'     .. text .. '</b>'     end
function markup.italic(text)    return '<i>'     .. text .. '</i>'     end
function markup.strike(text)    return '<s>'     .. text .. '</s>'     end
function markup.underline(text) return '<u>'     .. text .. '</u>'     end
function markup.monospace(text) return '<tt>'    .. text .. '</tt>'    end
function markup.big(text)       return '<big>'   .. text .. '</big>'   end
function markup.small(text)     return '<small>' .. text .. '</small>' end

-- Set the font.
function markup.font(font, text)
  return '<span font="'  .. font  .. '">' .. text ..'</span>'
end

-- Set the foreground.
function markup.fg.color(color, text)
  return '<span foreground="' .. color .. '">' .. text .. '</span>'
end

-- Set the background.
function markup.bg.color(color, text)
  return '<span background="' .. color .. '">' .. text .. '</span>'
end

-- Set foreground and background.
function markup.color(fg, bg, text)
  return string.format('<span foreground="%s" background="%s">%s</span>', fg, bg, text)
end

-- Set font and foreground.
function markup.fontfg(font, fg, text)
  return string.format('<span font="%s" foreground="%s">%s</span>', font, fg, text)
end

-- Set font and background.
function markup.fontbg(font, bg, text)
  return string.format('<span font="%s" background="%s">%s</span>', font, bg, text)
end

-- Set font, foreground and background.
function markup.fontcolor(font, fg, bg, text)
  return string.format('<span font="%s" foreground="%s" background="%s">%s</span>', font, fg, bg, text)
end

-- link markup.{fg,bg}(...) calls to markup.{fg,bg}.color(...)
setmetatable(markup.fg, { __call = function(_, ...) return markup.fg.color(...) end })
setmetatable(markup.bg, { __call = function(_, ...) return markup.bg.color(...) end })

-- link markup(...) calls to markup.fg.color(...)
return setmetatable(markup, { __call = function(_, ...) return markup.fg.color(...) end })
