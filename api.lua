-- ======================================================================
-- $File      : ~/.config/nvim/lua/comment-headers/api.lua
-- $Date      : 25/11/30
-- $Updated   : 25/12/05
-- $Author    : Ringmaker
-- ======================================================================
-- Purpose:
--   Public API for comment-headers plugin.
--   Exposes user-facing functions for manual header operations.
-- ======================================================================
-- Note:
--   - All functions operate on the current buffer
--   - These are exposed through init.lua to users
--   - Useful for custom keybindings or commands
-- ======================================================================

local M = {}

-- Load all required modules
local config_module = require("comment-headers.config")
local path_utils = require("comment-headers.utils.path")
local lookup_utils = require("comment-headers.utils.lookup")
local template_utils = require("comment-headers.core.template")
local insert_module = require("comment-headers.core.insert")
local update_module = require("comment-headers.core.update")
local remove_module = require("comment-headers.core.remove")

-- Manually insert header in current buffer
-- Usage: :lua require('comment-headers').insert_header()
function M.insert_header()
	local config = config_module.options
	insert_module.insert_header(config, path_utils, lookup_utils, template_utils)
end

-- Manually update headers in current buffer
-- Will ONLY update file, date (if still placeholder), and updated
-- Usage: :lua require('comment-headers').update_headers()
function M.update_headers()
	local config = config_module.options
	update_module.update_headers(config, path_utils)
end

-- Remove header from current buffer
-- Usage: :lua require('comment-headers').remove_header()
function M.remove_header()
	local config = config_module.options
	remove_module.remove_header(config)
end

return M
