local wibox = require("wibox")
local awful = require("awful")

local volume_widget = wibox.widget.textbox()
volume_widget:set_align("right")

function update_volume(widget)
    local fd = io.popen("amixer sget Master")
    local status = fd:read("*all")
    fd:close()

    local volume = string.match(status, "(%d?%d?%d)%%")
    volume = string.format("%3d", volume)

    status = string.match(status, "%[(o[^%]]*)%]")

    if string.find(status, "on", 1, true) then
        volume = " <span color='#b19cd9'>volume: " .. volume .. "%</span> |"
    else
        volume = " <span color='#ffe9de'>volume: " .. volume .. "M</span> |"
    end

    widget:set_markup(volume)
end

update_volume(volume_widget)

local mytimer = timer({ timeout = 0.2 })
mytimer:connect_signal("timeout", function () update_volume(volume_widget) end)
mytimer:start()

return volume_widget
