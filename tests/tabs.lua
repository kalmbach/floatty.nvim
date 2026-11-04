local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local floatty = require('floatty')
local helpers = require('helpers')

vim.o.shell = 'sh'
vim.o.columns = 200
vim.o.lines = 100

local function computed_size(base)
  return math.floor(base * 0.75)
end

local function computed_center(base, size)
  return math.floor((base - size) / 2)
end

local tab
local buffer
local channel
local first_win
local second_win

floatty.open()
assert(vim.wait(1000, function() return vim.bo.buftype == 'terminal' end), 'terminal did not start')
buffer = vim.api.nvim_get_current_buf()
first_win = vim.api.nvim_get_current_win()

vim.cmd 'wincmd p'

vim.cmd 'tabnew'
tab = vim.api.nvim_get_current_tabpage()
floatty.toggle()
second_win = vim.api.nvim_get_current_win()

assert(vim.api.nvim_get_current_tabpage() == tab, 'current tab changed after toggling the terminal')
assert(vim.api.nvim_get_current_buf() == buffer, 'toggle in second tab did not show the terminal buffer')
assert(second_win ~= first_win, 'toggle in second tab did not open a new terminal window')
assert(helpers.float_count() == 2, 'toggle in second tab did not open a second float')
assert(helpers.term_count() == 1, 'toggle in second tab did not reuse terminal buffer')

vim.o.columns = 160
vim.o.lines = 80
vim.api.nvim_exec_autocmds('VimResized', {})

local config = vim.api.nvim_win_get_config(second_win)
assert(config.relative == 'editor', 'terminal is not a float')
assert(config.width == computed_size(vim.o.columns), 'second window has not the expected width')
assert(config.height == computed_size(vim.o.lines), 'second window has not the expected height')
assert(config.col == computed_center(vim.o.columns, config.width), 'second window was not horizontally centered')
assert(config.row == computed_center(vim.o.lines, config.height), 'second window was not vertically centered')

config = vim.api.nvim_win_get_config(first_win)
assert(config.relative == 'editor', 'terminal is not a float')
assert(config.width == computed_size(vim.o.columns), 'first window has not the expected width')
assert(config.height == computed_size(vim.o.lines), 'first window has not the expected height')
assert(config.col == computed_center(vim.o.columns, config.width), 'first window was not horizontally centered')
assert(config.row == computed_center(vim.o.lines, config.height), 'first window was not vertically centered')

floatty.toggle()
assert(helpers.float_count() == 1, 'toggle again did not close second window')
assert(not vim.api.nvim_win_is_valid(second_win), 'toggle did not close terminal window in second tab')

floatty.toggle()
assert(helpers.float_count() == 2, 'toggle again did not open the second window')

channel = vim.bo[buffer].channel
vim.fn.chansend(channel, 'exit\n')

assert(vim.wait(1000, function() return not vim.api.nvim_buf_is_valid(buffer) end), 'terminal did not exit')
assert(helpers.float_count() == 0, 'terminal floats were not closed')
assert(helpers.term_count() == 0, 'terminal buffer was not closed')

print 'floatty.nvim tabs test passed'
vim.cmd 'qa!'
