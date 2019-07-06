local wibox = require("wibox")
local awful = require("awful")

local tasks_widget = wibox.widget.textbox()
tasks_widget:set_align("right")

function get_task_count(filter)
  local cap_fd = io.popen("task " .. filter .. " count")
  local count = cap_fd:read("*n")
  cap_fd:close()

  return count;
end

function get_current_task()
  local cap_fd = io.popen("cat ~/.current_task")
  local task_name = cap_fd:read("*l")
  cap_fd:close()

  return task_name;
end

function update_task_count(widget)
  local gh_count = get_task_count("status:pending +gh");
  local other_count = get_task_count("status:pending -gh");
  local current_task = get_current_task();

  local tasks_count_html = "";
  local current_task_count_html = "";

  if(current_task ~= nil and current_task ~= "") then
    local current_task_count = get_task_count("status:pending project:" .. current_task);
    if(current_task_count ~= nil) then
     current_task_count_html = "| <span color='orange'>" 
      .. current_task
      .. ": "
      .. current_task_count
      .. "</span> ";
    end
  end

  tasks_count_html = current_task_count_html 
    .. "| <span color='orange'>GH: " .. gh_count .. "</span> "
    .. "| <span color='orange'>TW: " .. other_count .. "</span> ";


  widget:set_markup(tasks_count_html);
end

update_task_count(tasks_widget);

local mytimer = timer({ timeout = 1 });
mytimer:connect_signal("timeout", function () update_task_count(tasks_widget) end);
mytimer:start();

return tasks_widget;
