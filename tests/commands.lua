local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local helpers = require('helpers')

vim.o.shell = 'sh'

vim.cmd 'Floatty'
local floatty = vim.api.nvim_get_current_buf()
assert(vim.wait(1000, function() return vim.bo.buftype == 'terminal' end), 'floating terminal did not start')
assert(helpers.float_count() == 1, 'floating window did not open on default action')
assert(helpers.term_count() == 1, 'floating terminal did not open on default action')

vim.cmd 'Floatty hide'
assert(helpers.float_count() == 0, 'floating window did not close on hide')
assert(helpers.term_count() == 1, 'floating terminal was deleted on hide')

vim.cmd 'Floatty open'
assert(helpers.float_count() == 1, 'floating window did not open')
assert(helpers.term_count() == 1, 'floating terminal did not open')
assert(floatty == vim.api.nvim_get_current_buf(), 'floating buffer was not reused on open')

vim.cmd 'Floatty toggle'
assert(helpers.float_count() == 0, 'floating window did not close on toggle(hide)')
assert(helpers.term_count() == 1, 'floating terminal was deleted on toggle(hide)')

vim.cmd 'Floatty toggle'
assert(helpers.float_count() == 1, 'floating window did not open on toggle(open)')
assert(helpers.term_count() == 1, 'floating terminal was deleted on toggle(open)')
assert(floatty == vim.api.nvim_get_current_buf(), 'floating buffer was not reused on toggle')

local calls = {}
local expected_error = 'floatty.nvim: unknown action: bogus'
local original = vim.notify
vim.notify = function(msg, level, _)
  table.insert(calls, { msg = msg, level = level })
end
vim.cmd 'Floatty bogus'
assert(#calls == 1, 'expected 1 notification, got ' .. #calls)
assert(calls[1].level == vim.log.levels.ERROR, 'notification was not ERROR level')
assert(calls[1].msg == expected_error, 'unexpected error msg was ' .. calls[1].msg)
assert(helpers.float_count() == 1, 'floating window was closed after error')
assert(helpers.term_count() == 1, 'floating terminal was closed after error')
assert(floatty == vim.api.nvim_get_current_buf(), 'floating buffer lost focus after error')

vim.notify = original
print 'floatty.nvim commands test passed'
vim.cmd 'qa!'
