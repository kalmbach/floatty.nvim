local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local floatty = require('floatty')
local helpers = require('helpers')

local function computed_size(base)
  return math.floor(base * 0.75)
end

local function computed_center(base, size)
  return math.floor((base - size) / 2)
end

vim.o.shell = 'sh'
vim.o.columns = 200
vim.o.lines = 100

floatty.open()
assert(vim.wait(1000, function() return vim.bo.buftype == 'terminal' end), 'terminal did not start')

local config = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win())
assert(config.relative == 'editor', 'terminal is not a float')
assert(config.width == computed_size(vim.o.columns), 'terminal has not the expected width')
assert(config.height == computed_size(vim.o.lines), 'terminal has not the expected height')
assert(config.col == computed_center(vim.o.columns, config.width), 'terminal was not horizontally centered')
assert(config.row == computed_center(vim.o.lines, config.height), 'terminal was not vertically centered')

vim.o.columns = 160
vim.o.lines = 80
vim.api.nvim_exec_autocmds('VimResized', {})
config = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win())
assert(config.width == computed_size(vim.o.columns), 'terminal has not the expected width after resize')
assert(config.height == computed_size(vim.o.lines), 'terminal has not the expected height after resize')
assert(config.col == computed_center(vim.o.columns, config.width), 'terminal was not horizontally centered after resize')
assert(config.row == computed_center(vim.o.lines, config.height), 'terminal was not vertically centered after resize')

floatty.hide()
vim.o.columns = 120
vim.o.lines = 60
vim.v.errmsg = '' -- catch any errors while hidden
vim.api.nvim_exec_autocmds('VimResized', {})
assert(vim.v.errmsg == '', 'terminal error after resize while hidden: ' .. vim.v.errmsg)
assert(helpers.float_count() == 0, 'terminal float did not remain hidden after resize')

floatty.open()
config = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win())
assert(config.width == computed_size(vim.o.columns), 'terminal has not the expected width after resize while hidden')
assert(config.height == computed_size(vim.o.lines), 'terminal has not the expected height after resize while hidden')
assert(config.col == computed_center(vim.o.columns, config.width), 'terminal was not horizontally centered after resize while hidden')
assert(config.row == computed_center(vim.o.lines, config.height), 'terminal was not vertically centered after resize while hidden')

print 'floatty.nvim resize test passed'
vim.cmd 'qa!'
