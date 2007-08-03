-- $Id$

require 'shell'
require 'shell.tray'
require 'ui.key'
require 'ui.hotkey'
require 'ui.tray'
require 'ui.window'




function reload_config()
  dofile(cereja.user_directory .. '\\config.lua')
end




local metrics = ui.window.get_minimized_metrics()
metrics.arrange = bor(metrics.arrange, ui.window.ARW_HIDE)
ui.window.set_minimized_metrics(metrics)


shell.tray.subscribe(function (event, icon_index, flags)
  if event == shell.tray.NIM_ADD then
    shell.tray.sort_icons()
  end
  return
end)
shell.tray.sort_icons()

ui.tray.activate()


if not (cereja.on_other_shellp or ui.key.pressedp('Shift')) then
  shell.run_startup_programs()
end

reload_config()

-- __END__
