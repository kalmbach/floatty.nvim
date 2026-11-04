local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local floatty = require('floatty')
local helpers = require('helpers')

local function reset()
  floatty.hide()
  vim.cmd 'silent only'
  vim.cmd 'enew!'
end

local left_split
local right_split
local terminal

vim.o.shell = 'sh'

-- hide returns to the window floatty was opened from
reset()
vim.cmd 'vsplit'
left_split = vim.api.nvim_get_current_win()
vim.cmd 'wincmd l'
right_split = vim.api.nvim_get_current_win()
assert(left_split ~= right_split, 'first layout setup failed')

vim.api.nvim_set_current_win(left_split)
floatty.open()
floatty.hide()

assert(vim.api.nvim_get_current_win() == left_split, 'hide did not send focus back to previous window')

-- hide returns to the last visited window
vim.api.nvim_set_current_win(left_split)
floatty.open()
terminal = vim.api.nvim_get_current_win()

vim.api.nvim_set_current_win(right_split)
vim.api.nvim_set_current_win(terminal)
floatty.hide()

assert(vim.api.nvim_get_current_win() == right_split, 'hide did not send focus back to the last visited window')

-- hide returns to the normal window if previous was closed
reset()
vim.cmd 'vsplit'
left_split = vim.api.nvim_get_current_win()
vim.cmd 'wincmd l'
right_split = vim.api.nvim_get_current_win()
assert(left_split ~= right_split, 'second layout setup failed')

vim.api.nvim_set_current_win(left_split)
floatty.open()
assert(helpers.float_count() == 1, 'the floating window was not opened')

vim.api.nvim_win_close(left_split, true)
floatty.hide()
assert(helpers.float_count() == 0, 'the floating window was not closed')
assert(vim.api.nvim_get_current_win() == right_split, 'hide did not land in the remaining window')

print 'floatty.nvim focus test passed'
vim.cmd 'qa!'
