local wibox = require("wibox")
local awful = require("awful")

local pomodoro = {};

pomodoro.break_time = 5 * 60;
pomodoro.work_time  = 25 * 60;
pomodoro.timer = timer({ timeout = 1 })
pomodoro.status = "Stopped";
pomodoro.statuses = {};
pomodoro.statuses.working = "Working";
pomodoro.statuses.stopped = "Stopped";
pomodoro.statuses.onbreak  = "Break"; 
pomodoro.count = 0;

function init()
  pomodoro.widget = wibox.widget.textbox()
  pomodoro.widget:set_align("left")

  pomodoro.started = false;
end

function pomodoro:start()
  pomodoro.start_time = os.time();
  pomodoro.status = pomodoro.statuses.working;
  pomodoro.timer:again();
end

function pomodoro:start_break()
  pomodoro.start_time = os.time();
  pomodoro.status = pomodoro.statuses.onbreak;
end

function pomodoro:stop()
  if(pomodoro.status == pomodoro.statuses.stopped) then
    pomodoro.count = 0;
  end
  pomodoro.status = pomodoro.statuses.stopped;
  pomodoro.timer:stop();
  update_time(pomodoro);
end

function update_time(pomodoro)
  if(pomodoro.status == pomodoro.statuses.stopped) then
    pomodoro.widget:set_markup("<span color='orange'>Pomodoro: " .. pomodoro.status  .. " | " .. pomodoro.count .. "</span> ");
  else
    local now = os.time();
    local time_add = 0;
    local time_left = 0;
    local time_add = 0;

    if(pomodoro.status == pomodoro.statuses.working) then
      time_add = pomodoro.work_time;
    end

    if(pomodoro.status == pomodoro.statuses.onbreak) then
      time_add = pomodoro.break_time;
    end

    time_left = (pomodoro.start_time + time_add) - now;

    if(time_left <= 0) then
      if(pomodoro.status == pomodoro.statuses.working) then
        pomodoro:start_break();
      else
        pomodoro:start();
        pomodoro.count = pomodoro.count + 1;
      end
    end

    if(pomodoro.status == pomodoro.statuses.working) then
      pomodoro.widget:set_markup("<span color='orange'>Pomodoro: " .. os.date("%M:%S", time_left) .. " | " .. pomodoro.count .. "</span> ");
    else
      pomodoro.widget:set_markup("<span color='yellow'>Pomodoro: " .. os.date("%M:%S", time_left) .. " | " .. pomodoro.count .. "</span> ");
    end
  end
end

function on_mouse_click()
  naughty.notify({ preset = naughty.config.presets.critical,
  title = "click",
  text = 'ya clicked' })
end

init();
update_time(pomodoro);

pomodoro.timer:connect_signal("timeout", function () update_time(pomodoro) end);
pomodoro.widget:connect_signal("button::press", on_mouse_click);

return pomodoro;
