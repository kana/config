-- $Id$

require 'shell'
require 'shell.tray'
require 'ui.key'
require 'ui.hotkey'
require 'ui.tray'
require 'ui.window'




do
  local firstp = true

  function reload_config()
    dofile(cereja.user_directory .. "\\config.lua")
    if firstp then
      firstp = false
    else
      cereja.notice_info('config.lua', 'config.lua has been reloaded.')
    end
  end
end




-- Hide minimized windows.
local metrics = ui.window.get_minimized_metrics()
metrics.arrange = bor(metrics.arrange, ui.window.ARW_HIDE)
ui.window.set_minimized_metrics(metrics)


-- Sort icons in the tray automatically.
shell.tray.subscribe(function (event, icon_index, flags)
  if event == shell.tray.NIM_ADD then
    shell.tray.sort_icons()
  end
  return
end)
shell.tray.sort_icons()


if not (cereja.on_other_shellp or ui.key.pressedp('Shift')) then
  shell.run_startup_programs()
end
reload_config()
ui.tray.activate()

-- __END__
