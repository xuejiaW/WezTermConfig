local wezterm = require 'wezterm'
local platform = require 'platform'

local M = {}

local function home_path(path)
  return wezterm.home_dir .. path
end

local function common_paths()
  if platform.is_windows then
    return {}
  end

  return {
    {
      label = 'Launcher Unity',
      cwd = home_path '/Projects/refactor_Launcher/dronelauncherunity',
    },
    {
      label = 'Projects',
      cwd = home_path '/Projects',
    },
    {
      label = 'Workspaces',
      cwd = home_path '/Projects/workspaces',
    },
    {
      label = 'Public Volume',
      cwd = '/Volumes/公共空间/',
    },
  }
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
