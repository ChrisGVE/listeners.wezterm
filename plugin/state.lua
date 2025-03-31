-- Import wezterm for the timing functions
local wezterm = require("wezterm")

-- Default function options
local StateManager = {
	default_function_options = {
		timeout = 5000, -- Default timeout: 5000ms (5 seconds)
		safe = true,    -- Default to safe execution
	}
}
StateManager.__index = StateManager

---@return InternalState
function StateManager.new()
	local self = {
		flags = {},
		counters = {},
		data = {},
		functions = {},
		function_options = {}, -- Store options for functions
	}
	return setmetatable(self, StateManager)
end

---@param category string
---@param key string
---@return boolean
function StateManager:_removeKey(category, key)
	if self[category] and type(self[category]) == "table" then
		self[category][key] = nil
		return true
	end
	return false
end

---@param category string
---@param key string
---@return any|nil
function StateManager:_getValue(category, key)
	if self[category] and type(self[category]) == "table" then
		return self[category][key]
	end
	return nil
end

---@param category string
---@param key string
---@param value any
---@return any|nil
function StateManager:_setValue(category, key, value)
	if self[category] and type(self[category]) == "table" then
		self[category][key] = value
		return value
	end
	return nil
end

---------------
-- Accessors
---------------
--- Flags

---@param key string
---@return boolean|nil
function StateManager:getFlag(key)
	return self:_getValue("flags", key)
end

---@param key string
---@param value boolean
---@return boolean
function StateManager:setFlag(key, value)
	return self:_setValue("flags", key, value)
end

---@param key string
---@return boolean
function StateManager:toggleFlag(key)
	local current = self:_getValue("flags", key)
	return self:_setValue("flags", key, not current)
end

---@param key string
---@return boolean
function StateManager:removeFlag(key)
	return self:_removeKey("flags", key)
end

--- Data

---@param key string
---@return any|nil
function StateManager:getData(key)
	return self:_getValue("data", key)
end

---@param key string
---@param value any
---@return any
function StateManager:setData(key, value)
	return self:_setValue("data", key, value)
end

---@param key string
---@return boolean
function StateManager:removeData(key)
	return self:_removeKey("data", key)
end

--- Counters

---@param key string
---@param value? number
---@return number
function StateManager:setCounter(key, value)
	return self:_setValue("counters", key, value or 0)
end

---@param key string
---@return number
function StateManager:getCounter(key)
	return self:_getValue("counters", key) or 0
end

---@param key string
---@param increment? number
---@return number
function StateManager:incrementCounter(key, increment)
	increment = increment or 1
	return self:_setValue("counters", key, (self:_getValue("counters", key) or 0) + increment)
end

---@param key string
---@param decrement? number
---@return number
function StateManager:decrementCounter(key, decrement)
	decrement = decrement or 1
	return self:_setValue("counters", key, (self:_getValue("counters", key) or 0) - decrement)
end

---@param key string
---@return boolean
function StateManager:removeCounter(key)
	return self:_removeKey("counters", key)
end

--- Functions

---@param key string
---@return function|nil
function StateManager:getFunction(key)
	return self:_getValue("functions", key)
end

---@param key string
---@param func function
---@param options? FunctionOptions
---@return function|nil
function StateManager:setFunction(key, func, options)
	if type(func) ~= "function" then
		return nil
	end
	
	-- Merge with default options
	options = options or {}
	local merged_options = {}
	for k, v in pairs(self.default_function_options) do
		merged_options[k] = options[k] ~= nil and options[k] or v
	end
	
	-- Store the options
	self.function_options[key] = merged_options
	
	return self:_setValue("functions", key, func)
end

---@param key string
---@return FunctionOptions|nil
function StateManager:getFunctionOptions(key)
	return self.function_options[key]
end

---@param key string
---@return boolean
function StateManager:existsFunction(key)
	return self:_getValue("functions", key) ~= nil
end

---@param key string
---@vararg any
---@return any, string?
function StateManager:callFunction(key, ...)
	local func = self:_getValue("functions", key)
	if type(func) ~= "function" then
		return nil, "Function not found or is not callable"
	end
	
	local options = self:getFunctionOptions(key) or self.default_function_options
	
	if options.safe then
		-- Safe execution with pcall
		local status, result = pcall(func, ...)
		if not status then
			return nil, "Function execution error: " .. tostring(result)
		end
		return result
	else
		-- Direct execution without safety
		return func(...)
	end
end

---@param key string
---@vararg any
---@return FunctionCallResult
function StateManager:safeCallFunction(key, ...)
	local result = {
		success = false,
		result = nil,
		error = nil,
		timed_out = false
	}
	
	local func = self:_getValue("functions", key)
	if type(func) ~= "function" then
		result.error = "Function not found or is not callable"
		return result
	end
	
	local options = self:getFunctionOptions(key) or self.default_function_options
	local args = {...}
	
	-- Simple execution with pcall - without timeout due to WezTerm limitations
	-- Note: wezterm.time.call_after doesn't work reliably in callbacks per issue #3026
	local status, func_result = pcall(function()
		return func(table.unpack(args))
	end)
	
	if status then
		result.success = true
		result.result = func_result
	else
		result.error = "Function execution error: " .. tostring(func_result)
	end
	
	return result
end

---@param key string
---@return boolean
function StateManager:removeFunction(key)
	-- Also remove the options
	if self.function_options[key] then
		self.function_options[key] = nil
	end
	return self:_removeKey("functions", key)
end

return StateManager.new()
