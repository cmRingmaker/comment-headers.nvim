-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/utils/path.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--   Path manipulation utilities for comment-headers plugin.
--   Handles path stripping, skip directory checking, and prefix addition.
-- ======================================================================
-- Note:
--   - Base paths are checked in priority order (home dir first)
-- ======================================================================

local M = {}

function M.should_skip_directory(config)
	local path = vim.api.nvim_buf_get_name(0)

	for _, dir in ipairs(config.skip_directories) do
		if path:match("/" .. dir .. "/") then
			return true
		end
	end

	return false
end

-- Strip bas path and add prefix
-- Example: /home/user/.config/nvim/init.lua -> ~/.config/nvim/init.lua
function M.get_relative_path(config)
	local fullpath = vim.api.nvim_buf_get_name(0)
	local home = vim.fn.expand("~")

	-- Build base paths (home first, then mount paths)
	local base_paths = { { path = home, prefix = "~/" } }
	for _, mount in ipairs(config.mount_paths) do
		table.insert(base_paths, mount)
	end

	-- Try each base path
	for _, base in ipairs(base_paths) do
		if fullpath:sub(1, #base.path) == base.path then
			-- Ensure we're matching a directory boundary (next char is / or end of string)
			local next_char = fullpath:sub(#base.path + 1, #base.path + 1)
			if next_char == "/" or next_char == "" then
				local relative = fullpath:sub(#base.path + 2)
				return (base.prefix or "") .. relative
			end
		end
	end

	return fullpath
end

return M
