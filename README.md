# floatty.nvim

[![Tests](https://github.com/kalmbach/floatty.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/kalmbach/floatty.nvim/actions/workflows/test.yml)

**One floating terminal.** A small Neovim plugin that runs your shell in a
centered floating window. You can show and hide the window as many times
as you want, the shell keeps running in the background.

```
┌──────────────────────────────────────────┐
│   ╭──────────── floatty ────────────╮    │
│   │ $ make test                     │    │
│   │                                 │    │
│   │                                 │    │
│   ╰─────────────────────────────────╯    │
└──────────────────────────────────────────┘
```

## Requirements

- Neovim 0.11 or newer

## Installation

### `vim.pack`

```lua
vim.pack.add { 'https://github.com/kalmbach/floatty.nvim' }

require('floatty').setup()
```

### lazy.nvim

```lua
{
  'kalmbach/floatty.nvim',
  config = function()
    require('floatty').setup()
  end,
}
```

## Configuration

`setup()` takes a table that is merged with the defaults. These are the
defaults:

```lua
require('floatty').setup {
  keymaps = {
    toggle = '<M-t>',
  },
  window = {
    width = 0.75,  -- fraction of the editor width
    height = 0.75, -- fraction of the editor height
    border = 'rounded',
    title = 'floatty',
    title_pos = 'center',
  },
}
```

- The terminal runs your `shell` option, in Neovim's current working
  directory.
- `window.width` and `window.height` are fractions of `columns` and
  `lines`. The window is resized and re-centered when Neovim is resized.
- `border`, `title` and `title_pos` are passed to `nvim_open_win()`, see
  `:help nvim_open_win()` for the accepted values.
- Set `keymaps.toggle` to `false` to disable it.

## Default keymaps

| Keys | Mode | What it does |
| --- | --- | --- |
| `<M-t>` | normal and terminal | Toggle the terminal. From inside the terminal, it hides it without stopping the shell |
| `<C-\><C-n>` | terminal | Leave terminal mode (Neovim builtin, see `:help terminal-input`) |

`<M-t>` is taken from the shell while you are in the terminal. In bash
and zsh that is `transpose-words`, and fzf's shell integration uses it
for its file picker. Pick another key if you need those.

## Behavior

- **One terminal per Neovim.** There is a single shell, shared by the
  whole session.
- **Hiding keeps the shell running.** The next toggle shows the same
  session, with its scrollback.
- **Opening always puts you in terminal mode**, ready to type.
- **When the shell exits**, the window closes and the buffer is removed.
  The next toggle starts a fresh shell.
- **Quitting Neovim kills the shell**, without asking, even if a command
  is still running in it.
- **Hiding returns to the last visited window**, Neovim's default when a
  floating window closes.

## Commands

```vim
:Floatty          " Open the terminal (same as :Floatty open)
:Floatty open     " Open or focus it
:Floatty hide     " Hide it without stopping the shell
:Floatty toggle   " Toggle it
```

## Lua API

```lua
local floatty = require 'floatty'

floatty.open()
floatty.hide()
floatty.toggle()
```

## Testing

The tests run in headless Neovim with no user config:

```sh
make test                                      # all tests
nvim --headless -u NONE -l tests/smoke.lua     # one test
```

## License

MIT. See [LICENSE](LICENSE).
