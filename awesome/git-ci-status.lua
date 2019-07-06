local wibox = require("wibox")
local awful = require("awful")
local getcwd = require("focused_window_cwd");
local naughty = require("naughty")

local status = {};
status.timer = timer({ timeout = 1 })
status.code = -1;
status.count = 1;

status.codes = {
  'Success',
  'Failure',
  'Pending',
  'Not Setup'
}

local status_command = "hub ci-status";

function init()
  status.widget = wibox.widget.textbox();
  status.widget:set_align("right");
  status.timer:again();
end

function status:set_status(status) 
  status.code = status;
end

-- 0 = success, 1 = error/failure, 2 = pending, 3 = no status
function update_from_command(out, err, reason, exit_code)
  if(err and string.len(err) > 0) then
    status.code = -1;
    return;
  end

  status.code = exit_code;
end

function check_if_git()
  path = getcwd();
  awful.spawn.easy_async_with_shell('cd ' .. path .. ' && ' ..status_command, update_from_command)
end


function update_status()
  check_if_git();

        -- naughty.notify({ preset = naughty.config.presets.critical,
        -- title = "cwd",
        -- text = 'checking' })

  if(status.code == -1 or status.code > 100) then
    status.widget:set_markup("");
    status.timer.timeout = 1;
  else
    status.widget:set_markup("<span color='orange'>CI: " .. status.codes[status.code + 1]  .. "</span> ");
    status.timer:stop()
    status.timer.timeout = 10;
    status.timer:again()
  end
end

init();
update_status();
status.timer:connect_signal("timeout", function () update_status() end);

return status;
