package = "lain"
version = "scm-1"
source = {
   url = "git+https://github.com/lcpz/lain.git",
   tag = "master"
}
description = {
   summary = "Layout, widgets and utilities for Awesome WM",
   detailed = "Alternative layouts, asynchronous widgets and utility functions for Awesome WM. Non-Lua dependency: curl (for IMAP, MPD and weather widgets).",
   homepage = "https://github.com/lcpz/lain",
   license = "GPL2"
}
dependencies = {
   "lua >= 5.3",
   "dkjson >= 2.6-1"
}
supported_platforms = { "linux" }
build = {
   type = "builtin",
   modules = { lain = "init.lua" }
}

