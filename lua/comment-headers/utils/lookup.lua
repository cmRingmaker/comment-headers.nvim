-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/utils/lookup.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--   Filetype lookup utilities for comment-headers plugin.
--   Builds lookup tables from config for filetype checking.
-- ======================================================================
-- Note:
--   - All filetypes are normalized to lowercase for consistency
--   - Falls back to "//" style if filetype not found
-- ======================================================================

local M = {}
-- Build lookup tables from comment_styles config
-- Returns: enabled_set (filetypes to process), filetype_to_comment (style map)
function M.build_lookups(config)
	local enabled_set = {}
	local filetype_to_comment = {}

	-- Convert comment_styles config into fast lookup tables
	for style, filetypes in pairs(config.comment_styles) do
		for _, ft in ipairs(filetypes) do
			local ft_lower = ft:lower()
			filetype_to_comment[ft_lower] = style
			enabled_set[ft_lower] = true
		end
	end

	return enabled_set, filetype_to_comment
end

-- Get comment style for filetype with fallback to "//"
function M.get_comment_style(filetype, filetype_to_comment)
	return filetype_to_comment[filetype] or "//"
end

return M
