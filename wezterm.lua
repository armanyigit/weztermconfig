local wezterm = require('wezterm')
local act = wezterm.action

-- Detect if active pane is running nvim
local function is_vim(pane)
  local info = pane:get_foreground_process_info()
  return info and info.name == 'nvim'
end

-- Build a nav key that forwards to nvim or moves the wezterm pane
local dir_keys = { h = 'Left', j = 'Down', k = 'Up', l = 'Right' }

local function nav(key)
  return {
    key = key,
    mods = 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        win:perform_action(act.SendKey({ key = key, mods = 'CTRL' }), pane)
      else
        win:perform_action(act.ActivatePaneDirection(dir_keys[key]), pane)
      end
    end),
  }
end

local function resize(key)
  return {
    key = key,
    mods = 'META',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        win:perform_action(act.SendKey({ key = key, mods = 'META' }), pane)
      else
        win:perform_action(act.AdjustPaneSize({ dir_keys[key], 3 }), pane)
      end
    end),
  }
end

return {
  -- Font
  font = wezterm.font('JetBrains Mono', { weight = 'Regular' }),
  font_size = 15.0,

  -- Colors
  color_scheme = 'Tokyo Night',

  -- Window
  window_decorations = 'RESIZE',
  window_padding = { left = 4, right = 4, top = 4, bottom = 4 },

  -- Hide tab bar (single tab workflow)
  enable_tab_bar = false,

  -- Misc
  scrollback_lines = 5000,
  enable_scroll_bar = false,
  audible_bell = 'Disabled',

  -- Keys
  keys = {
    -- Pane navigation (synced with smart-splits.nvim)
    nav('h'), nav('j'), nav('k'), nav('l'),
    -- Pane resize
    resize('h'), resize('j'), resize('k'), resize('l'),
    -- Pane splitting
    { key = '|', mods = 'CTRL|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = 's', mods = 'CTRL|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane({ confirm = false }) },
    { key = 'Space', mods = 'CTRL|SHIFT', action = act.QuickSelect },
  },
}
