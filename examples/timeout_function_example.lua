local wezterm = require("wezterm")
local listeners = require("plugin")

-- Example of setting functions with options
wezterm.log_info("Setting up functions with options...")

-- Function that completes quickly
listeners.state.functions.set("quick_function", function()
    -- Some quick work
    local result = 0
    for i = 1, 1000 do
        result = result + i
    end
    return result
end, { safe = true }) 

-- Function that takes longer
listeners.state.functions.set("normal_function", function()
    -- Simulate moderate work
    local result = 0
    for i = 1, 100000 do
        result = result + i
    end
    return result
end)

-- Note: Timeout is not enforced due to WezTerm limitations
-- The timeout option is kept for future compatibility
listeners.state.functions.set("long_function", function()
    -- Simulate long work
    local result = 0
    for i = 1, 10000000 do -- Large loop
        result = result + i
        -- Check every 1M iterations to log progress
        if i % 1000000 == 0 then
            wezterm.log_info("Long function iteration: " .. i)
        end
    end
    return result
end, { timeout = 1000 }) -- This timeout is not enforced

-- Function with unsafe execution
listeners.state.functions.set("unsafe_function", function()
    -- This will throw an error
    return non_existent_variable + 10
end, { safe = false })

-- Testing the functions
wezterm.log_info("Testing quick function...")
local result = listeners.state.functions.safecall("quick_function")
wezterm.log_info("Quick function success: " .. tostring(result.success))
wezterm.log_info("Quick function result: " .. tostring(result.result))

wezterm.log_info("\nTesting normal function...")
result = listeners.state.functions.safecall("normal_function")
wezterm.log_info("Normal function success: " .. tostring(result.success))
wezterm.log_info("Normal function result: " .. tostring(result.result))

wezterm.log_info("\nTesting long function (will likely timeout)...")
result = listeners.state.functions.safecall("long_function")
wezterm.log_info("Long function success: " .. tostring(result.success))
wezterm.log_info("Long function timed out: " .. tostring(result.timed_out))
wezterm.log_info("Long function error: " .. tostring(result.error))

wezterm.log_info("\nTesting unsafe function (will error)...")
local success, error_msg = pcall(function()
    listeners.state.functions.call("unsafe_function")
end)
wezterm.log_info("Unsafe function call succeeded: " .. tostring(success))
wezterm.log_info("Unsafe function error: " .. tostring(error_msg))

-- Example of using both APIs
wezterm.log_info("\nExample of using both APIs...")

-- 1. Get + direct call (unsafe but flexible)
wezterm.log_info("Using getFunction and direct call...")
local func = listeners.state.functions.get("quick_function")
if func then
    local direct_result = func()
    wezterm.log_info("Direct call result: " .. tostring(direct_result))
end

-- 2. Safe call with result handling
wezterm.log_info("Using safecall API...")
result = listeners.state.functions.safecall("normal_function")
if result.success then
    wezterm.log_info("Safe call successful with result: " .. tostring(result.result))
else
    wezterm.log_info("Safe call failed: " .. tostring(result.error))
end

-- 3. Standard call with error handling
wezterm.log_info("Using standard call API with error handling...")
local call_result, call_error = listeners.state.functions.call("normal_function")
if call_error then
    wezterm.log_info("Call failed: " .. call_error)
else
    wezterm.log_info("Call successful with result: " .. tostring(call_result))
end
