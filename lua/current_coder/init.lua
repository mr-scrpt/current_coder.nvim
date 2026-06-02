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

local config = {}

local function copy_current_file_to_direction(direction, return_focus)
	local current_buf = vim.api.nvim_get_current_buf()
	local current_file = vim.api.nvim_buf_get_name(current_buf)
	local current_win = vim.api.nvim_get_current_win()

	-- Check if file exists
	if current_file == "" then
		if not config.silent then
			vim.notify("Current buffer is not associated with a file", vim.log.levels.WARN)
		end
		return false
	end

	local current_pos = vim.api.nvim_win_get_cursor(0)

	local success = pcall(vim.cmd, "wincmd " .. direction)
	if not success then
		if not config.silent then
			vim.notify("Failed to switch to window " .. direction, vim.log.levels.ERROR)
		end
		return false
	end

	local new_win = vim.api.nvim_get_current_win()
	if new_win == current_win then
		if not config.silent then
			vim.notify("No adjacent window in direction " .. direction, vim.log.levels.WARN)
		end
		return false
	end

	vim.cmd("edit " .. vim.fn.fnameescape(current_file))

	vim.api.nvim_win_set_cursor(0, current_pos)

	if return_focus then
		vim.api.nvim_set_current_win(current_win)
	end

	if not config.silent then
		local direction_name = direction == "h" and "left"
			or direction == "l" and "right"
			or direction == "j" and "bottom"
			or direction == "k" and "top"
			or direction
		local filename = vim.fn.fnamemodify(current_file, ":t")
		vim.notify(string.format("File '%s' copied to %s window", filename, direction_name))
	end

	return true
end

local function copy_to_next_window()
	local current_buf = vim.api.nvim_get_current_buf()
	local current_file = vim.api.nvim_buf_get_name(current_buf)

	if current_file == "" then
		if not config.silent then
			vim.notify("Current buffer is not associated with a file", vim.log.levels.WARN)
		end
		return false
	end

	local current_pos = vim.api.nvim_win_get_cursor(0)

	vim.cmd("wincmd w")

	vim.cmd("edit " .. vim.fn.fnameescape(current_file))

	vim.api.nvim_win_set_cursor(0, current_pos)

	if not config.silent then
		local filename = vim.fn.fnamemodify(current_file, ":t")
		vim.notify(string.format("File '%s' copied to next window", filename))
	end

	return true
end

local function get_windows_info()
	local windows = vim.api.nvim_list_wins()
	local current_win = vim.api.nvim_get_current_win()
	local info = {}

	for _, win in ipairs(windows) do
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

	vim.api.nvim_create_user_command("CopyToNextWindow", copy_to_next_window, {
		desc = "Copy current file to next window",
	})

	vim.api.nvim_create_user_command("CopyToLeft", function()
		copy_current_file_to_direction("h", false)
	end, {
		desc = "Copy current file to left window",
	})

	vim.api.nvim_create_user_command("CopyToRight", function()
		copy_current_file_to_direction("l", false)
	end, {
		desc = "Copy current file to right window",
	})

	vim.api.nvim_create_user_command("CopyToUp", function()
		copy_current_file_to_direction("k", false)
	end, {
		desc = "Copy current file to upper window",
	})

	vim.api.nvim_create_user_command("CopyToDown", function()
		copy_current_file_to_direction("j", false)
	end, {
		desc = "Copy current file to lower window",
	})

	vim.api.nvim_create_user_command("WindowsInfo", function()
		local info = get_windows_info()
		print("Windows information:")
		for i, win_info in ipairs(info) do
			local marker = win_info.is_current and " [current]" or ""
			print(string.format("%d. %s%s", i, win_info.short_name, marker))
		end
	end, {
		desc = "Show information about all windows",
	})
end

local function create_keymaps()
	local keymaps = config.keymaps

	if keymaps.copy_to_next then
		vim.keymap.set("n", keymaps.copy_to_next, copy_to_next_window, {
			desc = "Copy file to next window",
			silent = true,
		})
	end

	if keymaps.copy_to_left then
		vim.keymap.set("n", keymaps.copy_to_left, function()
			copy_current_file_to_direction("h", false)
		end, {
			desc = "Copy file to left window",
			silent = true,
		})
	end

	if keymaps.copy_to_right then
		vim.keymap.set("n", keymaps.copy_to_right, function()
			copy_current_file_to_direction("l", false)
		end, {
			desc = "Copy file to right window",
			silent = true,
		})
	end
end

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", default_config, user_config or {})

	create_commands()
	create_keymaps()
end

M.copy_to_next = copy_to_next_window
M.copy_to_left = function()
	return copy_current_file_to_direction("h", false)
end
M.copy_to_right = function()
	return copy_current_file_to_direction("l", false)
end
M.copy_to_up = function()
	return copy_current_file_to_direction("k", false)
end
M.copy_to_down = function()
	return copy_current_file_to_direction("j", false)
end
M.get_windows_info = get_windows_info

return M
