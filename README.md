# WezTerm Listeners Plugin

A plugin for WezTerm that provides enhanced event listener capabilities with persistent state management.

## Features

- Easy event listener setup with centralized configuration
- Persistent state management across event invocations
- Support for different state types (flags, counters, data, functions)
- Error handling and logging
- Toast notifications for events

## Installation

```lua
-- In your wezterm.lua
local wezterm = require('wezterm')
local listeners = wezterm.plugin.require('https://github.com/username/listeners.wezterm')
```

## Usage

### Basic Configuration

```lua
local event_listeners = {
    -- Simple event listener with notification
    ["window-resized"] = {
        toast_message = "Window resized to %dx%d",
        toast_arg = 1,
    },
    
    -- Event listener with custom function
    ["key-a"] = {
        fn = function(args)
            wezterm.log_info("The 'a' key was pressed!")
        end,
    },
    
    -- Multiple listeners for one event
    ["update-status"] = {
        { fn = function(args) wezterm.log_info("First handler") end },
        { fn = function(args) wezterm.log_info("Second handler") end },
    },
}

-- Configure the plugin
listeners.config(event_listeners, {
    toast_timeout = 2000,  -- 2 seconds toast duration
})
```

### State Management

The plugin provides persistent state that can be accessed and modified from any event handler:

```lua
-- Using flags (boolean values)
listeners.state.flags.set("dark_mode", true)
local is_dark = listeners.state.flags.get("dark_mode")
listeners.state.flags.toggle("dark_mode")

-- Using counters (numeric values)
listeners.state.counters.set("windows_opened", 0)
listeners.state.counters.increment("windows_opened")
local count = listeners.state.counters.get("windows_opened")

-- Using data (any values)
listeners.state.data.set("last_command", "split-pane")
local cmd = listeners.state.data.get("last_command")
```

### Function State

You can store and execute functions in the state:

```lua
-- Store a function
listeners.state.functions.set("calculate_area", function(width, height)
    return width * height
end)

-- Execute a stored function
local area = listeners.state.functions.call("calculate_area", 5, 10)

-- Check if a function exists
if listeners.state.functions.exists("calculate_area") then
    -- Function exists
end

-- Remove a function
listeners.state.functions.remove("calculate_area")

-- Safe function execution with error handling
local result = listeners.state.functions.safecall("calculate_area", 5, 10)
if result.success then
    wezterm.log_info("Area: " .. result.result)
else
    wezterm.log_error("Error: " .. result.error)
end

-- Set function with options
listeners.state.functions.set("complex_calculation", function(x, y)
    -- Complex calculation
    return x * y
end, { 
    safe = true,  -- Use safe execution with error handling
})
```

### Using State Functions in Event Listeners

You can reference stored functions in event listeners:

```lua
-- First, store a function
listeners.state.functions.set("handle_key", function(args)
    local event = args[1]
    wezterm.log_info("Key pressed: " .. event.key)
end)

-- Then reference it in an event listener
local event_listeners = {
    ["key"] = {
        state_fn = "handle_key",  -- Use the stored function
    },
}

listeners.config(event_listeners)
```

## Global Options

You can configure global options when setting up the plugin:

```lua
listeners.config(event_listeners, {
    toast_timeout = 2000,  -- Default toast notification duration in ms
    function_options = {
        safe = true,  -- Default to safe execution for all functions
    }
})
```

## Examples

Check the `examples` directory for more comprehensive examples.

## Contributions

Suggestions, Issues, and PRs are welcome!

The features currently implemented are the ones that address common needs, but your workflow might differ. If you have any proposals on how to improve the plugin, please feel free to make an issue or even better a PR!

- For bug reports, please provide steps to reproduce and relevant error messages
- For feature requests, please explain your use case and why it would be valuable
- For PRs, please ensure your code follows the existing style and includes appropriate documentation

## License

MIT
