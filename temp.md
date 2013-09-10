[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Show the current core temperature in a textbox.

Reads from `/sys/class/thermal`, so value is expressed in Celsius.

	mytemp = lain.widgets.temp()

The function takes a table as optional argument, which can contain:

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 5
`settings` | User settings | function | empty function

`settings` can use the string `coretemp_now`, which means current core temperature, expressed in Celsius (linux standard).