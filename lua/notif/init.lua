local message = require("notif.message")
local M = {}

M.setup = function(user_config)
	local lsp = require("notif.lsp")
	local config = require("notif.config").set(user_config or {})

	if config.lsp.progress then
		lsp.add_lsp_progress()
	end

	vim.notify = M.notify
end

M.notify = function(text, level, opts)
	local config = require("notif.config").get()
	opts = opts or {}

	if type(level) == "string" then
		level = vim.log.levels[level:upper()]
	else
		level = level or vim.log.levels.INFO
	end

	if level >= config.min_level then
		message.add_message(text, opts.title, opts.icon, level)
	end
end

return M
