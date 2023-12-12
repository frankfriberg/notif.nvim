local config = require("notif.config")
local util = require("notif.util")
local M = {}

M.create_window = function(lines, title, icon, level)
  local level_options = util.levels[level]
  local win_title = string.format(" %s %s ", icon or level_options.icon, title or level_options.name)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative = config.win_options.relative,
    anchor = util.positions[config.win_options.position].anchor,
    width = config.max_width,
    height = #lines,
    row = util.get_row(),
    col = util.get_col(),
    style = 'minimal',
    border = config.win_options.border,
    title = win_title,
    focusable = false,
    noautocmd = true,
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "filetype", "NotifMessage")
  vim.api.nvim_win_set_hl_ns(win, config.ns_id)
  vim.api.nvim_win_set_option(
    win,
    'winhighlight',
    string.format(
      'Normal:NormalNC,FloatTitle:%s,FloatBorder:%s',
      level_options.color,
      level_options.color
    )
  )

  return win, buf
end

M.set_win_position = function(message, new_row, new_col)
  if not vim.api.nvim_win_is_valid(message.win) then return end

  vim.api.nvim_win_set_config(message.win, {
    relative = config.win_options.relative,
    row = new_row,
    col = new_col or message.col,
  })

  message.row = new_row
end

return M
