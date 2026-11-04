local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local floatty = require('floatty')
local helpers = require('helpers')

local buffer
local channel
local new_buffer

vim.o.shell = 'sh'

-- closing the buffer while open
floatty.open()
assert(vim.wait(1000, function() return vim.bo.buftype == 'terminal' end), 'terminal did not start')

buffer = vim.api.nvim_get_current_buf()
vim.cmd 'bd!'

assert(helpers.float_count() == 0, 'terminal float was not closed')
assert(helpers.term_count() == 0, 'terminal buffer was not closed')
assert(not vim.api.nvim_buf_is_valid(buffer), 'terminal buffer is still valid')

vim.wait(300, function() return false end)
floatty.toggle()
new_buffer = vim.api.nvim_get_current_buf()

assert(helpers.float_count() == 1, 'a new terminal float did not open on toggle')
assert(helpers.term_count() == 1, 'a new terminal buffer was not created on toggle')
assert(buffer ~= new_buffer, 'a new terminal buffer was not created after the old one was closed')

-- closing the buffer while hidden
floatty.open()
buffer = vim.api.nvim_get_current_buf()

floatty.hide()
vim.cmd('bd! ' .. buffer)

assert(helpers.float_count() == 0, 'terminal float was not closed')
assert(helpers.term_count() == 0, 'terminal buffer was not closed')
assert(not vim.api.nvim_buf_is_valid(buffer), 'terminal buffer is still valid')

vim.wait(300, function() return false end)
floatty.toggle()
new_buffer = vim.api.nvim_get_current_buf()

assert(helpers.float_count() == 1, 'a new terminal float did not open on toggle')
assert(helpers.term_count() == 1, 'a new terminal buffer was not created on toggle')
assert(buffer ~= new_buffer, 'a new terminal buffer was not created after the old one was closed')

-- closing the buffer then immediate toggle
floatty.open()
buffer = vim.api.nvim_get_current_buf()

floatty.hide()
vim.cmd('bd! ' .. buffer)
floatty.toggle()

assert(helpers.float_count() == 1, 'a terminal float does not exist after immediate toggle')
assert(helpers.term_count() == 1, 'a terminal buffer does not exist after immediate toggle')
assert(buffer ~= vim.api.nvim_get_current_buf(), 'a new terminal buffer was not created on immediate toggle')

vim.wait(300, function() return false end)

assert(helpers.float_count() == 1, 'terminal float does not exist after waiting')
assert(helpers.term_count() == 1, 'terminal buffer does not exist after waiting')

-- quitting inside the float
buffer = vim.api.nvim_get_current_buf()
floatty.hide()
vim.api.nvim_buf_delete(buffer, { force = true })
vim.wait(300, function() return false end)

floatty.open()
buffer = vim.api.nvim_get_current_buf()
channel = vim.bo[buffer].channel
vim.cmd 'q'

assert(helpers.float_count() == 0, 'terminal float still open after quitting')
assert(helpers.term_count() == 1, 'terminal buffer was closed after quitting')
assert(vim.api.nvim_buf_is_valid(buffer), 'terminal buffer no longer valid after quitting')
assert(vim.fn.jobwait({ channel }, 0)[1] == -1, 'job is not running after quitting')

floatty.toggle()

assert(helpers.float_count() == 1, 'terminal float does not open on toggle')
assert(vim.api.nvim_get_current_buf() == buffer, 'a new terminal buffer was created after toggle')
assert(vim.fn.jobwait({ channel }, 0)[1] == -1, 'job is not running after toggle')

print 'floatty.nvim wipe test passed'
vim.cmd 'qa!'
