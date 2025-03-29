local StateManager = {}
StateManager.__index = StateManager

---@return metatable
function StateManager.new()
	local self = {
		flags = {},
		counters = {},
		data = {},
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

return StateManager.new()
