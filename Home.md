Welcome to the Lain wiki!

### Dependencies

Package | Requested by | Reason of choice
--- | --- | ---
alsa-utils | [alsa](https://github.com/copycat-killer/lain/wiki/alsa), [alsabar](https://github.com/copycat-killer/lain/wiki/alsabar) | /
curl | widgets accessing network resources | LuaSocket is not a core library. LuaSSL is out of date. 
imagemagick | album arts in [mpd](https://github.com/copycat-killer/lain/wiki/mpd) notifications | Cairo doesn't do high quality filtering.

### Installation

Simply clone this repository into your Awesome directory:

    git clone https://github.com/copycat-killer/lain.git ~/.config/awesome/lain

then include it in your `rc.lua`:

    local lain = require("lain")

### Submodules

- [Layouts](https://github.com/copycat-killer/lain/wiki/Layouts)
- [Widgets](https://github.com/copycat-killer/lain/wiki/Widgets)
- [Utilities](https://github.com/copycat-killer/lain/wiki/Utilities)