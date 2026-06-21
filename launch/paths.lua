local wezterm = require 'wezterm'

local M = {}

local function normalize_paths(paths)
  if type(paths) ~= 'table' then
    return {}
  end

  local normalized = {}

  for _, entry in ipairs(paths) do
    if type(entry) == 'table' and type(entry.label) == 'string' and type(entry.cwd) == 'string' then
      table.insert(normalized, {
        label = entry.label,
        cwd = entry.cwd,
      })
    end
  end

  return normalized
end

local function common_paths()
  local ok, paths = pcall(require, 'launch.local_paths')

  if ok then
    return normalize_paths(paths)
  end

  if not tostring(paths):find("module 'launch.local_paths' not found", 1, true) then
    wezterm.log_error('failed to load launch.local_paths: ' .. tostring(paths))
  end

  return {}
end

function M.launch_menu()
  return common_paths()
end

function M.input_choices()
  local choices = {}

  for _, entry in ipairs(common_paths()) do
    table.insert(choices, {
      label = entry.label,
      id = entry.cwd,
    })
  end

  return choices
end

return M
