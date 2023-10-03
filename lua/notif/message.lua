local window = require("notif.window")
local config = require("notif.config")
local util = require("notif.util")

local M = {}
M.messages = {}
M.history = {}
M.id = 1

M.unshift_messages = function(height, index)
  for i = 1, index - 1 do
    if M.messages[i] then
      local message = M.messages[i]
      window.set_win_position(message, message.row - util.adjustment * (height + 2))
    end
  end
end

M.shift_messages = function(height)
  for _, message in pairs(M.messages) do
    window.set_win_position(message, message.row + util.adjustment * (height + 2))
  end
end

M.remove_message = function(id)
  local win = M.messages[id].win
  M.unshift_messages(M.messages[id].height, id)
  vim.api.nvim_win_close(win, true)
  M.messages[id] = nil
end

M.update_message = function(lines, message)
  vim.api.nvim_buf_set_lines(message.buf, 0, -1, false, lines)
  message.text = lines
end

M.token_exists = function(token)
  if token ~= nil then
    for _, message in pairs(M.messages) do
      if message.token == token then
        return message
      end
    end
  else
    return nil
  end
end

M.message_exists = function(lines, title)
  for _, message in pairs(M.messages) do
    if message.text == lines and message.title == title then
      return message
    end
  end
end

M.add_message = function(text, title, icon, log_level, token, lifetime)
  local lines = util.split_string_into_lines(text)
  local token_exists = M.token_exists(token)
  local message_exists = M.message_exists(lines, title)
  if token_exists then return M.update_message(lines, token_exists) end
  if message_exists then return M.update_message(lines, message_exists) end

  local level = log_level or vim.log.levels.INFO
  local win, buf = window.create_window(lines, title, icon, level)
  local id = M.id
  M.shift_messages(#lines)
  local message = {
    win = win,
    buf = buf,
    height = #lines,
    level = level,
    title = title,
    text = lines,
    row = util.positions[config.win_options.position].row,
    col = util.positions[config.win_options.position].col,
    token = token
  }

  M.messages[id] = message
  M.history[id] = message

  vim.defer_fn(function()
    M.remove_message(id)
  end, lifetime or config.life_time)

  M.id = M.id + 1
  return message
end

M.replay_messages = function()
  for _, message in pairs(M.history) do
    M.add_message(message.text, message.title, message.level)
  end
end

return M
