local wezterm = require 'wezterm'

local config = wezterm.config_builder()


config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.use_fancy_tab_bar = true

config.window_frame = {
  font = wezterm.font 'SF Pro',
  font_size = 14,

  active_titlebar_bg = '#f0f0f1',
  inactive_titlebar_bg = '#f0f0f1'
}

config.hide_tab_bar_if_only_one_tab = false
-- config.show_close_tab_button_in_tabs = false

-- config.enable_scroll_bar = true


config.font = wezterm.font 'Monaco'
config.font_size = 14

config.initial_cols = 120
config.initial_rows = 48

config.bold_brightens_ansi_colors = "BrightOnly"


config.colors = {
  background = '#fcfcfc',
  foreground = '#3a3a3a',

  cursor_border = '#bcbcbc',
  cursor_bg = '#bcbcbc',
  cursor_fg = '#3a3a3a',

  selection_bg = '#fffacd',
  selection_fg = 'black',

  ansi = {
    '#808080', -- black
    '#ec6871', -- red
    '#89c186', -- green
    '#f3b665', -- yellow
    '#70a3d0', -- blue
    '#cd9fcc', -- magenta
    '#67bcbb', -- cyan
    '#fcfcfc', -- white
  },

  brights = {
    '#161616', -- black
    '#ee8689', -- red
    '#99d195', -- green
    '#f6cc96', -- yellow
    '#7fb3e1', -- blue
    '#ddafdb', -- magenta
    '#77cccb', -- cyan
    '#feffff', -- white
  },

  tab_bar = {
    background = '#f0f0f1',

    active_tab = {
      bg_color = '#fcfcfc',
      fg_color = '#3a3a3a',
    },

    inactive_tab_edge = '#f0f0f1',

    inactive_tab = {
      bg_color = '#f0f0f1',
      fg_color = '#3a3a3a',
    },

    inactive_tab_hover = {
      bg_color = '#d6d7d7',
      fg_color = '#3a3a3a',
    },

    new_tab = {
      bg_color = '#f0f0f1',
      fg_color = '#3a3a3a',
    },

    new_tab_hover = {
      bg_color = '#d6d7d7',
      fg_color = '#3a3a3a',
    },
  },

  scrollbar_thumb = '#f0f0f1'
}


return config
