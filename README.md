# WezTerm Config

This repository contains the actively used WezTerm configuration from
`~/.config/wezterm`.

## Layout

- `wezterm.lua`: thin entrypoint that assembles the config
- `appearance.lua`: fonts, colors, tab bar, scrollback, reload behavior
- `shell.lua`: default shell and environment bootstrapping
- `platform.lua`: minimal platform facts used by other modules
- `keys.lua`: keyboard bindings
- `mouse.lua`: mouse behavior
- `events.lua`: named WezTerm events and tab-title formatting
- `pane_actions.lua`: pane-close behavior that cooperates with vim/neovim

## Maintenance Rules

- Keep `platform.lua` limited to platform facts, not higher-level key aliases.
- Derive composite modifier strings close to the bindings that use them.
- Give custom events explicit names so `wezterm show-keys` stays readable.
- Prefer small, behavior-preserving changes and verify with `wezterm show-keys`.

## Verification

Run after key or event changes:

```bash
wezterm show-keys
```

The config hot-reloads in most cases, but opening a new tab or restarting
WezTerm is still the cleanest way to validate startup-related changes.
