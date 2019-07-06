local awful = require("awful")
local naughty = require("naughty")
local gfs = require("gears.filesystem")
local home = os.getenv("HOME")


function get_window_cwd()
  path = '';

  if(client.focus and client.focus.name) then
    path = client.focus.name;

    path = path and path:gsub("^~", home)
    -- check if is path and is readable
    if(gfs.dir_readable(path)) then

        -- naughty.notify({ preset = naughty.config.presets.critical,
        -- title = "path",
        -- text = path })
      return path
    -- Otherwise, remove the filename, and check the dir.
    else
      path = path:match("(.*)/.*")
      if(gfs.dir_readable(path)) then
        -- naughty.notify({ preset = naughty.config.presets.critical,
        -- title = "cwd",
        -- text = path })
        return path
      end
    end
  end

  return path;
end

return get_window_cwd;

