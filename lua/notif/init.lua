local config = require("notif.config")
local lsp = require("notif.lsp")
local message = require("notif.message")
local M = {}

M.notify = function(text, level, opts)
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

M.setup = function(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})

  vim.notify = M.notify

  if config.lsp.progress then lsp.add_lsp_progress() end
end

return M
