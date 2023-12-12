local message = require("notif.message")
local config = require("notif.config")
local M = {}
M.lsp_history = {}

local new_task = function(token, client)
  return {
    id = token,
    client = client,
    title = nil,
    message = nil,
    percentage = nil,
    job = nil
  }
end

M.add_lsp_progress = function()
  local lspStorage = {}

  vim.lsp.handlers["$/progress"] = function(_, params, info)
    local token = params.token
    local value = params.value
    local client = vim.lsp.get_client_by_id(info.client_id)

    if not token then return end
    if not client then return end

    if lspStorage[token] == nil then
      lspStorage[token] = new_task(token, client.name)
    end

    local progress = lspStorage[token]

    if value.kind == "begin" then
      progress.title = value.title
      progress.message = value.message
    elseif value.kind == "report" then
      if value.percentage then
        progress.percentage = value.percentage
      end
      if value.message then
        progress.message = value.message
      end
    elseif value.kind == "end" then
      if progress.percentage then
        progress.percentage = 100
      end
      if progress.message then
        progress.message = value.message
      end
    end

    if (progress.message and progress.title) then
      progress.message = string.format("%s %s", progress.title, progress.message)
    else
      progress.message = progress.title
    end

    local created = message.add_message(
      progress.message,
      client.name,
      config.lsp.icon,
      vim.log.levels.INFO,
      token,
      10000
    )

    table.insert(M.lsp_history, created)
  end
end

return M
