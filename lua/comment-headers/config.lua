-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/config.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--   Configuration module for comment-headers plugin.
--   Defines all default settings and provides setup() for user overrides.
-- ======================================================================
-- Note:
--   - scan_lines is ONLY defined here (no fallbacks needed elsewhere)
-- ======================================================================

local M = {}

M.defaults = {
	author = "Author",
	license = "MIT",
	date_format = "%y/%m/%d", -- Style you want your date to appear as (strftime format codes)
	scan_lines = 15, -- How many lines to scan for header fields
	auto_insert = true, -- Auto-insert headers on newly created files

	-- Toggle individual header fields
	fields = {
		file = true,
		date = true,
		updated = true,
		version = true,
		author = true,
		license = true,
	},

	-- Extra info about fields:
	-- File:      Auto updates if file moves directories or changes name
	-- Date:      Set once on first save, replacing the placeholder
	-- Updated:   Updates every save, assuming changes are made
	-- Version:   Never auto-updates, manual
	-- Author:    Never auto-updates, manual
	-- License:   Never auto-updates, manual

	-- Customize section labels
	purpose_label = "Purpose:",
	note_label = "Note:",

	-- Strip these paths for cleaner headers
	-- Leave empty if not needed - home directory (~/) is always stripped
	-- Example: /mnt/Projects/myapp/code.lua -> myapp/code.lua
	mount_paths = {
		-- { path = "/mnt/Projects", prefix = "" },
	},

	-- Map comment styles to filetypes
	-- If your language has a single line comment format found below, they can be added easily
	comment_styles = {
		["//"] = { "javascript", "typescript", "c", "cpp", "csharp", "rust", "go", "java", "swift", "zig" },
		["--"] = { "lua", "sql", "haskell" },
		["#"] = { "python", "sh", "bash", "zsh", "fish", "yaml", "toml", "ruby", "perl", "env" },
	},

	-- Skip auto-insert in these directories
	-- Can add whichever directories you NEVER want a header to possibly be added to
	skip_directories = {
		"node_modules",
		"vendor",
		".git",
		"build",
	},
}

M.options = vim.deepcopy(M.defaults)

function M.setup(user_config)
	M.options = vim.tbl_deep_extend("force", M.defaults, user_config or {})
end

return M
