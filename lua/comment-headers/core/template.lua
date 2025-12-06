-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/core/template.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--   Template builder for comment-headers plugin.
--   Generates header blocks based on config and filetype.
-- ======================================================================
-- Note:
--   - Only enabled fields are included in the header
--   - License is set from config and never auto-updated
--   - Shell scripts get shebang as first line
--   - Date/Updated use placeholder that gets filled on first save
-- ======================================================================

local M = {}

-- Build complete header template from config
function M.build_header(config, filepath, comment_style, filetype)
	local fields = config.fields
	local header = {}

	-- Top separator
	table.insert(header, comment_style .. " ======================================================================")

	-- Add enabled fields in order
	if fields.file then
		table.insert(header, comment_style .. " $File      : " .. filepath)
	end
	if fields.date then
		-- Placeholder gets replaced with actual date on first save
		table.insert(header, comment_style .. " $Date      : --/--/--")
	end
	if fields.updated then
		-- Placeholder gets replaced with actual date on first save
		table.insert(header, comment_style .. " $Updated   : --/--/--")
	end
	if fields.version then
		table.insert(header, comment_style .. " $Version   : 1.0.0")
	end
	if fields.author then
		table.insert(header, comment_style .. " $Author    : " .. config.author)
	end
	if fields.license then
		-- License is set from config on creation and never auto-updated
		table.insert(header, comment_style .. " $License   : " .. config.license)
	end

	-- Middle separator + Purpose section
	table.insert(header, comment_style .. " ======================================================================")
	table.insert(header, comment_style .. " " .. config.purpose_label)
	table.insert(header, comment_style .. "   ")

	-- Bottom separator + Note section
	table.insert(header, comment_style .. " ======================================================================")
	table.insert(header, comment_style .. " " .. config.note_label)
	table.insert(header, comment_style .. "   ")
	table.insert(header, comment_style .. " ======================================================================")
	table.insert(header, "")

	-- Add shebang for shell scripts (must be first line in file)
	if filetype == "sh" or filetype == "bash" then
		table.insert(header, 1, "#!/bin/bash")
		table.insert(header, 2, "")
	end

	return header
end

return M
