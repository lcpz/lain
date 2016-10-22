package = "lain"
version = "1.0.0"
source = {
   url = "https://github.com/copycat-killer/lain",
   tag = "v.1.0.0"
}
description = {
   summary = "A layoutm widget and utilities library for the Awesome Window Manager",
   detailed = [[
        Successor of awesome-vain, this module provides new layouts, a set of widgets and utility functions, in order to improve Awesome usability and configurability.
    ]],
   homepage = "https://github.com/copycat-killer/lain",
   license = "GPL v2"
}
dependencies = {
   "lua >= 5.1"
}
supported_platforms = { "linux" }
build = {
   type = "builtin",
   modules = { lain = "init.lua" },
}
