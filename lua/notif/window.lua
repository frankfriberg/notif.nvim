local util = require("notif.util")
local W = {}

W.get_win_title = function(title, icon, options)
	local win_icon = icon or options.icon or ""
	local win_title = title or options.name or ""
	return string.format(" %s %s ", win_icon, win_title)
end

W.get_max_width = function(title, lines)
	local config = require("notif.config").get()
	local title_width = title and title:len() or 0
	local description_width = 0
	for _, line in ipairs(lines) do
		description_width = math.max(description_width, #line)
	end

	local border_width = config.win_options.border ~= nil and 1 or 0
	local max_text_width = math.max(title_width, description_width) + border_width
	return math.min(max_text_width, config.max_width)
end

local get_win_config = function(title, height, width, relative, position, border)
	local row, col = util.get_row_and_col()
	return {
		relative = relative,
		anchor = util.positions[position].anchor,
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = border,
		title = title,
		focusable = false,
		noautocmd = true,
	}
end

local set_buf_options = function(buf, lines)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("filetype", "NotifMessage", { buf = buf })
end

local set_win_options = function(win, level_options, namespace)
	local text_color
	vim.api.nvim_win_set_hl_ns(win, namespace)

	local highlight =
		string.format("Normal:%s,FloatTitle:%s,FloatBorder:%s", text_color, level_options.color, level_options.color)

	vim.api.nvim_set_option_value("winhighlight", highlight, { win = win })
end

W.set_win_position = function(message, new_row, new_col)
	local config = require("notif.config").get()
	if not vim.api.nvim_win_is_valid(message.win) then
		return
	end

	vim.api.nvim_win_set_config(message.win, {
		relative = config.win_options.relative,
		row = new_row,
		col = new_col or message.col,
	})

	message.row = new_row
end

W.create_window = function(lines, title, icon, level)
	local config = require("notif.config").get()
	local level_options = util.levels(level)

	local win_title = W.get_win_title(title, icon, level_options)

	local max_width = W.get_max_width(win_title, lines, config.max_width, config.win_options.border)

	local win_options = get_win_config(
		win_title,
		#lines,
		max_width,
		config.win_options.relative,
		config.win_options.position,
		config.win_options.border
	)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, false, win_options)

	set_buf_options(buf, lines)
	set_win_options(win, level_options, config.ns_id)

	return win, buf
end

return W
