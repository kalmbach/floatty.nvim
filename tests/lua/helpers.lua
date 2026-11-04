local M = {}

function M.float_count()
  local count = 0
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(w).relative ~= '' then
      count = count + 1
    end
  end

  return count
end

function M.term_count()
  local count = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buftype == 'terminal' then
      count = count + 1
    end
  end

  return count
end

return M
