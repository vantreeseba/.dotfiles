local wibox = require("wibox")
local awful = require("awful")

local battery_widget = wibox.widget.textbox()
battery_widget:set_align("right")

function update_battery(widget)
    local cap_fd = io.popen("cat /sys/class/power_supply/BAT0/capacity")
    local level = cap_fd:read("*n")
    cap_fd:close()

    local status_fd = io.popen("cat /sys/class/power_supply/BAT0/status")
    local status = status_fd:read("*all")
    status_fd:close()


    if string.find(status, "Discharging", 1, true) then
        if(level > 66) then
            battery = " <span color='lightgreen'>BAT: " .. level .. "%</span> |"
        elseif(level > 33) then
            battery = " <span color='orange'>BAT: " .. level .. "%</span> |"
        else
            battery = " <span color='pink'>BAT: " .. level .. "%</span> |"
        end
    else
        battery = " <span color='lavender'>AC : " .. level .. "%</span> |"
    end
    widget:set_markup(battery)
end

update_battery(battery_widget)

local mytimer = timer({ timeout = 0.5 })
mytimer:connect_signal("timeout", function () update_battery(battery_widget) end)
mytimer:start()

return battery_widget
