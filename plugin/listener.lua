local wezterm = require("wezterm") --[[@as Wezterm]] --- this type cast invokes the LSP module for Wezterm

local utils = require("utils")
local state = require("state")

local listeners = {}

local default_opts = {
	toast_timeout = 2000,
	function_options = {
		timeout = 5000,  -- 5 seconds timeout
		safe = true      -- Safe execution by default
	}
}

---@param event string
---@param listener EventListener
---@param opts listener_opt
local function register_event(event, listener, opts)
	wezterm.on(event, function(...)
		local sections = utils.get_sections(event)
		local args = { ... }

		-- Execute function directly if provided
		if listener.fn then
			listener.fn(args)
		end
		
		-- Execute state function if provided
		if listener.state_fn and state:existsFunction(listener.state_fn) then
			local result, error = state:callFunction(listener.state_fn, args)
			if error then
				wezterm.log_error("Error executing state function '" .. listener.state_fn .. "': " .. error)
			end
		end

		if listener.toast_message then
			local msg = listener.toast_message
			if listener.toast_arg then
				msg = utils.format_message(msg, listener.toast_arg, args)
			end
			utils.notify(msg, listener.max_time or opts.toast_timeout)
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
---@param opts? listener_opt
function listeners.setup_listeners(event_listeners, opts)
	-- Merge provided options with defaults
	opts = utils.tbl_deep_extend("force", default_opts, opts or {})
	
	-- Apply global function options from the provided options
	if opts.function_options then
		state.default_function_options = utils.tbl_deep_extend("force", 
			state.default_function_options, 
			opts.function_options)
	end

	for event, listener_setup in pairs(event_listeners) do
		if type(listener_setup) == "table" and listener_setup[1] ~= nil then
			for _, listener in ipairs(listener_setup) do
				register_event(event, listener, opts)
			end
		else
			register_event(event, listener_setup, opts)
		end
	end
end

return listeners
