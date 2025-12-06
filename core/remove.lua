-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/core/remove.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--   Header removal logic for comment-headers plugin.
--   Removes entire header block from current buffer.
-- ======================================================================
-- Note:
--   - Searches for field markers ($File, $Version, $Author) to locate header
--   - Walks backwards to find top separator
--   - Finds bottom separator by continuing forward
--   - Only removes if both boundaries are found
-- ======================================================================

local M = {}

function M.remove_header(config)
	local lines = vim.api.nvim_buf_get_lines(0, 0, config.scan_lines, false)
	local start_idx, end_idx

	-- Find start by looking for any header field marker
	for i, line in ipairs(lines) do
		if line:match("%$File") or line:match("%$Version") or line:match("%$Author") then
			-- Walk backwards up to 5 lines to find top separator
			for j = math.max(1, i - 5), i do
				if lines[j]:match("^%s*[#/%-]+%s*=+") then
					start_idx = j
					break
				end
			end
			break
		end
	end

	-- Early exit if no header found
	if not start_idx then
		return
	end

	-- Find bottom separator by continuing forward from header start
	-- Keep updating end_idx to find the LAST separator in the block
	for k = start_idx + 1, #lines do
		if lines[k]:match("^%s*[#/%-]+%s*=+") then
			end_idx = k
		end
	end

	-- Only remove if we found both boundaries
	if start_idx and end_idx then
		vim.api.nvim_buf_set_lines(0, start_idx - 1, end_idx, false, {})
	end
end

return M
