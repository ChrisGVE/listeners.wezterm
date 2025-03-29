local wezterm = require("wezterm") --[[@as Wezterm]] --- this type cast invokes the LSP module for Wezterm

---@type { setup: fun(config: table, opts: table)}
local dev = wezterm.plugin.require("https://github.com/chrisgve/dev.wezterm")

local M = {}

local function init()
	_ = dev.setup({ "http", "chrisgve", "listeners", "wezterm" }, { auto = true })
end

init()

local listener = require("listener")
local state = require("state")

-- stylua: ignore start
M.state = {
  flags = {
    get = function(key) return state:getFlag(key) end,
    set = function(key, value) return state:setFlag(key, value) end,
    toggle = function(key) return state:toggleFlag(key) end,
    remove = function(key) return state:removeFlag(key) end,
  },
  data = {
    get = function(key) return state:getData(key) end,
    set = function(key, value) return state:setValue(key,value) end,
    remove = function(key) return state:removeData(key) end,
  },
  counters = {
    get = function(key) return state:getCounter(key) end,
    set = function(key, value) return state:setCounter(key, value) end,
    increment = function(key, increment) return state:incrementCounter(key, increment) end,
    decrement = function(key, decrement) return state:decrementCounter(key, decrement) end,
    remove = function(key) return state:removeCounter(key) end,
  },
}
-- stylua: ignore end

---@param event_listeners EventListeners
function M.config(event_listeners)
	listener.setup_listeners(event_listeners)
end

return M
