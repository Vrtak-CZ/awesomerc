-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/vrtak-cz/.config/awesome/themes/starenka/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"
ctrlkey = "Control"
shiftkey = "Shift"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  names = { 'term', 'www', 'dev', 'media', 'xmpp', 'monit', 'tmp' },
  layout = {
    layouts[9], layouts[9], layouts[9], layouts[9], layouts[9], layouts[9], layouts[9]
  }
}

for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layout)
end


-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
  { "restart", awesome.restart },
  { "quit", awesome.quit }
}

mymainmenu = awful.menu({
  items = {
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "browser", "google-chrome" },
    { "terminal", terminal }
  }
})

mylauncher = awful.widget.launcher({
  image = image(beautiful.awesome_icon),
  menu = mymainmenu
})
-- }}}

-- Keyboard layout switching
kbdcfg = {
  cmd = "setxkbmap",
  layout = { "us", "cz" },
  current = 1,
  widget = widget({ type = "textbox", align = "right" })
}
kbdcfg.switch = function()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
  local t = " " .. kbdcfg.layout[kbdcfg.current] .. " "
  kbdcfg.widget.text = t:gsub('%s%-variant%s', ':')
  os.execute(kbdcfg.cmd .. t)
end
kbdcfg.widget.text = " " .. kbdcfg.layout[kbdcfg.current] .. " "
-- Mouse bindings
kbdcfg.widget:buttons(awful.util.table.join(awful.button({}, 1, function() kbdcfg.switch() end)))

-- battery
battery = require('battery')
battery_poll_int = 7

-- battery.settings={color='#dcdccc', battery='BAT0', warning={ color='#fecf35', level=31}, critical={color='red', level=16}}
batterywidget = {
  widget = widget({ type = "textbox", name = "batterywidget", align = "right" }),
  timer = timer({ timeout = battery_poll_int })
}
batterywidget.widget.text = " ?? "
batterywidget.timer:add_signal("timeout", function() batterywidget.widget.text = battery.get_info() end)
batterywidget.timer:start()

-- wifi
wifi = require('wifi')

wifiwidget = {
  widget = widget({type = "textbox", name = "wifiwidget", align = "right" }),
  timer = timer({ timeout = 5 })
}
wifiwidget.widget.text = " ?? "
wifiwidget.timer:add_signal("timeout", function() wifiwidget.widget.text = wifi("wlan0") end)
wifiwidget.timer:start()

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, " %b %d, %H:%M ")

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(awful.button({}, 1, awful.tag.viewonly),
  awful.button({ modkey }, 1, awful.client.movetotag),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, awful.client.toggletag),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev))
mytasklist = {}
mytasklist.buttons = awful.util.table.join(awful.button({}, 1, function(c)
  if c == client.focus then
    c.minimized = true
  else
    if not c:isvisible() then
      awful.tag.viewonly(c:tags()[1])
    end
    -- This will also un-minimize
    -- the client, if needed
    client.focus = c
    c:raise()
  end
end),
  awful.button({}, 3, function()
    if instance then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ width = 250 })
    end
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end))



-- Left padding
padding_left = widget({ type = "textbox", name = "left-padding", align = "left" })
padding_left.text = " "
-- Right padding
padding_right = widget({ type = "textbox", name = "right-padding", align = "right" })
padding_right.text = " "
--widget sep
widget_sep = widget({ type = "textbox", name = "widget-sep", align = "right" })
widget_sep.text = "|"

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
    awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
    awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
    awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(function(c)
    return awful.widget.tasklist.label.currenttags(c, s)
  end, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s })
  -- Add widgets to the wibox - order matters
  mywibox[s].widgets = {
    {
      padding_left,
      mypromptbox[s],
      mytaglist[s],
      padding_right,
      padding_right,
      layout = awful.widget.layout.horizontal.leftright
    },
    {
--      mylayoutbox[s],
      mytextclock,
      widget_sep,
      kbdcfg.widget,
      widget_sep,
      batterywidget.widget,
      widget_sep,
      wifiwidget.widget,
      widget_sep,
      padding_right,
      layout = awful.widget.layout.horizontal.rightleft
    },
    s == 1 and mysystray or nil,
    mytasklist[s],
    layout = awful.widget.layout.horizontal.rightleft
  }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(awful.button({}, 3, function() mymainmenu:toggle() end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)))
-- }}}


-- {{{ Key bindings (use xev)
globalkeys = awful.util.table.join(awful.key({ ctrlkey, altkey, }, "Left", awful.tag.viewprev),
  awful.key({ ctrlkey, altkey }, "Right", awful.tag.viewnext),

  awful.key({ altkey, }, "Tab", function () awful.client.focus.byidx(1) if client.focus then client.focus:raise() end end),
  awful.key({ altkey, shiftkey }, "Tab", function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end),

  -- Layout manipulation
  awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
  awful.key({ modkey, }, "Tab",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),

  -- Standard program
  awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end),
  awful.key({ modkey, ctrlkey }, "r", awesome.restart),
  awful.key({ modkey, shiftkey }, "q", awesome.quit),

  awful.key({ modkey, ctrlkey }, "n", awful.client.restore),

  awful.key({ ctrlkey, altkey }, "k", function() kbdcfg.switch() end),

  -- volume
  awful.key({}, "XF86AudioRaiseVolume", function() awful.util.spawn("amixer -c 0 set Master 2+ unmute") end),
  awful.key({}, "XF86AudioLowerVolume", function() awful.util.spawn("amixer -c 0 set Master 2- unmute") end),
  awful.key({}, "XF86AudioMute", function() awful.util.spawn("amixer set Master toggle") end),

  -- misc
  awful.key({ altkey, }, "space", function() mypromptbox[mouse.screen]:run() end), --prompt
  awful.key({}, "Print", function() awful.util.spawn("scrot") end), -- screenshot
  awful.key({ ctrlkey }, "Escape", function() awful.util.spawn("htop") end), -- "htop"

  awful.key({ modkey }, "x", function() awful.util.spawn("terminator -x ipython") end)) -- spawn term w/ python

clientkeys = awful.util.table.join(awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
  awful.key({ modkey, shiftkey }, "c", function(c) c:kill() end),
  awful.key({ modkey, ctrlkey }, "space", awful.client.floating.toggle),
  awful.key({ modkey, ctrlkey }, "Return", function(c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey, }, "m",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical = not c.maximized_vertical
    end))

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewonly(tags[screen][i])
        end
      end),
    awful.key({ modkey, ctrlkey }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewtoggle(tags[screen][i])
        end
      end),
    awful.key({ modkey, shiftkey }, "#" .. i + 9,
      function()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.movetotag(tags[client.focus.screen][i])
        end
      end),
    awful.key({ modkey, ctrlkey, shiftkey }, "#" .. i + 9,
      function()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.toggletag(tags[client.focus.screen][i])
        end
      end))
end

clientbuttons = awful.util.table.join(awful.button({}, 1, function(c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = true,
      keys = clientkeys,
      buttons = clientbuttons
    }
  },
  {
    rule = { class = "gimp" },
    properties = { floating = true }
  },

  -- default apps -> tags
  -- xprop | grep WM_CLAS
  { rule = { class = "OperaNext" }, properties = { tag = tags[1][2] }, maximized_vertical = true, maximized_horizontal = true, },
  { rule = { class = "Opera" }, properties = { tag = tags[1][2] }, maximized_vertical = true, maximized_horizontal = true, },
  { rule = { class = "Google-chrome" }, properties = { tag = tags[1][2] }, maximized_vertical = true, maximized_horizontal = true, },
  { rule = { class = "Pidgin" }, properties = { tag = tags[1][5] } },
  { rule = { class = "Conversation" }, properties = { tag = tags[1][5] } },
  { rule = { class = "Sublime_text" }, properties = { tag = tags[1][3] }, maximized_vertical = true, maximized_horizontal = true, },
  { rule = { class = "Sublime" }, properties = { tag = tags[1][3] }, maximized_vertical = true, maximized_horizontal = true, },
  { rule = { class = "Vlc" }, properties = { tag = tags[1][4] } },
  { rule = { class = "jd-Main" }, properties = { tag = tags[1][7] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function(c, startup)
-- Add a titlebar
--awful.titlebar.add(c, { modkey = modkey })

-- Enable sloppy focus
  c:add_signal("mouse::enter", function(c)
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
  end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- run_once = require('run_once')
-- run_once.run_once("terminator")
-- run_once.run_once("/home/starenka/.dropbox-dist/dropboxd")
-- Use the second argument, if the programm you wanna start, 
-- differs from the what you want to search.
-- run_once("redshift", "nice -n19 redshift -l 51:14 -t 5700:4500")

-- function find_tag (name, s) local s = s or mouse.screen for _, t in pairs(tags[s]) do if t.name == name then return t end end end

-- remove spawn cursor
local oldspawn = awful.util.spawn
awful.util.spawn = function(s)
  oldspawn(s, false)
end
