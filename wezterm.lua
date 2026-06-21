local wezterm = require 'wezterm'
local config = wezterm.config_builder()

require('config.appearance').apply_to_config(config)
require('config.shell').apply_to_config(config)
require('launch.menu').apply_to_config(config)
require('features.agent_status').apply_to_config(config)
require('features.tab_rename').apply_to_config(config)
require('features.status_area').apply_to_config(config)
require('input.mouse').apply_to_config(config)
require('features.pane_actions').apply_to_config(config)
require('input.keys').apply_to_config(config)

return config
