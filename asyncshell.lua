
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Alexander Yakushev              
      * (c) 2014, Yauhen Kirylau
                                                  
--]]

-- Asynchronous io.popen for Awesome WM.
-- How to use...
-- ...asynchronously:
-- asyncshell.request('wscript -Kiev', function(f) wwidget.text = f:read("*l") end)
-- ...synchronously
-- widget:set_text(asyncshell.demand('wscript -Kiev', 5):read("*l") or "Error")

-- This is more cpu demanding, but makes things faster.

local awful = require('awful')

asyncshell               = {}
asyncshell.request_table = {}
asyncshell.id_counter    = 0

-- Returns next tag - unique identifier of the request
local function next_id()
   asyncshell.id_counter = (asyncshell.id_counter + 1) % 100000
   return asyncshell.id_counter
end

-- Sends an asynchronous request for an output of the shell command.
-- @param command Command to be executed and taken output from
-- @param callback Function to be called when the command finishes
-- @return Request ID
function asyncshell.request(command, callback)
  local id = next_id()
  asyncshell.request_table[id] = {
    callback = callback,
    table = {}}
  awful.util.spawn_with_shell(string.format(
    [[
  echo asyncshell.deliver\(\"%q\", \""$(%s | %s)"\"\) | awesome-client;
    ]],
    --"]]-- syntax highlighter fix
    id,
    command:gsub('"','\"'),
    [[tr '\\n' '\\\\n' | tr '"' '\\"']]
  ))
  return id
end

-- Calls the remembered callback function on the output of the shell
-- command.
-- @param id Request ID
-- @param str The output of the shell command to be delievered
function asyncshell.deliver(id, str)
  id = tonumber(id)
  if not asyncshell.request_table[id] then return end
  str = str:gsub('\\n','\n')
  asyncshell.request_table[id].callback(str)
  asyncshell.request_table[id] = nil
end

-- Sends a synchronous request for an output of the command. Waits for
-- the output, but if the given timeout expires returns nil.
-- @param command Command to be executed and taken output from
-- @param timeout Maximum amount of time to wait for the result
-- @return File handler on success, nil otherwise
function asyncshell.demand(command, timeout)
   local f = io.popen(string.format("timeout %s %s",
                                    timeout, command))
   local result = f:read("*line")
   return result
end

return asyncshell
