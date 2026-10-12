# current_coder.nvim

Show the current file in an adjacent (or the next) window, keeping the cursor
and scroll position, and move there. Handy for split-based workflows where you
want the same buffer side by side without re-typing the path.

With a single editor window a split is opened on the requested side. With two
or more editor windows no new window is created: the file goes into the
neighbour, or you get a warning if there is none on that side. File trees,
quickfix, terminals and floating windows are never used as targets.

## Features

- Show the current file in the left / right / up / down / next window
- Opens a split when there is only one editor window, never a third one
- Keeps the cursor and the view (scroll position)
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
