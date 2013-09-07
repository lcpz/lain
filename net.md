Monitors network interfaces and shows current traffic in a textbox. 

    mynet = lain.widgets.net()

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`iface` | Network device | string | autodetected
`refresh_timeout` | Refresh timeout seconds | int | 2
`units` | Units | int | 1024 (kilobytes) 
`spr` | Separator text between download and upload values | string | " "
`header` | Text to show before value | string | `iface`
`header_color` | Header color | string | `beautiful.fg_normal` or "#FFFFFF"
`color_up` | Upload value color | string | `beautiful.fg_focus` or "#FFFFFF"
`color_down` | Download value color | string | `beautiful.fg_focus` or "#FFFFFF"
`app` | Net program to spawn on click | string | "sudo wifi-menu"

**Note**: `spr` can be a markup text.

Possible value for `units` are stored in table `lain.widgets.net.units`, which contains:

         ["b"] = 1,
         ["kb"] = 1024,
   ["mb"] = 1024^2,
   ["gb"] = 1024^3