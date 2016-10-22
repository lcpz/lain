package = "lain"
version = "git"
source = {
   url = "https://github.com/copycat-killer/lain",
   tag = "git"
}
description = {
   summary = "A layoutm widget and utilities library for the Awesome Window Manager",
   detailed = [[
        Successor of awesome-vain, this module provides new layouts, a set of widgets and utility functions, in order to improve Awesome usability and configurability.

        Optional dependencies: alsa-utils, curl, imagemagick
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
   modules = { lain = "init.lua" },
}
