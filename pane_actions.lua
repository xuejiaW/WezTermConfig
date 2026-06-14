local wezterm = require 'wezterm'
local act = wezterm.action
local launch_paths = require 'launch_paths'

local M = {}
M.close_pane_event = 'close-pane-with-editor-cleanup'

local function normalize_file_path(path)
  if wezterm.target_triple:find('windows') and path and path:match('^/[A-Za-z]:[\\/]') then
    return path:sub(2)
  end

  return path
end

local function current_working_dir_path(pane)
  local cwd = pane:get_current_working_dir()
  if not cwd then
    return nil
  end

  if cwd.scheme == 'file' then
    return normalize_file_path(cwd.file_path)
  end

  return nil
end

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

local function split_pane(pane, direction, cwd, fallback_without_cwd)
  local args = {
    direction = direction,
    size = 0.5,
  }

  if cwd then
    args.cwd = cwd
  end

  local ok, new_pane = pcall(function()
    return pane:split(args)
  end)

  if not ok and args.cwd and fallback_without_cwd then
    ok, new_pane = pcall(function()
      return pane:split {
        direction = direction,
        size = 0.5,
      }
    end)
  end

  if not ok then
    wezterm.log_error('failed to split pane: ' .. tostring(new_pane))
    return
  end

  if new_pane then
    new_pane:activate()
  end
end

function M.split_with_current_working_dir(direction)
  return wezterm.action_callback(function(_window, pane)
    split_pane(pane, direction, current_working_dir_path(pane), true)
  end)
end

function M.split_with_launch_path(direction)
  return act.InputSelector {
    title = 'Split pane in',
    choices = launch_paths.input_choices(),
    fuzzy = true,
    action = wezterm.action_callback(function(_window, pane, cwd)
      if not cwd then
        return
      end

      split_pane(pane, direction, cwd, false)
    end),
  }
end

function M.split_with_launch_path_or_current_working_dir(direction)
  local choices = launch_paths.input_choices()

  if #choices == 0 then
    return M.split_with_current_working_dir(direction)
  end

  return M.split_with_launch_path(direction)
end

function M.move_current_pane_to_new_tab()
  return wezterm.action_callback(function(_window, pane)
    local tab = pane:move_to_new_tab()
    if tab then
      tab:activate()
    end
  end)
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
