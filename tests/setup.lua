local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local floatty = require('floatty')

local win
local config

vim.o.columns = 80

-- works without setup()
vim.cmd 'Floatty open'
win = vim.api.nvim_get_current_win()
assert(vim.wait(1000, function() return vim.bo.buftype == 'terminal' end), 'terminal did not start')
assert(vim.api.nvim_win_get_config(win).relative == 'editor', 'floatty did not open in a floating window')

-- keymaps
floatty.setup({ keymaps = { toggle = false } })
assert(vim.fn.maparg('<M-t>', 'n') == '', 'toggle="false" sets <M-t> keymap in normal mode')
assert(vim.fn.maparg('<M-t>', 't') == '', 'toggle="false" sets <M-t> keymap in terminal mode')

floatty.setup()
assert(vim.fn.maparg('<M-t>', 'n') ~= '', 'toggle keymap was not installed')
assert(vim.fn.maparg('<M-t>', 't') ~= '', 'toggle terminal keymap was not installed')

-- defaults
vim.cmd 'Floatty hide'
floatty.setup({ window = { width = 0.5 } })
vim.cmd 'Floatty open'
win = vim.api.nvim_get_current_win()
config = vim.api.nvim_win_get_config(win)
assert(config.width == 40, 'window width was not configured')
assert(config.title[1][1] == 'floatty', 'window default title was overwritten')

print 'floatty.nvim setup test passed'
vim.cmd 'qa!'
