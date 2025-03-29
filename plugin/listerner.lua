local wezterm = require("wezterm") --[[@as Wezterm]] --- this type cast invokes the LSP module for Wezterm

local utils = require("utils")

local listeners = {}

---@param event string
---@param listener EventListener
local function register_event(event, listener)
	wezterm.on(event, function(...)
		local sections = utils.get_sections(event)
		local args = { ... }

		if listener.fn then
			listener.fn(args)
		end
		if listener.toast_message then
			local msg = listener.toast_message
			if listener.toast_arg then
				msg = utils.format_message(msg, listener.toast_arg, args)
			end
			utils.notify(msg, listener.max_time or 2000)
		end
		if listener.log_message then
			local log = event .. ":"
			for _, v in ipairs(args) do
				log = log .. " " .. tostring(v)
			end
			if listener.error then
				wezterm.log_error(listener.log_message, log)
			elseif listener.warn then
				wezterm.log_warn(listener.log_message, log)
			else
				wezterm.log_info(listener.log_message, log)
			end
		end
	end)
end

---@param event_listeners EventListeners
function listeners.setup_listeners(event_listeners)
	for event, listener_setup in pairs(event_listeners) do
		if type(listener_setup) == "table" and listener_setup[1] ~= nil then
			for _, listener in ipairs(listener_setup) do
				register_event(event, listener)
			end
		else
			register_event(event, listener_setup)
		end
	end
end

return listeners
