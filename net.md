[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Monitors network interfaces and shows current traffic in a textbox. 

    mynet = lain.widgets.net()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 2
`iface` | Network device | string | autodetected
`units` | Units | int | 1024 (kilobytes) 
`settings` | User settings | function | empty function

Possible other values for `units` are 1 (byte) or multiple of 1024: 1024^2 (mb), 1024^3 (gb), and so on.

`settings` can use the following `iface` strings:

- `net_now.carrier` ("0", "1");
- `net_now.state` ("up", "down");
- `net_now.sent` and `net_now.received` (numbers).

### output

A textbox.