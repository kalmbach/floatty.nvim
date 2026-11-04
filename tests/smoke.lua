local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local floatty = require('floatty')
local helpers = require('helpers')

vim.o.columns = 100
vim.o.lines = 50
vim.o.shell = 'sh'

local editor = vim.api.nvim_get_current_win()

floatty.open()
assert(vim.wait(1000, function() return vim.bo.buftype == 'terminal' end), 'terminal did not start')
local window = vim.api.nvim_get_current_win()
local buffer = vim.api.nvim_get_current_buf()
local channel = vim.bo[buffer].channel
local config = vim.api.nvim_win_get_config(window)
local width = math.floor(vim.o.columns * 0.75)
local height = math.floor(vim.o.lines * 0.75)

assert(config.relative == 'editor', 'terminal window is not a float')
assert(config.width == width, 'terminal width was not set')
assert(config.height == height, 'terminal height was not set')
assert(config.col == math.floor((vim.o.columns - width) / 2), 'terminal was not horizontally centered')
assert(config.row == math.floor((vim.o.lines - height) / 2), 'terminal was not vertically centered')
assert(config.title[1][1] == 'floatty', 'terminal title was not set')

assert(helpers.float_count() == 1, 'there is not just one floating window')
assert(helpers.term_count() == 1, 'there is not just one terminal buffer')

floatty.hide()
assert(editor == vim.api.nvim_get_current_win(), 'focus did not return to main window')
assert(helpers.float_count() == 0, 'terminal window did not hide')
assert(helpers.term_count() == 1, 'terminal buffer was deleted after hide')
assert(vim.fn.jobwait({ channel }, 0)[1] == -1, 'terminal is not running after hide')

floatty.open()
window = vim.api.nvim_get_current_win()
assert(helpers.float_count() == 1, 'terminal window did not open')
assert(buffer == vim.api.nvim_get_current_buf(), 'new terminal buffer was created on open')

vim.cmd 'wincmd p'
floatty.open()
assert(helpers.float_count() == 1, 're-opened a new terminal window')
assert(helpers.term_count() == 1, 're-opened a new terminal buffer')
assert(buffer == vim.api.nvim_get_current_buf(), 'new terminal buffer was created on re-open')
assert(window == vim.api.nvim_get_current_win(), 'new terminal window was created on re-open')

floatty.hide()
floatty.hide()

print 'floatty.nvim smoke test passed'
vim.cmd 'qa!'
