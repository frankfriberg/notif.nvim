local config = require("notif.config")
M = {}

M.positions = {
  ["bottom-left"] = {
    row = vim.o.lines - vim.o.cmdheight - 1,
    col = 4,
    anchor = "SW",
    top_down = false
  },
  ["bottom-center"] = {
    row = vim.o.lines - vim.o.cmdheight - 1,
    col = (vim.o.columns - config.max_width) / 2,
    anchor = "SW",
    top_down = false
  },
  ["bottom-right"] = {
    row = vim.o.lines - vim.o.cmdheight - 1,
    col = vim.o.columns,
    anchor = "SE",
    top_down = false
  },
  ["top-left"] = {
    row = 0,
    col = 4,
    anchor = "NW",
    top_down = true
  },
  ["top-center"] = {
    row = 0,
    col = (vim.o.columns - config.max_width) / 2,
    anchor = "NW",
    top_down = true
  },
  ["top-right"] = {
    row = 0,
    col = vim.o.columns - config.max_width - 4,
    anchor = "NE",
    top_down = true
  }
}

M.levels = {
  [0] = {
    name = 'TRACE',
    color = config.colors.trace,
    icon = config.icons.trace,
  },
  [1] = {
    name = 'DEBUG',
    color = config.colors.debug,
    icon = config.icons.debug,
  },
  [2] = {
    name = 'INFO',
    color = config.colors.info,
    icon = config.icons.info,
  },
  [3] = {
    name = 'WARN',
    color = config.colors.warn,
    icon = config.icons.warn,
  },
  [4] = {
    name = 'ERROR',
    color = config.colors.error,
    icon = config.icons.error,
  },
}

M.adjustment = M.positions[config.win_options.position].top_down and 1 or -1

M.split_string_into_lines = function(longString)
  local max_width = config.max_width
  local lines = {}
  local currentLine = ""
  for word in longString:gmatch("%S+") do
    if string.len(currentLine) + string.len(word) + 2 <= max_width then
      currentLine = currentLine .. " " .. word
    else
      table.insert(lines, currentLine)
      currentLine = " " .. word
    end
  end
  table.insert(lines, currentLine)
  return lines
end

return M
