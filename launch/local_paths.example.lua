local wezterm = require 'wezterm'

local function home_path(path)
  return wezterm.home_dir .. path
end

return {
  {
    label = 'Projects',
    cwd = home_path '/Projects',
  },
  {
    label = 'Workspaces',
    cwd = home_path '/Projects/workspaces',
  },
}
