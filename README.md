# current_coder.nvim

Copy the current file into an adjacent (or the next) window, preserving the
cursor position. Handy for split-based workflows where you want the same buffer
open side by side without re-typing the path.

## Features

- Copy the current file to the left / right / up / down / next window
- Keeps the cursor at the same position in the copied window
- User commands and configurable keymaps
- Optional silent mode

## Install (lazy.nvim)

```lua
{
  "mr-scrpt/current_coder.nvim",
  config = function()
    require("current_coder").setup({
      keymaps = {
        copy_to_next = "<leader>oo",
        copy_to_left = "<leader>oh",
        copy_to_right = "<leader>ol",
      },
      silent = false,
      create_commands = true,
    })
  end,
}
```

## Commands

| Command            | Action                          |
| ------------------ | ------------------------------- |
| `:CopyToNextWindow`| Copy file to the next window    |
| `:CopyToLeft`      | Copy file to the left window    |
| `:CopyToRight`     | Copy file to the right window   |
| `:CopyToUp`        | Copy file to the upper window   |
| `:CopyToDown`      | Copy file to the lower window   |
| `:WindowsInfo`     | List all windows and buffers    |

## Configuration

```lua
require("current_coder").setup({
  keymaps = {
    copy_to_next = "<leader>oc",
    copy_to_left = "<leader>oh",
    copy_to_right = "<leader>ol",
  },
  silent = false,         -- suppress notifications
  create_commands = true, -- create the :CopyTo* user commands
})
```

## License

MIT
