local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}
M.close_pane_event = 'close-pane-with-editor-cleanup'

local function basename(path)
  if not path or path == '' then
    return ''
  end
  return path:gsub('^.*[\\/]', '')
end

local function is_vim_process(process_name)
  local name = basename(process_name):lower()
  return name == 'nvim'
      or name == 'vim'
      or name == 'vimdiff'
      or name == 'view'
      or name == 'vi'
end

function M.apply_to_config(_config)
  wezterm.on(M.close_pane_event, function(window, pane)
    if is_vim_process(pane:get_foreground_process_name()) then
      -- Try to leave insert mode and ask vim/neovim to quit cleanly. If there
      -- are unsaved changes, the editor will stay open and we won't force-close
      -- the pane.
      pane:send_text('\x1b:qa\n')
      wezterm.sleep_ms(150)
      if is_vim_process(pane:get_foreground_process_name()) then
        return
      end
    end

    window:perform_action(act.CloseCurrentPane { confirm = false }, pane)
  end)
end

return M
