-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/core/insert.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--    Header insertion logic for comment-headers plugin.
--    Handles auto-insert on BufNewFile and manual insertion via API.
-- ======================================================================
-- Note:
--    - Positions cursor at Purpose section after insertion
--    - Auto insert uses vim.schedule, manual insert executes immediately
--    - Auto insert works only on empty files
--    - Manual insert works on any file
-- ======================================================================

local M = {}

local function position_cursor_at_purpose(config)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local purpose_label = config.purpose_label

	for i, line in ipairs(lines) do
		-- Search for Purpose label (vim.pesc escapes special pattern chars)
		if line:match(vim.pesc(purpose_label)) then
			local comment_style = line:match("^([#/%-]+)")
			if comment_style then
				-- Position cursor on next line, indented after comment prefix
				-- +3 accounts for: comment chars + space + indent
				vim.api.nvim_win_set_cursor(0, { i + 1, #comment_style + 3 })
				vim.cmd("startinsert!")
				return
			end
		end
	end
end

-- force_insert: if true, insert even if buffer has content (for manual API calls)
-- use_schedule: if true, use vim.schedule (for autocmds), if false, insert immediately (for manual calls)
local function insert_header_internal(
	config,
	path_utils,
	lookup_utils,
	template_utils,
	enabled_set,
	filetype_to_comment,
	force_insert,
	use_schedule
)
	-- Skip if buffer already has content (unless forced by manual API call)
	if not force_insert then
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		if #lines > 1 or (#lines == 1 and lines[1] ~= "") then
			return
		end
	end

	local filetype = vim.bo.filetype:lower()

	-- Skip if filetype not enabled or in skip directory
	if not enabled_set[filetype] or path_utils.should_skip_directory(config) then
		return
	end

	local comment_style = lookup_utils.get_comment_style(filetype, filetype_to_comment)
	local filepath = path_utils.get_relative_path(config)
	local header = template_utils.build_header(config, filepath, comment_style, filetype)

	-- Insert header and position cursor on insert
	local function do_insert()
		vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
		position_cursor_at_purpose(config)
	end

	-- Only schedule for auto-insert, execute immediately for manual calls
	if use_schedule then
		vim.schedule(do_insert)
	else
		do_insert()
	end
end

-- Setup autocmd for automatic header insertion on new files
function M.setup(config, path_utils, lookup_utils, template_utils)
	if not config.auto_insert then
		return
	end

	-- Build lookups once at setup time
	local enabled_set, filetype_to_comment = lookup_utils.build_lookups(config)

	-- Auto insertion on new files
	vim.api.nvim_create_autocmd("BufNewFile", {
		group = vim.api.nvim_create_augroup("CommentHeadersInsert", { clear = true }),
		pattern = "*",
		callback = function()
			-- Auto-insert: don't force, use schedule
			insert_header_internal(
				config,
				path_utils,
				lookup_utils,
				template_utils,
				enabled_set,
				filetype_to_comment,
				false,
				true
			)
		end,
	})
end

-- Public API for manual header insertion
function M.insert_header(config, path_utils, lookup_utils, template_utils)
	local enabled_set, filetype_to_comment = lookup_utils.build_lookups(config)
	-- Manual insert: force-true, use_schedule=false for immediate execution
	insert_header_internal(
		config,
		path_utils,
		lookup_utils,
		template_utils,
		enabled_set,
		filetype_to_comment,
		true,
		false
	)
end

return M
