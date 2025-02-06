local C = {}

local ns_id = vim.api.nvim_create_namespace("notif")

local options = {
	max_width = 60,
	life_time = 5000,
	ns_id = ns_id,
	min_level = vim.log.levels.INFO,
	colors = {
		trace = "DiagnosticOk",
		debug = "DiagnosticHint",
		info = "DiagnosticInfo",
		warn = "DiagnosticWarn",
		error = "DiagnosticError",
	},
	icons = {
		trace = "󱨧",
		debug = "󰘥",
		info = "󱨧",
		warn = "",
		error = "󰅚",
	},
	win_options = {
		relative = "editor",
		position = "bottom-right",
		border = "rounded",
		margin = {
			top = 0,
			right = 0,
			bottom = 0,
			left = 0,
		},
	},
	lsp = {
		icon = "󰀴",
		progress = {
			enable = true,
		},
	},
}

C.set = function(user_config)
	options = vim.tbl_deep_extend("force", options, user_config or {})
	return options
end

C.get = function()
	return options
end

return C
