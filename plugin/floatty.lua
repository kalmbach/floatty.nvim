if vim.g.loaded_floatty_nvim then return end
vim.g.loaded_floatty_nvim = true

local actions = {
  open = true,
  hide = true,
  toggle = true,
}

vim.api.nvim_create_user_command('Floatty', function(opts)
  local action = opts.args ~= '' and opts.args or 'open'
  if not actions[action] then
    vim.notify('floatty.nvim: unknown action: ' .. action, vim.log.levels.ERROR)
    return
  end

  require('floatty')[action]()
end, {
  nargs = '?',
  complete = function()
    return { 'open', 'hide', 'toggle' }
  end,
  desc = 'Open, hide or toggle the floating terminal',
})
