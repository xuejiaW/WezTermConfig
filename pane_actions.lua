local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}
M.close_pane_event = 'close-pane-with-editor-cleanup'

local function percent_decode(value)
  return value:gsub('%%(%x%x)', function(hex)
    return string.char(tonumber(hex, 16))
  end)
end

local function file_path_from_uri(uri)
  local url = nil

  if wezterm.url and wezterm.url.parse then
    local ok, parsed = pcall(wezterm.url.parse, uri)
    if ok then
      url = parsed
    end
  end

  if url and url.scheme == 'file' then
    return url.file_path
  end

  local path = uri:gsub('^file://[^/]*', '')
  if path == uri then
    return nil
  end

  path = percent_decode(path)
  if path:match('^/[A-Za-z]:/') then
    path = path:sub(2):gsub('/', '\\')
  end

  return path
end

local function current_working_dir_path(pane)
  local cwd = pane:get_current_working_dir()
  if not cwd then
    return nil
  end

  if type(cwd) == 'string' then
    return file_path_from_uri(cwd)
  end

  if cwd.scheme == 'file' then
    return cwd.file_path
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

function M.split_with_current_working_dir(direction)
  return wezterm.action_callback(function(_window, pane)
    local args = {
      direction = direction,
      size = 0.5,
    }

    local cwd = current_working_dir_path(pane)
    if cwd then
      args.cwd = cwd
    end

    local ok, new_pane = pcall(function()
      return pane:split(args)
    end)

    if not ok and args.cwd then
      local fallback_args = {
        direction = direction,
        size = 0.5,
      }
      ok, new_pane = pcall(function()
        return pane:split(fallback_args)
      end)
    end

    if not ok then
      wezterm.log_error('failed to split pane: ' .. tostring(new_pane))
      return
    end

    if new_pane then
      new_pane:activate()
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
