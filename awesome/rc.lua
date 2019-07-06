-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")

local lain = require("lain")

local runner = require('run_once')

-- Load Debian menu entries
require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, an error happened!",
        text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme/theme.lua")

-- Start composite manager
runner.run("compton &")
runner.run("urxvtd -q -f -o &")
runner.run("screenkey --no-systray &")
--runner.run("bash -c `cd /home/vantreeseba && tern --persistent --ignore-stdin --port 58580` &")

--load widgets after theme
-- local volume_widget = require("volume");
local battery_widget = require("battery");
-- local tasks_widget = require("tasks");
local pomodoro = require("pomodoro");
-- local git_status = require("git-ci-status");
local git_status = require("git-issue-count");
-- local pomodoro_widget = pomodoro.widget;
-- local git_status_widget = git_status.widget;

local getcwd = require("focused_window_cwd");


-- Setting notification styles
naughty.config.defaults.position         = "bottom_right"
naughty.config.defaults.margin           = 16
--naughty.config.defaults.height           = 160
--naughty.config.defaults.width            = 480
naughty.config.defaults.spacing          = 2
naughty.config.defaults.font             = beautiful.font or "Verdana 8"
--naughty.config.defaults.border_width     = 10
naughty.config.defaults.bg                = "#181818"

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    --awful.layout.suit.floating,
    --lain.layout.uselessfair,
    --lain.layout.uselesstile.right,
		--lain.layout.uselesstile.top,
		--lain.layout.uselesspiral
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
{ "Debian", debian.menu.Debian_menu.Debian },
{ "open terminal", terminal }
}})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

-- Create a network usage widget
netwidget = wibox.widget.textbox();
vicious.register(netwidget,
vicious.widgets.net,
'<span color="lavender">network: ${enp0s3 down_kb}<span color="#66FF66">↓</span> ${enp0s3 up_kb}<span color="#FF6666">↑</span></span> |',
3);

-- Memory usage widget
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, "<span color='lightblue'>ram: $1% </span>| ", 13)

-- CPU Usage widget
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, "<span color='orange'>cpu: $1% </span>| ")

-- Create a textclock widget
mytextclock = awful.widget.textclock(' %m/%d/%Y %H:%M ')

-- Create a wibox for each screen and add it
topwibox = {}
bottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
    if c == client.focus then
        c.minimized = true
    else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
end),
awful.button({ }, 3, function ()
    if instance then
        instance:hide()
        instance = nil
    else
        instance = awful.menu.clients({
            theme = { width = 250 }
        })
    end
end),
awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
end),
awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    topwibox[s] = awful.wibox({ position = "top", screen = s })
    bottomwibox[s] = awful.wibox({ position = "bottom", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    -- left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(cpuwidget)
    right_layout:add(memwidget)
    right_layout:add(netwidget)
		-- right_layout:add(volume_widget)
    right_layout:add(battery_widget)
    right_layout:add(mytextclock)
    --right_layout:add(tasks_widget)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local top_layout = wibox.layout.align.horizontal()
    top_layout:set_left(left_layout)
    top_layout:set_middle(mytasklist[s])
    top_layout:set_right(right_layout)

    local bottom_layout = wibox.layout.align.horizontal();
    bottom_layout:set_left(pomodoro_widget);
    -- bottom_layout:set_right(git_status_widget);

    topwibox[s]:set_widget(top_layout)

    bottomwibox[s]:set_widget(bottom_layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

-- awful.key({ altKey,           }, "Tab",
-- function ()
--     awful.client.focus.byidx(1)
--     if client.focus then client.focus:raise() end
-- end),

awful.key({ modkey,           }, "j",
function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "k",
function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

-- Layout manipulation
awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
-- awful.key({ modkey,           }, "Tab",
-- function ()
--     awful.client.focus.history.previous()
--     if client.focus then
--         client.focus:raise()
--     end
-- end),

-- Standard program
awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
awful.key({ modkey, "Control" }, "r", awesome.restart),
awful.key({ modkey, "Shift"   }, "q", awesome.quit),

awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)    end),
awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)    end),
--awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
--awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

awful.key({ modkey, "Control" }, "n", awful.client.restore),

-- Prompt
awful.key({ altkey },            "space", function ()
    awful.prompt.run({ autoexec = true, prompt = "Run:"},
    mypromptbox[mouse.screen.index].widget,
    function (...) awful.util.spawn(...) end,
    awful.completion.shell,
    awful.util.getdir("cache") .. "/history")
end),

awful.key({ modkey, altkey    }, "space", function ()
    awful.prompt.run({ autoexec = true, prompt = "RIT:"},
    mypromptbox[mouse.screen.index].widget,
    function (...) awful.util.spawn(terminal .. " -e " .. ...) end,
    awful.completion.shell,
    awful.util.getdir("cache") .. "/history")
end),


awful.key({ modkey }, "x", function ()
    awful.prompt.run({ prompt = "Run Lua code: " },
    mypromptbox[mouse.screen.index].widget,
    awful.util.eval, nil,
    awful.util.getdir("cache") .. "/history_eval")
end),
-- Menubar
--awful.key({ modkey }, "p", function() menubar.show() end),
-- Start pomodoro
-- awful.key({ modkey          }, "p", function() pomodoro:start() end),
awful.key({ modkey, "Shift" }, "p", function() pomodoro:stop() end),
awful.key({ modkey          }, "p", function() getcwd() end),

awful.key({ modkey }, "F3", function () awful.util.spawn("amixer set Master 9%+") end),
awful.key({ modkey }, "F2", function () awful.util.spawn("amixer set Master 9%-") end),
awful.key({ modkey }, "F1", function () awful.util.spawn("amixer sset Master toggle") end)
)

clientkeys = awful.util.table.join(
awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
awful.key({ altkey            }, "F4",     function (c) c:kill()                         end),
awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky          end),
awful.key({ modkey,           }, "n",
function (c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end),
awful.key({ modkey,           }, "m",
function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
            awful.tag.viewonly(tag)
        end
    end),
    -- Toggle tag.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
            awful.tag.viewtoggle(tag)
        end
    end),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
        if client.focus then
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if tag then
                awful.client.movetotag(tag)
            end
        end
    end),
    -- Toggle tag.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
    function ()
        if client.focus then
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if tag then
                awful.client.toggletag(tag)
            end
        end
    end))
end

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
    properties = { border_width = 1, --beautiful.border_width,
    border_color = 111111, beautiful.border_normal,
    focus = awful.client.focus.filter,
    size_hints_honor = false,
    raise = true,
    keys = clientkeys,
    buttons = clientbuttons } },

    { rule = { name = "YAD"},
    properties = { 
      floating = true,
      x = 500,
      y = 500,
      ontop = true
    } },

    { rule = { class = "Screenkey" },
    properties = {
        floating = true,
        --x = 0,
        --y = 0,
        --width = 50,
        height = 10,
        focus = false,
        maximized_horizontal = true,
        sticky = true,
        ontop = true
    } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { name = "WeeChat 1.4" },
       properties = { tag = tags[1][9] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
        elseif not c.size_hints.user_position and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count change
            awful.placement.no_offscreen(c)
        end

        local titlebars_enabled = false
        if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
            -- buttons for the titlebar
            local buttons = awful.util.table.join(
            awful.button({ }, 1, function()
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
            end),
            awful.button({ }, 3, function()
                client.focus = c
                c:raise()
                awful.mouse.client.resize(c)
            end)
            )

            -- Widgets that are aligned to the left
            local left_layout = wibox.layout.fixed.horizontal()
            left_layout:add(awful.titlebar.widget.iconwidget(c))
            left_layout:buttons(buttons)

            -- Widgets that are aligned to the right
            local right_layout = wibox.layout.fixed.horizontal()
            right_layout:add(awful.titlebar.widget.floatingbutton(c))
            right_layout:add(awful.titlebar.widget.maximizedbutton(c))
            right_layout:add(awful.titlebar.widget.stickybutton(c))
            right_layout:add(awful.titlebar.widget.ontopbutton(c))
            right_layout:add(awful.titlebar.widget.closebutton(c))

            -- The title goes in the middle
            local middle_layout = wibox.layout.flex.horizontal()
            local title = awful.titlebar.widget.titlewidget(c)
            title:set_align("center")
            middle_layout:add(title)
            middle_layout:buttons(buttons)

            -- Now bring it all together
            local layout = wibox.layout.align.horizontal()
            layout:set_left(left_layout)
            layout:set_right(right_layout)
            layout:set_middle(middle_layout)

            awful.titlebar(c):set_widget(layout)
        end
    end)

    client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
    client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
    -- }}}



