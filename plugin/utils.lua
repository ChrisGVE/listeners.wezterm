local wezterm = require("wezterm") --[[@as Wezterm]] --- this type cast invokes the LSP module for Wezterm

local M = {}

-- Split a dot separated string into sections in a table
---@param str string dot separated string
---@return table sections array of sections from the input string
function M.get_sections(str)
	-- Return cached result if it exists
	if M.split_cache[str] then
		return M.split_cache[str]
	end

	-- Split and cache the result if it's new
	local sections = {}
	for section in str:gmatch("([^%.]+)") do
		table.insert(sections, section)
	end

	-- Store in cache and return
	M.split_cache[str] = sections
	return sections
end

-- Use the OS notification system to notify the user
---@param message string message to display
function M.notify(message)
	local window = wezterm.gui.gui_windows()[1]
	window:toast_notification("wezterm", message, nil, constants.NOTIFICATION_TIME)
end

return M
