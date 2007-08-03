-- $Id$

ui.hotkey.reset()
ui.hotkey.register('Alt-Ctrl-Shift-Win-R', reload_config)




-- tray
ui.hotkey.register('Win-T', ui.tray.activate)

ui.tray.hotkey_add('Ctrl-J', ui.tray.CMD_ICON_MOVE_LAST)
ui.tray.hotkey_add('Ctrl-K', ui.tray.CMD_ICON_MOVE_FIRST)
ui.tray.hotkey_add('S-Ctrl-J', ui.tray.CMD_ICON_SHIFT_NEXT)
ui.tray.hotkey_add('S-Ctrl-K', ui.tray.CMD_ICON_SHIFT_PREV)


-- window
local WM_SYSCOMMAND = 274
local SC_MINIMIZE = 0xF020
ui.hotkey.register('Alt-Shift-M', ui.window.minimize)
ui.hotkey.register('Alt-Shift-Win-M',
                   function ()
                     ui.window.post_message(NULL, WM_SYSCOMMAND, SC_MINIMIZE)
                   end)
ui.hotkey.register('Alt-Shift-X', ui.window.maximize)
ui.hotkey.register('Alt-Shift-R', ui.window.restore)
ui.hotkey.register('Alt-Shift-V', ui.window.maximize_vertically)
ui.hotkey.register('Alt-Shift-H', ui.window.maximize_horizontally)
-- ui.hotkey.register('Alt-Shift-S', ui.window.shade)
ui.hotkey.register('Alt-Shift-A', ui.window.set_always_on_top)
ui.hotkey.register('Alt-Shift-Space', function () ui.window.set_alpha(204) end)

ui.hotkey.register('Alt-Shift-Ctrl-H', ui.window.snap_to_left)
ui.hotkey.register('Alt-Shift-Ctrl-K', ui.window.snap_to_top)
ui.hotkey.register('Alt-Shift-Ctrl-L', ui.window.snap_to_right)
ui.hotkey.register('Alt-Shift-Ctrl-J', ui.window.snap_to_bottom)
ui.hotkey.register('Alt-Shift-Win-V',
                   function () ui.window.move('c', 'r', 0, 0) end)
ui.hotkey.register('Alt-Shift-Win-H',
                   function () ui.window.move('r', 'c', 0, 0) end)


-- launcher
function bluewind(keyword)
  return shell.execute(nil,
                       'C:\\cygwin\\usr\\win\\bin\\bluewind\\bluewind.exe',
                       '/Runcommand=' .. keyword)
end

ui.hotkey.register('Alt-Ctrl-C',
                   function ()
                     shell.execute('C:\\cygwin\\usr\\local\\bin\\plala.lnk')
                   end)
ui.hotkey.register('Alt-Ctrl-H', function () bluewind('home') end)
ui.hotkey.register('Alt-Ctrl-I', function () bluewind('irfanview') end)
ui.hotkey.register('Alt-Ctrl-J', function () bluewind('jtrim') end)
ui.hotkey.register('Alt-Ctrl-L', function () bluewind('latest') end)
ui.hotkey.register('Alt-Ctrl-O', function () bluewind('opera') end)
ui.hotkey.register('Alt-Ctrl-S', function () bluewind('shell') end)
ui.hotkey.register('Alt-Ctrl-T', function () bluewind('timidi95') end)




-- __END__
