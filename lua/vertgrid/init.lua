local M = {}
local defaults = {
	size = 5,
	color_name = {
		primary = "CursorLine",
		secondary = "StatusLine",
	},
}

local config = {}

local group = {
	cursor = "Vertgrid-cursor",
	status = "Vertgrid-status",
}

local ns_id = vim.api.nvim_create_namespace("Vertns")

local cursorline
local statusLine

local function setup()
	cursorline = vim.api.nvim_get_hl(0, { name = config.color_name.primary })
	statusLine = vim.api.nvim_get_hl(0, { name = config.color_name.secondary })
	vim.api.nvim_set_hl(ns_id, group.cursor, { bg = cursorline.bg })
	vim.api.nvim_set_hl(ns_id, group.status, { bg = statusLine.bg })
	vim.api.nvim_create_augroup(group.cursor, { clear = true })
	vim.api.nvim_create_augroup(group.status, { clear = true })
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", defaults, opts or {})
	setup()
end

local function Highlight(target, targetGroup)
	if target - 1 < 1 then
		return
	end
	vim.api.nvim_win_set_hl_ns(0, ns_id)
	vim.api.nvim_buf_set_extmark(0, ns_id, target - 1, 0, {
		line_hl_group = targetGroup,
	})
end

local function Render()
	vim.api.nvim_buf_clear_namespace(0, ns_id, 1, -1)
	local cursor_position = vim.api.nvim_win_get_cursor(0)[1]
	local first_line = vim.fn.line("w0")
	local last_line = vim.fn.line("w$")

	for i = cursor_position - config.size * 2, first_line, -config.size * 2 do
		Highlight(i, group.cursor)
	end
	for i = cursor_position + config.size * 2, last_line, config.size * 2 do
		Highlight(i, group.cursor)
	end

	for i = cursor_position - config.size, first_line, -config.size * 2 do
		Highlight(i, group.status)
	end
	for i = cursor_position + config.size, last_line, config.size * 2 do
		Highlight(i, group.status)
	end
end

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = ns_id,
	callback = function()
		vim.api.nvim_buf_clear_namespace(0, ns_id, 1, -1)
		vim.api.nvim_win_set_hl_ns(0, 0)
	end,
})
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "CursorMoved", "CursorMovedI", "ModeChanged" }, {
	group = ns_id,
	callback = function()
		vim.schedule(function()
			Render()
		end)
	end,
})

local function refresh_cursorline()
	cursorline = vim.api.nvim_get_hl(0, { name = config.color_name.primary })
	statusLine = vim.api.nvim_get_hl(0, { name = config.color_name.secondary })

	vim.api.nvim_set_hl(ns_id, group.cursor, {
		bg = cursorline.bg,
	})
	vim.api.nvim_set_hl(ns_id, group.status, {
		bg = statusLine.bg,
	})
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = ns_id,
	callback = refresh_cursorline,
})

return M
