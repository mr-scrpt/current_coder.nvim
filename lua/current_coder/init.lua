local M = {}

local default_config = {
	keymaps = {
		copy_to_next = "<leader>oc",
		copy_to_left = "<leader>oh",
		copy_to_right = "<leader>ol",
	},
	silent = false,
	create_commands = true,
}

local config = vim.deepcopy(default_config)

-- split that puts the new window on the requested side
local split_cmd = {
	h = "leftabove vsplit",
	l = "rightbelow vsplit",
	k = "leftabove split",
	j = "rightbelow split",
}
local side_name = { h = "left", l = "right", k = "upper", j = "lower", next = "next" }

local function notify(msg, level)
	if not config.silent then
		vim.notify(msg, level or vim.log.levels.INFO, { title = "current_coder" })
	end
end

-- An editor window: a normal (not floating) window showing a file buffer.
-- File trees, quickfix, terminals and floats are never targets.
local function is_editor(win)
	if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
		return false
	end
	return vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
end

local function editor_windows()
	return vim.tbl_filter(is_editor, vim.api.nvim_tabpage_list_wins(0))
end

local function find_target(src, direction)
	if direction == "next" then
		local wins = editor_windows()
		for i, win in ipairs(wins) do
			if win == src then
				local next_win = wins[i % #wins + 1]
				return next_win ~= src and next_win or nil
			end
		end
		return nil
	end
	local win = vim.fn.win_getid(vim.fn.winnr(direction))
	return (win ~= src and is_editor(win)) and win or nil
end

--- Show the current buffer, with the same cursor and scroll position, in the
--- window on the given side ("h", "j", "k", "l") or in the next editor window
--- ("next"), and move there. When the current window is the only editor
--- window, a split is opened on that side ("next" opens to the right). When
--- there are two or more editor windows, no new window is ever created.
---@param direction "h"|"j"|"k"|"l"|"next"
---@return boolean
function M.copy_to(direction)
	local src = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
		notify("Current buffer is not a file", vim.log.levels.WARN)
		return false
	end
	local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")

	local target = find_target(src, direction)
	if not target then
		if #editor_windows() > 1 then
			notify(("No window on the %s side"):format(side_name[direction]), vim.log.levels.WARN)
			return false
		end
		-- a split shows the same buffer with the same cursor and view
		vim.cmd(split_cmd[direction] or split_cmd.l)
		notify(("'%s' opened in a new window"):format(name))
		return true
	end

	local view = vim.fn.winsaveview()
	vim.api.nvim_win_set_buf(target, buf)
	vim.api.nvim_set_current_win(target)
	vim.fn.winrestview(view)
	notify(("'%s' opened in the %s window"):format(name, side_name[direction]))
	return true
end

M.copy_to_next = function()
	return M.copy_to("next")
end
M.copy_to_left = function()
	return M.copy_to("h")
end
M.copy_to_right = function()
	return M.copy_to("l")
end
M.copy_to_up = function()
	return M.copy_to("k")
end
M.copy_to_down = function()
	return M.copy_to("j")
end

function M.get_windows_info()
	local current_win = vim.api.nvim_get_current_win()
	local info = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local filename = vim.api.nvim_buf_get_name(buf)
		table.insert(info, {
			win_id = win,
			buf_id = buf,
			filename = filename,
			is_current = win == current_win,
			short_name = vim.fn.fnamemodify(filename, ":t"),
		})
	end
	return info
end

local function create_commands()
	if not config.create_commands then
		return
	end
	local commands = {
		{ "CopyToNextWindow", M.copy_to_next, "Show current file in the next window" },
		{ "CopyToLeft", M.copy_to_left, "Show current file in the left window" },
		{ "CopyToRight", M.copy_to_right, "Show current file in the right window" },
		{ "CopyToUp", M.copy_to_up, "Show current file in the upper window" },
		{ "CopyToDown", M.copy_to_down, "Show current file in the lower window" },
	}
	for _, cmd in ipairs(commands) do
		vim.api.nvim_create_user_command(cmd[1], function()
			cmd[2]()
		end, { desc = cmd[3] })
	end
	vim.api.nvim_create_user_command("WindowsInfo", function()
		print("Windows information:")
		for i, win_info in ipairs(M.get_windows_info()) do
			local marker = win_info.is_current and " [current]" or ""
			print(string.format("%d. %s%s", i, win_info.short_name, marker))
		end
	end, { desc = "Show information about all windows" })
end

local function create_keymaps()
	local keymaps = config.keymaps
	local maps = {
		{ keymaps.copy_to_next, M.copy_to_next, "Show file in next window" },
		{ keymaps.copy_to_left, M.copy_to_left, "Show file in left window" },
		{ keymaps.copy_to_right, M.copy_to_right, "Show file in right window" },
	}
	for _, map in ipairs(maps) do
		if map[1] then
			vim.keymap.set("n", map[1], map[2], { desc = map[3], silent = true })
		end
	end
end

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", default_config, user_config or {})
	create_commands()
	create_keymaps()
end

return M
