local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
vim.opt.runtimepath:prepend(root .. '/tests')
vim.cmd 'runtime plugin/floatty.lua'

assert(vim.fn.exists ':Floatty' == 2, ':Floatty was not registered')

local floatty = require('floatty')
local helpers = require('helpers')

vim.o.shell = 'sh'

local function test(command, hide)
  floatty.open()
  assert(vim.wait(1000, function() return vim.bo.buftype == 'terminal' end), 'terminal did not start')
  local buffer = vim.api.nvim_get_current_buf()
  local channel = vim.bo[buffer].channel

  if hide then floatty.hide() end
  vim.fn.chansend(channel, command)
  assert(vim.wait(1000, function() return not vim.api.nvim_buf_is_valid(buffer) end), 'terminal did not exit')
  assert(helpers.float_count() == 0, 'the shell exit did not close the floating window')

  floatty.toggle()
  local new_buffer = vim.api.nvim_get_current_buf()
  local new_channel = vim.bo[new_buffer].channel

  assert(helpers.float_count() == 1, 'the float did not open')
  assert(new_buffer ~= buffer, 'it did not open a new buffer')
  assert(new_channel ~= channel, 'it did not create a new channel')
  assert(vim.fn.jobwait({ channel }, 0)[1] == -3, 'terminal is still running after shell exit')
  assert(vim.fn.jobwait({ new_channel }, 0)[1] == -1, 'terminal is not running after toggle')
end

test('exit\n', false)
test('exit\n', true)
test('exit 3\n', false)

print 'floatty.nvim exit test passed'
vim.cmd 'qa!'
