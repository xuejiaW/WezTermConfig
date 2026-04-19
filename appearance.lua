local M = {}

function M.apply_to_config(config)
  -- WezTerm supports hot reloading config files.
  -- With automatically_reload_config enabled, saving this file will usually
  -- refresh key bindings and visual settings immediately.
  -- Startup-related settings such as default_prog are safer to verify by opening
  -- a new tab/window, and in some cases a full restart is still the cleanest way
  -- to confirm the behavior.
  config.automatically_reload_config = true

  config.color_scheme = 'OneHalfDark'
  config.font_size = 14.0
  config.window_frame = {
    font_size = 14.0,
  }

  config.use_fancy_tab_bar = true
  config.tab_bar_at_bottom = true
  config.show_tab_index_in_tab_bar = true
  config.switch_to_last_active_tab_when_closing_tab = true
  config.scrollback_lines = 50000
  config.alternate_buffer_wheel_scroll_speed = 1
end

return M
