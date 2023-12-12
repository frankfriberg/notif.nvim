local ns_id = vim.api.nvim_create_namespace("notif")
if vim.api.nvim_win_set_hl_ns then
  vim.api.nvim_set_hl(ns_id, "NormalFloat", { bg = "NONE" })
  vim.api.nvim_set_hl(ns_id, "FloatBorder", { bg = "NONE" })
end

local config = {
  max_width = 40,
  life_time = 5000,
  ns_id = ns_id,
  min_level = vim.log.levels.INFO,
  colors = {
    error = "ErrorFloat",
    warn = "WarningFloat",
    info = "InfoFloat",
    debug = "Comment",
    trace = "Comment",
  },
  icons = {
    hint = "󰘥",
    info = "󱨧",
    warn = "󰗖",
    error = "󰅚",
    trace = "",
  },
  win_options = {
    relative = "editor",
    position = "bottom-right",
    border = "rounded"
  },
  lsp = {
    icon = "󰀴",
    progress = {
      enable = true,
    },
  }
}

return config
