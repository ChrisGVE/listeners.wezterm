local wezterm = require("wezterm")
local listeners = require("plugin")

-- Define some helper functions that we'll use
local function format_status(window)
    local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")
    local battery = ""
    
    for _, b in ipairs(wezterm.battery_info()) do
        battery = string.format("%.0f%%", b.state_of_charge * 100)
    end
    
    -- Get values from state
    local key_presses = listeners.state.counters.get("key_presses") or 0
    local last_key = listeners.state.data.get("last_key") or "none"
    local mode = listeners.state.flags.get("vim_mode") and "VIM" or "NORMAL"
    
    return string.format(
        "KEYS: %d | LAST: %s | MODE: %s | BAT: %s | %s",
        key_presses,
        last_key,
        mode,
        battery,
        date
    )
end

-- Set up our state function for handling keystrokes
listeners.state.functions.set("handle_key", function(args)
    if not args or #args < 1 then return end
    
    local event = args[1]
    local key = event.key
    
    -- Track key presses in state
    listeners.state.counters.increment("key_presses")
    listeners.state.data.set("last_key", key)
    
    -- Special key handling
    if key == "v" and event.ctrl then
        -- Toggle vim mode flag
        local new_state = listeners.state.flags.toggle("vim_mode")
        return {
            vim_mode = new_state,
            message = "Vim mode " .. (new_state and "activated" or "deactivated")
        }
    end
    
    return { key = key }
end, {
    timeout = 1000,  -- 1 second timeout for key handling
})

-- Function to update the status bar
listeners.state.functions.set("update_status", function(args)
    if not args or #args < 1 then return end
    
    local window = args[1]
    local status = format_status(window)
    
    -- Use the WezTerm API to set the status
    window:set_right_status(status)
    
    return status
end)

-- Initialize state
listeners.state.counters.set("key_presses", 0)
listeners.state.flags.set("vim_mode", false)

-- Configure event listeners
local event_listeners = {
    -- Track all key presses
    ["key"] = {
        state_fn = "handle_key",
        toast_message = "Key pressed: %s",
        toast_arg = function(args)
            local result = listeners.state.functions.call("handle_key", args)
            if result and result.message then
                return result.message
            end
            return (result and result.key) or "unknown"
        end,
    },
    
    -- Update status bar
    ["update-status"] = {
        state_fn = "update_status",
    },
    
    -- Handle config reloads
    ["reload-configuration"] = {
        fn = function(args)
            -- Reset some state when config is reloaded
            listeners.state.counters.set("config_reloads", 
                (listeners.state.counters.get("config_reloads") or 0) + 1)
            
            wezterm.log_info("Configuration reloaded!")
        end,
        toast_message = "WezTerm config reloaded",
    },
}

-- Configure with custom options
listeners.config(event_listeners, {
    toast_timeout = 1500,  -- 1.5 seconds for toasts
    function_options = {
        timeout = 2000,    -- 2 seconds default timeout
        safe = true,       -- Safe execution
    }
})

-- Show startup message
wezterm.log_info("Complete example configured!")

-- Return a startup message
return {
    text = "WezTerm listener system initialized with state functions"
}
