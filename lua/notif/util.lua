local Util = {}

local get_bottom_position = function(_, margin_bottom)
	return vim.o.lines - vim.o.cmdheight - margin_bottom
end

local get_top_position = function(margin_top, _)
	return 0 + margin_top
end

local get_left_position = function(_, margin_left)
	return 0 + margin_left
end

local get_right_position = function(_, margin_right)
	return vim.o.columns - margin_right
end

local get_center_position = function()
	return vim.o.columns / 2
end

Util.positions = {
	["bottom-left"] = {
		row = get_bottom_position,
		col = get_left_position,
		anchor = "SW",
		top_down = false,
	},
	["bottom-center"] = {
		row = get_bottom_position,
		col = get_center_position,
		anchor = "SW",
		top_down = false,
	},
	["bottom-right"] = {
		row = get_bottom_position,
		col = get_right_position,
		anchor = "SE",
		top_down = false,
	},
	["top-left"] = {
		row = get_top_position,
		col = get_left_position,
		anchor = "NW",
		top_down = true,
	},
	["top-center"] = {
		row = get_top_position,
		col = get_center_position,
		anchor = "NW",
		top_down = true,
	},
	["top-right"] = {
		row = get_top_position,
		col = get_right_position,
		anchor = "NE",
		top_down = true,
	},
}

Util.levels = function(level)
	local config = require("notif.config").get()
	if level == 0 then
		return {
			name = "TRACE",
			color = config.colors.trace,
			icon = config.icons.trace,
		}
	elseif level == 1 then
		return {
			name = "DEBUG",
			color = config.colors.debug,
			icon = config.icons.debug,
		}
	elseif level == 2 then
		return {
			name = "INFO",
			color = config.colors.info,
			icon = config.icons.info,
		}
	elseif level == 3 then
		return {
			name = "WARN",
			color = config.colors.warn,
			icon = config.icons.warn,
		}
	elseif level == 4 then
		return {
			name = "ERROR",
			color = config.colors.error,
			icon = config.icons.error,
		}
	end
end

Util.direction = function()
	local config = require("notif.config").get()
	return Util.positions[config.win_options.position].top_down and 1 or -1
end

Util.split_string_into_lines = function(long_string, max_width, border)
	local borders = border and 2 or 0
	local lines = {}
	local padding = " "
	local current_line = ""

	local function is_word_fitting(word)
		local line_length_with_word = current_line:len() + word:len() + borders
		return line_length_with_word <= max_width
	end

	local function add_line_to_result()
		table.insert(lines, current_line .. padding)
	end

	for word in long_string:gmatch("%S+") do
		if is_word_fitting(word) then
			current_line = current_line .. padding .. word
		else
			add_line_to_result()
			current_line = padding .. word
		end
	end

	add_line_to_result()
	return lines
end

Util.get_row_and_col = function()
	local config = require("notif.config").get()
	local margin = config.win_options.margin

	return Util.positions[config.win_options.position].row(margin.top, margin.bottom),
		Util.positions[config.win_options.position].col(margin.left, margin.right)
end

return Util
