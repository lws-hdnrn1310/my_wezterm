local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'nightfox'
config.automatically_reload_config = true
config.font_size = 14
config.use_ime = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}
-- https://github.com/mbadolato/iTerm2-Color-Schemes/blob/bfb3ee10c53e0f3eb2d97626d2fe48f3e0204e53/wezterm/Nightfox.toml#L4
config.window_background_gradient = {
  colors = { "#192330" },
}
config.show_new_tab_button_in_tab_bar = false
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
  split = "#ae8b2d",
}
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.6,
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"

  if tab.is_active then
   background = "#ae8b2d"
   foreground = "#FFFFFF"
  end

  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
   { Background = { Color = background } },
   { Foreground = { Color = foreground } },
   { Text = title },
  }
end)

local act = wezterm.action

local function setup_dev_layout(window, pane)
  -- 今いるpaneを左側のnvim用
  local cwd_uri = pane:get_current_working_dir()
  local cwd = cwd_uri and cwd_uri.file_path or nil

  -- 右側30%
  local claude_pane = pane:split {
    direction = 'Right',
    size = 0.30,
    cwd = cwd,
  }

  -- 右側上下に分割
  local bottom_pane = claude_pane:split {
    direction = 'Bottom',
    size = 0.50,
    cwd = cwd,
  }

  -- コマンド投入
  pane:send_text("nvim\n")
  claude_pane:send_text('claude\n')
  bottom_pane:send_text('git status\n')
end

local extra_keys = {
  { key = 'UpArrow', mods = 'CMD', action = act.ScrollByLine(-3) },
  { key = 'DownArrow', mods = 'CMD', action = act.ScrollByLine(3) },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      setup_dev_layout(window, pane)
    end),
  },
}

config.keys = require("keybinds").keys
for _, k in ipairs(extra_keys) do
  table.insert(config.keys, k)
end
config.key_tables = require("keybinds").key_tables

return config

