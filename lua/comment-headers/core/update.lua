-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/core/update.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--   Header update logic for comment-headers plugin.
--   Updates $File, $Date, and $Updated fields on save.
-- ======================================================================
-- Note:
--   - Only scans first N lines (15 is default)
--   - Date cache refreshed every 20 minutes
--   - Preserves cursor position during updates
-- ======================================================================

local M = {}

local today_cache = ""
local last_check = 0
local DATE_PLACEHOLDER = "--/--/--"

-- Extract and trim value from header line
-- Example: "// $File      : path.lua      " -> "path.lua""
local function extract_value(line)
	local value = line:match(":%s*(.-)%s*$")
	return value and value:match("^%s*(.-)%s*$") or ""
end

local function update_headers_internal(config, path_utils)
	-- Early exit if buffer hasn't been modified
	-- This prevents updating $Updated when you just hit :w without changes
	if not vim.bo.modified then
		return
	end

	-- Early exit if no updatable fields are enabled
	if not (config.fields.file or config.fields.date or config.fields.updated) then
		return
	end

	-- Refresh date cache every 20 minutes (1200 seconds)
	local now = os.time()
	if now - last_check > 1200 then
		today_cache = os.date(config.date_format) --[[@as string]]
		last_check = now
	end

	-- Only scan configured number of lines (default: 15)
	local lines = vim.api.nvim_buf_get_lines(0, 0, config.scan_lines, false)
	local changes = {}
	local current_path = path_utils.get_relative_path(config)

	-- Scan header area for fields that need updating
	for i, line in ipairs(lines) do
		-- Fast byte-level check: skip non-comment lines
		-- ASCII: 35 = '#', 47 = '/', 45 = '-'
		local first_byte = line:byte(1)
		if first_byte ~= 35 and first_byte ~= 47 and first_byte ~= 45 then
			goto continue
		end

		-- Skip lines without $ field marker
		if not line:find("$", 1, true) then
			goto continue
		end

		-- Extract comment style and field name
		local comment_style, field_name = line:match("^([#/%-]+)%s*%$(%w+)%s*:")
		if not comment_style then
			goto continue
		end

		-- Update $File if path has changed (trim both for accurate comparison)
		if field_name == "File" and config.fields.file then
			if extract_value(line) ~= current_path then
				changes[i] = comment_style .. " $File      : " .. current_path
			end

		-- Update $Date if still placeholder (only happens on first save)
		elseif field_name == "Date" and config.fields.date then
			if line:find(DATE_PLACEHOLDER, 1, true) then
				changes[i] = comment_style .. " $Date      : " .. today_cache
			end

		-- Update $Updated if date has changed (trim for accurate comparison)
		elseif field_name == "Updated" and config.fields.updated then
			-- local stored_date = trim(line:match(":%s*(.-)%s*$"))
			-- if stored_date ~= today_cache then
			-- changes[i] = comment_style .. " $Updated   : " .. today_cache
			if extract_value(line) ~= today_cache then
				changes[i] = comment_style .. " $Updated   : " .. today_cache
			end
		end

		-- NOTE: $License, $Version, and $Author are intentionally NOT updated here

		::continue::
	end

	-- Batch apply all changes
	if next(changes) then
		-- Preserve cursor position across changes
		local cursor = vim.api.nvim_win_get_cursor(0)

		for line_num, new_line in pairs(changes) do
			vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { new_line })
		end

		vim.api.nvim_win_set_cursor(0, cursor)
	end
end

-- Setup autocmd for automatic header updates on save
function M.setup(config, path_utils)
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("CommentHeadersUpdate", { clear = true }),
		callback = function()
			update_headers_internal(config, path_utils)
		end,
	})
end

-- Public API for manual header updates
function M.update_headers(config, path_utils)
	update_headers_internal(config, path_utils)
end

return M
