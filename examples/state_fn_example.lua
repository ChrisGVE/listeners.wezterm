local wezterm = require("wezterm")
local listeners = require("plugin")

-- First, register some functions in the state
listeners.state.functions.set("log_event", function(args)
    wezterm.log_info("Event args received: " .. wezterm.inspect(args))
    return true
end)

listeners.state.functions.set("handle_key", function(args)
    if not args or #args < 1 then return end
    
    local event = args[1]
    -- Check if this was the 'a' key
    if event.key == "a" then
        wezterm.log_info("The 'a' key was pressed!")
        -- You could update state here
        listeners.state.counters.increment("a_key_presses")
    end
end)

listeners.state.functions.set("track_window_resize", function(args)
    if not args or #args < 1 then return end
    
    local dims = args[1]
    wezterm.log_info(string.format("Window resized to %dx%d", dims.width, dims.height))
    
    -- Store the current dimensions in the state
    listeners.state.data.set("window_width", dims.width)
    listeners.state.data.set("window_height", dims.height)
end)

-- Initialize a counter
listeners.state.counters.set("a_key_presses", 0)

-- Set up event listeners using state_fn
local event_listeners = {
    -- Log all keys using the state function
    ["key"] = {
        state_fn = "log_event",
        log_message = "Key event occurred",
    },
    
    -- Special handling for 'a' key
    ["key-a"] = {
        state_fn = "handle_key",
    },
    
    -- Track window resizes
    ["window-resized"] = {
        state_fn = "track_window_resize",
        toast_message = "Window resized to %dx%d",
        toast_arg = 1,
    },
    
    -- Demonstrate both fn and state_fn together
    ["update-status"] = {
        -- Custom in-place function
        fn = function(args)
            wezterm.log_info("Status updated via fn")
        end,
        -- Also use a state function
        state_fn = "log_event",
    },
}

-- Configure with custom function options
listeners.config(event_listeners, {
    toast_timeout = 3000,
    function_options = {
        timeout = 3000,  -- 3 second timeout for all functions
        safe = true,
    }
})

-- Note: This is just an example - in real usage, the events would be triggered by user actions
wezterm.log_info("State function event handlers configured!")
