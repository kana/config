-- My config.lua

-- Hotkey for reload_config should be registered at first
-- to be able to reload this file even if this file is failed to load.
ui.hotkey.reset()
ui.hotkey.register('Alt-Ctrl-Shift-Win-R', reload_config)




-- tray
ui.hotkey.register('Win-T', ui.tray.activate)

ui.tray.hotkey_add('Ctrl-J', ui.tray.CMD_ICON_MOVE_LAST)
ui.tray.hotkey_add('Ctrl-K', ui.tray.CMD_ICON_MOVE_FIRST)
ui.tray.hotkey_add('Ctrl-Shift-J', ui.tray.CMD_ICON_SHIFT_NEXT)
ui.tray.hotkey_add('Ctrl-Shift-K', ui.tray.CMD_ICON_SHIFT_PREV)

if balloon == nil then
  balloon = {}
  balloon.ids = {}
end
function balloon.show(...)
  table.insert(balloon.ids, app.snarl.show_message(...))
end
function balloon.hide(allp)
  while 1 <= #balloon.ids do
    local id = table.remove(balloon.ids, 1)
    if app.snarl.hide_message(id) then
      if not allp then
        break
      end
    end
  end
end
ui.hotkey.register('Win-Shift-B', balloon.hide)
ui.hotkey.register('Win-Shift-Alt-B', function () balloon.hide(true) end)


-- window
ui.hotkey.register('Win-Shift-M',  -- alt method
                   function () ui.window.minimize(NULL, true) end)
ui.hotkey.register('Win-Shift-Alt-M',  -- default method
                   function () ui.window.minimize(NULL, false) end)
ui.hotkey.register('Win-Shift-X', ui.window.maximize)
ui.hotkey.register('Win-Shift-R', ui.window.restore)
ui.hotkey.register('Win-Shift-V', ui.window.maximize_vertically)
ui.hotkey.register('Win-Shift-H', ui.window.maximize_horizontally)
-- ui.hotkey.register('Win-Shift-S', ui.window.shade)
ui.hotkey.register('Win-Shift-A', ui.window.set_always_on_top)
ui.hotkey.register('Win-Shift-Space', function () ui.window.set_alpha(204) end)

ui.hotkey.register('Win-Alt-H', ui.window.snap_to_left)
ui.hotkey.register('Win-Alt-K', ui.window.snap_to_top)
ui.hotkey.register('Win-Alt-L', ui.window.snap_to_right)
ui.hotkey.register('Win-Alt-J', ui.window.snap_to_bottom)
ui.hotkey.register('Win-Alt-Shift-V',
                   function () ui.window.move('c', 'r', 0, 0) end)
ui.hotkey.register('Win-Alt-Shift-H',
                   function () ui.window.move('r', 'c', 0, 0) end)


-- application launcher
APPDIRS = {
  'C:\\cygwin\\usr\\win\\bin',
  'C:\\Program Files',
}
function appdir(app)
  for _, dir in ipairs(APPDIRS) do
    local path = dir .. '\\' .. app
    if os.pathexistsp(path) then
      return path
    end
  end
  error(string.format('Application "%s" does not exist.', app))
end

function bluewind(keyword)
  return shell.execute(nil,
                       appdir('bluewind\\bluewind.exe'),
                       '/Runcommand=' .. keyword)
end

ui.hotkey.register('Win-Ctrl-C',
                   function ()
                     shell.execute('C:\\cygwin\\usr\\local\\bin\\plala.lnk')
                   end)
ui.hotkey.register('Win-Ctrl-B', function () bluewind('bluewind') end)
ui.hotkey.register('Win-Ctrl-H', function () bluewind('home') end)
ui.hotkey.register('Win-Ctrl-I', function () bluewind('irfanview') end)
ui.hotkey.register('Win-Ctrl-J', function () bluewind('jtrim') end)
ui.hotkey.register('Win-Ctrl-L', function () bluewind('latest') end)
ui.hotkey.register('Win-Ctrl-O', function () bluewind('opera') end)
ui.hotkey.register('Win-Ctrl-S', function () bluewind('shell') end)
ui.hotkey.register('Win-Ctrl-T', function () bluewind('timedate') end)
ui.hotkey.register('Win-Ctrl-W', function () bluewind('wmp') end)

ui.hotkey.register('Alt-Ctrl-Shift-Win-S', function ()
  shell.execute(nil,
                appdir('Samurize\\Client.exe'),
                'i=Default reload')
end)




-- To avoid doubly adding subscribers.
shell.tray.unsubscribe('user')


-- Sort icons in the tray automatically.
shell.tray.subscribe('user', function (event, icon_index, flags)
  if event == shell.tray.NIM_ADD then
    shell.tray.sort_icons()
  end
  return
end)
shell.tray.sort_icons()


-- Pseudo balloon tooltips by Snarl.
shell.tray.subscribe('user', function (event, icon_index, flags)
  -- Is this an event to show a balloon tooltip?
  if event == shell.tray.NIM_MODIFY
     and band(flags, shell.tray.NIF_INFO) ~= 0
  then
    title = shell.tray.get_icon_data(icon_index, 'szInfoTitle')
    text = shell.tray.get_icon_data(icon_index, 'szInfo')
    if 0 < #text then
      balloon.show(title, text, 30)
    else
      -- Nothing to do.
      -- Because #text == 0 means a request to hide a balloon tooltip.
    end
  end
  return
end)




-- __END__
