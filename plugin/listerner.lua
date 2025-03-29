local wezterm = require("wezterm") --[[@as Wezterm]] --- this type cast invokes the LSP module for Wezterm

local listener = {}

local utils = require("utils")

---@param event_listeners EventListeners
function listener.setup_listeners(event_listeners)
	for event, opts in pairs(event_listeners) do
		wezterm.on(event, function(...)
			local sections = utils.get_sections(event)
			local args = { ... }

			if opts.fn then
				opts.fn(args)
			end
			if opts.message then
				local msg = opts.message
				if opts.format then
					msg = string.format(msg, args[opts.format])
				end
				utils.notify(msg)
			end
			if opts.log_message then
				local log = event .. ":"
				for _, v in ipairs(args) do
					log = log .. " " .. tostring(v)
				end
				if opts.error then
					wezterm.log_error(opts.log_message, log)
				elseif opts.warn then
					wezterm.log_warn(opts.log_message, log)
				else
					wezterm.log_info(opts.log_message, log)
				end
			end
		end)
	end
end

return listener
