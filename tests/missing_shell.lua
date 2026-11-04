local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local floatty = require('floatty')
local helpers = require('helpers')

vim.o.shell = 'no-shell-for-you'

local calls = {}
local original = vim.notify
vim.notify = function(msg, level, _)
  table.insert(calls, { msg = msg, level = level })
end

local buffers = #vim.api.nvim_list_bufs()
local win = vim.api.nvim_get_current_win()
local expected_error = 'floatty.nvim: failed to start no-shell-for-you'
local assert_attempt = function(n)
  assert(helpers.float_count() == 0, 'a floating window was left open')
  assert(#vim.api.nvim_list_bufs() == buffers, 'a floating buffer was left open')
  assert(vim.api.nvim_get_current_win() == win, 'focus did not go back to original window')

  assert(#calls == n, 'expected ' .. n .. ' notification(s), got ' .. #calls)
  assert(calls[n].level == vim.log.levels.ERROR, 'notification was not ERROR level')
  assert(string.find(calls[n].msg, expected_error, 1, true) == 1, 'unexpected error msg was ' .. calls[n].msg)
end


floatty.open()
assert_attempt(1)
floatty.toggle()
assert_attempt(2)

vim.o.shell = 'sh'
floatty.open()
assert(helpers.float_count() == 1, 'floating window did not open')
assert(vim.bo[vim.api.nvim_get_current_buf()].buftype == 'terminal', 'floating terminal did not open')

vim.notify = original
print 'floatty.nvim missing shell test passed'
vim.cmd 'qa!'
