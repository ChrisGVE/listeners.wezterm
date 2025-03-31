local wezterm = require("wezterm") --[[@as Wezterm]] --- this type cast invokes the LSP module for Wezterm

---@type { setup: fun(opts: table)}
local dev = wezterm.plugin.require("https://github.com/chrisgve/dev.wezterm")

local M = {}

local function init()
	local opts = {
		keywords = { "http", "chrisgve", "listeners", "wezterm" },
		auto = true,
	}
	_ = dev.setup(opts)
end

init()

local listener = require("listener")
local state = require("state")

-- stylua: ignore start
---@class State
M.state = {
  flags = {
    get = function(key) return state:getFlag(key) end,
    set = function(key, value) return state:setFlag(key, value) end,
    toggle = function(key) return state:toggleFlag(key) end,
    remove = function(key) return state:removeFlag(key) end,
  },
  data = {
    get = function(key) return state:getData(key) end,
    set = function(key, value) return state:setData(key, value) end,
    remove = function(key) return state:removeData(key) end,
  },
  counters = {
    get = function(key) return state:getCounter(key) end,
    set = function(key, value) return state:setCounter(key, value) end,
    increment = function(key, increment) return state:incrementCounter(key, increment) end,
    decrement = function(key, decrement) return state:decrementCounter(key, decrement) end,
    remove = function(key) return state:removeCounter(key) end,
  },
  functions = {
    get = function(key) return state:getFunction(key) end,
    set = function(key, value, options) return state:setFunction(key, value, options) end,
    call = function(key, ...) return state:callFunction(key, ...) end,
    safecall = function(key, ...) return state:safeCallFunction(key, ...) end,
    remove = function(key) return state:removeFunction(key) end,
    exists = function(key) return state:existsFunction(key) end,
    get_options = function(key) return state:getFunctionOptions(key) end,
  },
}
-- stylua: ignore end

---@param event_listeners EventListeners
---@param opts listener_opt
function M.config(event_listeners, opts)
	listener.setup_listeners(event_listeners, opts)
end

return M
