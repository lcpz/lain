-[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Aaron Lebo                     
                                                  
--]]

local newtimer = require("lain.helpers").newtimer
local wibox = require("wibox")
local json = require("dkjson")

-- acw (awesome crypto widget)
-- diplays BTC/USD and DOGE/USD using Coinbase and Cryptsy APIs
-- requires http://dkolf.de/src/dkjson-lua.fsl/home   
-- based upon http://awesome.naquadah.org/wiki/Bitcoin_Price_Widget
-- lain.widgets.contrib.acw

acw = {widget=wibox.widget.textbox('')}

local function get(url)
    f = io.popen('curl -m 5 -s "' .. url .. '"')
    if (not f) then return 0 end
    return f:read("*all")
end

local function parse(j)
    local obj, pos, err = json.decode (j, 1, nil)
    if err thenfunction worker(args)
        return nil
    else
        return obj
    end
end

function worker(args)
    local args = args or {}
    local timeout = args.timeout or 600
    local settings = args.settings or function() end

    local function update()
        btc = parse(get("https://coinbase.com/api/v1/prices/buy"))
        if btc then
            btc = tonumber(btc["subtotal"]["amount"])
            btc_display = "$" .. btc
        else
            btc_display = "N/A"
        end
        doge = parse(get("http://pubapi.cryptsy.com/api.php?method=singlemarketdata&marketid=132"))
        if doge and btc then
            doge = tonumber(doge["return"]["markets"]["DOGE"]["lasttradeprice"])
            doge_display = string.format("$%.4f", btc * doge)
        else
            doge_display = "N/A"
        end
        prices = btc_display .. " " ..  doge_display
        prices_now = {}
        prices_now.prices = prices

        widget = acw.widget
        settings()
   end

    newtimer("acw", timeout, update)

    return acw.widget
end

return setmetatable(acw, { __call = function(_, ...) return worker(...) end })
