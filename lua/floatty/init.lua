local M = {}

local defaults = {
  keymaps = {
    toggle = '<M-t>',
  },
  window = {
    width = 0.75,
    height = 0.75,
    border = 'rounded',
    title = 'floatty',
    title_pos = 'center',
  },
}

local config = vim.deepcopy(defaults)
local state = {
  buf = nil,
}

local function terminal_buf()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    return state.buf
  end
end

local function terminal_win()
  if not terminal_buf() then return end
  for _, w in ipairs(vim.fn.win_findbuf(state.buf)) do
    if vim.api.nvim_win_get_tabpage(w) == vim.api.nvim_get_current_tabpage() then
      return w
    end
  end
end

local function float_config()
  local width = math.floor(vim.o.columns * config.window.width)
  local height = math.floor(vim.o.lines * config.window.height)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  return {
    relative = 'editor',
    style = 'minimal',
    width = width,
    height = height,
    col = col,
    row = row,
    border = config.window.border,
    title = config.window.title,
    title_pos = config.window.title_pos,
  }
end

local function clear_state()
  M.hide()
  if terminal_buf() then vim.api.nvim_buf_delete(state.buf, { force = true }) end
  state.buf = nil
end

function M.hide()
  local win = terminal_win()
  if not win then return end

  vim.api.nvim_win_close(win, true)
end

local function open_float(buf)
  return vim.api.nvim_open_win(buf, true, float_config())
end

function M.open()
  local win = terminal_win()

  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd 'startinsert'
    return
  end

  if terminal_buf() then
    open_float(state.buf)
    vim.cmd 'startinsert'
    return
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = 'hide'
  open_float(state.buf)

  local buf = state.buf
  local ok, job = pcall(
    vim.fn.jobstart,
    -- use split to pass along the shell arguments
    vim.fn.split(vim.o.shell),
    {
      term = true,
      cwd = vim.fn.getcwd(),
      on_exit = function()
        vim.schedule(function()
          if state.buf == buf then clear_state() end
        end)
      end,
    }
  )

  if not ok then
    clear_state()
    vim.notify('floatty.nvim: failed to start ' .. vim.o.shell .. ': ' .. job, vim.log.levels.ERROR)
    return
  end

  if job <= 0 then
    clear_state()
    vim.notify('floatty.nvim: failed to start ' .. vim.o.shell, vim.log.levels.ERROR)
    return
  end

  vim.cmd 'startinsert'
end

function M.toggle()
  if terminal_win() then
    M.hide()
  else
    M.open()
  end
end

local group = vim.api.nvim_create_augroup('floatty', { clear = true })
vim.api.nvim_create_autocmd('VimResized', {
  group = group,
  callback = function()
    local buffer = terminal_buf()

    if not buffer then return end

    for _, w in ipairs(vim.fn.win_findbuf(buffer)) do
      if vim.api.nvim_win_get_config(w).relative == 'editor' then
        vim.api.nvim_win_set_config(w, float_config())
      end
    end
  end,
  desc = 'Resize floatty terminal',
})

function M.setup(opts)
  config = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})

  if config.keymaps.toggle then
    vim.keymap.set({ 'n', 't' }, config.keymaps.toggle, M.toggle, {
      desc = 'Floating terminal',
    })
  end
end

return M
