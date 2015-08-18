
--[[
                                                  
     Licensed under GNU General Public License v2 
<<<<<<< HEAD
=======
      * (c) 2015, worron                          
>>>>>>> upstream/master
      * (c) 2013, Alexander Yakushev              
                                                  
--]]

-- Asynchronous io.popen for Awesome WM.
<<<<<<< HEAD
-- How to use...
-- ...asynchronously:
-- asyncshell.request('wscript -Kiev', function(f) wwidget.text = f:read("*l") end)
-- ...synchronously:
-- widget:set_text(asyncshell.demand('wscript -Kiev', 5):read("*l") or "Error")

local spawn = require('awful.util').spawn

asyncshell               = {}
asyncshell.request_table = {}
asyncshell.id_counter    = 0
asyncshell.folder        = "/tmp/asyncshell"
asyncshell.file_template = asyncshell.folder .. '/req'

-- Create a directory for asynchell response files
os.execute("mkdir -p " .. asyncshell.folder)

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
   local tmpfname = asyncshell.file_template .. id
   asyncshell.request_table[id] = { callback = callback }
   local req =
      string.format("sh -c '%s > %s; " ..
                    'echo "asyncshell.deliver(%s)" | ' ..
                    "awesome-client' 2> /dev/null",
                    string.gsub(command, "'", "'\\''"), tmpfname, id)
   spawn(req, false)
   return id
end

-- Calls the remembered callback function on the output of the shell
-- command.
-- @param id Request ID
-- @param output The output file of the shell command to be delievered
function asyncshell.deliver(id)
   if asyncshell.request_table[id] and
      asyncshell.request_table[id].callback then
      local output = io.open(asyncshell.file_template .. id, 'r')
      asyncshell.request_table[id].callback(output)
   end
end

-- Sends a synchronous request for an output of the command. Waits for
-- the output, but if the given timeout expires returns nil.
-- @param command Command to be executed and taken output from
-- @param timeout Maximum amount of time to wait for the result
-- @return File handler on success, nil otherwise
function asyncshell.demand(command, timeout)
   local id = next_id()
   local tmpfname = asyncshell.file_template .. id
   local f = io.popen(string.format("(%s > %s; echo asyncshell_done) & " ..
                                    "(sleep %s; echo asynchell_timeout)",
                                    command, tmpfname, timeout))
   local result = f:read("*line")
   if result == "asyncshell_done" then
      return io.open(tmpfname)
   end
=======
-- How to use:
-- asyncshell.request('wscript -Kiev', function(output) wwidget.text = output end)

-- Grab environment
local awful = require('awful')

-- Initialize tables for module
asyncshell = { request_table = {}, id_counter = 0 }

-- Request counter
local function next_id()
    asyncshell.id_counter = (asyncshell.id_counter + 1) % 10000
    return asyncshell.id_counter
end

-- Remove given request
function asyncshell.clear(id)
    if asyncshell.request_table[id] then
        if asyncshell.request_table[id].timer then
            asyncshell.request_table[id].timer:stop()
            asyncshell.request_table[id].timer = nil
        end
        asyncshell.request_table[id] = nil
    end
end

-- Sends an asynchronous request for an output of the shell command
-- @param command Command to be executed and taken output from
-- @param callback Function to be called when the command finishes
-- @param timeout Maximum amount of time to wait for the result (optional)
function asyncshell.request(command, callback, timeout)
    local id = next_id()
    asyncshell.request_table[id] = { callback = callback }

    local formatted_command = string.gsub(command, '"','\"')

    local req = string.format(
        "echo \"asyncshell.deliver(%s, [[\\\"$(%s)\\\"]])\" | awesome-client &",
        id, formatted_command
    )

    awful.util.spawn_with_shell(req)

    if timeout then
        asyncshell.request_table[id].timer = timer({ timeout = timeout })
        asyncshell.request_table[id].timer:connect_signal("timeout", function() asyncshell.clear(id) end)
        asyncshell.request_table[id].timer:start()
    end
end

-- Calls the remembered callback function on the output of the shell command
-- @param id Request ID
-- @param output Shell command output to be delievered
function asyncshell.deliver(id, output)
    local output = string.sub(output, 2, -2)
    if asyncshell.request_table[id] then
        asyncshell.request_table[id].callback(output)
        asyncshell.clear(id)
    end
>>>>>>> upstream/master
end

return asyncshell
