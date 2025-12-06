-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/init.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--   Main entry point for comment-headers plugin.
--   Orchestrates setup and exposes public API to users.
-- ======================================================================
-- Note:
--   - This is what users require in their config
-- ======================================================================

local M = {}

local config_module = require("comment-headers.config")
local path_utils = require("comment-headers.utils.path")
local lookup_utils = require("comment-headers.utils.lookup")
local template_utils = require("comment-headers.core.template")
local insert_module = require("comment-headers.core.insert")
local update_module = require("comment-headers.core.update")
local api = require("comment-headers.api")

local commands_created = false

-- User commands for easier nvim usage
local function create_commands()
	if commands_created then
		return
	end

	-- Usage in nvim: :CommentHeaderInsert, :CommentHeaderUpdate, :CommentHeaderRemove
	vim.api.nvim_create_user_command("CommentHeaderInsert", api.insert_header, { desc = "Insert a new header" })
	vim.api.nvim_create_user_command("CommentHeaderUpdate", api.update_headers, { desc = "Update existing header" })
	vim.api.nvim_create_user_command("CommentHeaderRemove", api.remove_header, { desc = "Remove the existing header" })

	commands_created = true
end

-- Initialize plugin with user configuration
function M.setup(user_config)
	config_module.setup(user_config)
	local config = config_module.options

	-- Setup automatic features
	insert_module.setup(config, path_utils, lookup_utils, template_utils)
	update_module.setup(config, path_utils)

	create_commands()
end

-- Expose public API
M.insert_header = api.insert_header
M.update_headers = api.update_headers
M.remove_header = api.remove_header

M.version = "1.0.0"

return M
