local wezterm = require("wezterm") --[[@as Wezterm]] --- this type cast invokes the LSP module for Wezterm

local M = {}

M.split_cache = {}

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

---@param msg string
---@param args any[]
---@param selected_args number|number[]
---@return string
function M.format_message(msg, args, selected_args)
	local function collect_args(args, pos, selection)
		if type(pos) == "number" and pos >= 1 and pos <= #args then
			selection[#selection + 1] = args[pos]
			return true
		else
			return false
		end
	end

	-- Guard against nil message
	if not msg then
		return ""
	end

	-- Guard against nil or empty args
	if not args or #args == 0 then
		return msg
	end

	local format_args = {}
	local valid = false
	local single = false
	local valid_type = true

	-- Handle single index
	if type(selected_args) == "number" then
		valid = collect_args(args, selected_args, format_args)
		single = true
	-- Handle multiple indices
	elseif type(selected_args) == "table" and #selected_args > 0 then
		for _, arg_index in ipairs(selected_args) do
			valid = collect_args(args, arg_index, format_args)
			if not valid then
				break
			end
		end
	else
		valid_type = false
	end

	if valid then
		-- Use pcall to catch formatting errors
		local success, result = pcall(function()
			return string.format(msg, table.unpack(format_args))
		end)
		if not success then
			wezterm.log_error(("Formatting error: " .. result))
		end
		return success and result or msg .. "(" .. result .. ")"
	end

	local err
	if valid_type then
		if single then
			err = "index"
		else
			err = "indices"
		end
		err = "(incorrect argument " .. err .. ")"
	else
		err = "(incorrect type of argument selection)"
	end

	wezterm.log_error("Formatting error: " .. msg .. " " .. err)

	return msg .. " " .. err
end

-- Use the OS notification system to notify the user
---@param message string message to display
function M.notify(message, time)
	local window = wezterm.gui.gui_windows()[1]
	window:toast_notification("wezterm", message, nil, time)
end

-- deep copy
---@param original table
---@return any copy
function M.deepcopy(original)
	local copy
	if type(original) == "table" then
		copy = {}
		for k, v in pairs(original) do
			copy[k] = M.deepcopy(v)
		end
	else
		copy = original
	end
	return copy
end

-- extend table
---@alias behavior
---| 'error' # Raises an error if a kye exists in multiple tables
---| 'keep'  # Uses the value from the leftmost table (first occurrence)
---| 'force' # Uses the value from the rightmost table (last occurrence)
---
---@param behavior behavior
---@param ... table
---@return table|nil
function M.tbl_deep_extend(behavior, ...)
	local tables = { ... }
	if #tables == 0 then
		return {}
	end

	local result = {}
	for k, v in pairs(tables[1]) do
		if type(v) == "table" then
			result[k] = M.deepcopy(v)
		else
			result[k] = v
		end
	end

	for i = 2, #tables do
		for k, v in pairs(tables[i]) do
			if type(result[k]) == "table" and type(v) == "table" then
				-- For nested tables, we recurse with the same behavior
				result[k] = M.tbl_deep_extend(behavior, result[k], v)
			elseif result[k] ~= nil then
				-- Key exists in the result already
				if behavior == "error" then
					error("Key '" .. tostring(k) .. "' exists in multiple tables")
				elseif behavior == "force" then
					-- "force" uses value from rightmost table
					if type(v) == "table" then
						result[k] = M.deepcopy(v)
					else
						result[k] = v
					end
				end
			-- "keep" keeps the leftmost value, which is already in result
			else
				-- Key doesn't exist in result yet, add it
				if type(v) == "table" then
					result[k] = M.deepcopy(v)
				else
					result[k] = v
				end
			end
		end
	end

	return result
end

return M
