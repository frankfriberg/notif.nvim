local window = require("notif.window")
local util = require("notif.util")

local M = {}
M.messages = {}
M.history = {}
M.id = 1

M.unshift_messages = function(height, index)
	for i = 1, index - 1 do
		if M.messages[i] then
			local message = M.messages[i]
			window.set_win_position(message, message.row - util.direction() * (height + 2))
		end
	end
end

M.shift_messages = function(height)
	for _, message in pairs(M.messages) do
		window.set_win_position(message, message.row + util.direction() * (height + 2))
	end
end

M.remove_message = function(id)
	local win = M.messages[id].win
	M.unshift_messages(M.messages[id].height, id)
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	M.messages[id] = nil
end

M.update_message = function(lines, message, icon)
	if not vim.api.nvim_win_is_valid(message.win) then
		return
	end

	local win_title = window.get_win_title(message.title, icon, {})
	local width = window.get_max_width(win_title, lines)

	vim.api.nvim_buf_set_lines(message.buf, 0, -1, false, lines)
	vim.api.nvim_win_set_width(message.win, width)
	message.text = lines
end

local check_token = function(token)
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

local check_message = function(lines, title)
	for _, message in pairs(M.messages) do
		if message.text == lines and message.title == title then
			return message
		end
	end
end

M.add_message = function(text, title, icon, log_level, token, lifetime)
	local config = require("notif.config").get()
	local lines = util.split_string_into_lines(text, config.max_width, config.win_options.border)
	local existing_token = check_token(token)
	local existing_message = check_message(lines, title)

	if existing_token then
		return M.update_message(lines, existing_token)
	end
	if existing_message then
		return M.update_message(lines, existing_message)
	end

	local level = log_level or vim.log.levels.INFO
	local win, buf = window.create_window(lines, title, icon, level)
	local id = M.id

	M.shift_messages(#lines)

	local row, col = util.get_row_and_col()

	local message = {
		win = win,
		buf = buf,
		height = #lines,
		level = level,
		title = title,
		text = lines,
		row = row,
		col = col,
		token = token,
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

local autogroup = vim.api.nvim_create_augroup("notif", { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
	group = autogroup,
	callback = function()
		local row, col = util.get_row_and_col()
		for _, message in pairs(M.messages) do
			window.set_win_position(message, row, col)
		end
	end,
})

return M
