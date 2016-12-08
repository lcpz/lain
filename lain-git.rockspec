package = "lain"
version = "git"
source = {
   url = "https://github.com/copycat-killer/lain",
   tag = "git"
}
description = {
   summary = "Layout, widgets and utilities for Awesome WM",
   detailed = [[
        Successor of awesome-vain, this module provides new layouts, a set of widgets and utility functions, in order to improve Awesome usability and configurability.

        Optional dependencies: alsa-utils (for alsamixer); curl; imagemagick.
    ]],
   homepage = "https://github.com/copycat-killer/lain",
   license = "GPL v2"
}
dependencies = {
   "lua >= 5.1",
   "awesome >= 3.5",
   "alsa-utils",
   "curl",
   "imagemagick"
}
supported_platforms = { "linux" }
build = {
   type = "builtin",
   modules = { lain = "init.lua" }
}
