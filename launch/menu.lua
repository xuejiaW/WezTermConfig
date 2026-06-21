local launch_paths = require 'launch.paths'

local M = {}

function M.apply_to_config(config)
  config.launch_menu = launch_paths.launch_menu()
end

return M
