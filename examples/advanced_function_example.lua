local wezterm = require("wezterm")
local listeners = require("plugin")

-- Helper for safely executing functions with error handling
local function safe_call(func, ...)
    local status, result = pcall(func, ...)
    if status then
        return result
    else
        wezterm.log_error("Function execution error: " .. tostring(result))
        return nil
    end
end

-----------------------------------
-- Function Composition Example
-----------------------------------
-- Register some utility functions
listeners.state.functions.set("double", function(x)
    return x * 2
end)

listeners.state.functions.set("add_five", function(x)
    return x + 5
end)

-- A function that composes other functions
listeners.state.functions.set("compose", function(funcs)
    return function(input)
        local result = input
        for i = #funcs, 1, -1 do
            local func_name = funcs[i]
            if listeners.state.functions.exists(func_name) then
                result = listeners.state.functions.call(func_name, result)
            else
                error("Function not found: " .. func_name)
            end
        end
        return result
    end
end)

-- Use the compose function to create a pipeline
local pipeline = listeners.state.functions.call("compose", {"double", "add_five"})
local result = safe_call(pipeline, 10)
wezterm.log_info("Composition result: " .. tostring(result))  -- Should be (10 + 5) * 2 = 30

-----------------------------------
-- Function with Environment Sandbox
-----------------------------------
-- A function to create a sandboxed function from a string
listeners.state.functions.set("create_sandboxed_function", function(code_string, allowed_globals)
    -- Create a restricted environment for the function
    local sandbox = {}
    
    -- Add allowed globals
    if allowed_globals then
        for _, name in ipairs(allowed_globals) do
            sandbox[name] = _G[name]
        end
    end
    
    -- Add basic math operations
    sandbox.math = math
    
    -- Create the function in the sandboxed environment
    local func, err = load("return function(arg) " .. code_string .. " end", "sandbox", "t", sandbox)
    
    if not func then
        error("Failed to create function: " .. tostring(err))
    end
    
    return func()
end)

-- Register a user-defined function in a sandbox
local function_code = "return math.sqrt(arg * arg + 10)"
local allowed = {"tonumber", "tostring"}
local user_func = listeners.state.functions.call("create_sandboxed_function", function_code, allowed)

-- Save the user function
listeners.state.functions.set("user_sqrt_plus", user_func)

-- Call the sandboxed user function
local calc_result = safe_call(function() 
    return listeners.state.functions.call("user_sqrt_plus", 5)
end)
wezterm.log_info("User function result: " .. tostring(calc_result))

-----------------------------------
-- Function with Memorization/Caching
-----------------------------------
-- A memoization wrapper function
listeners.state.functions.set("memoize", function(func_name)
    local cache_key = "memo_cache_" .. func_name
    
    -- Initialize cache
    if not listeners.state.data.get(cache_key) then
        listeners.state.data.set(cache_key, {})
    end
    
    -- Return the memoized function wrapper
    return function(...)
        local args = {...}
        local cache = listeners.state.data.get(cache_key)
        
        -- Create a simple cache key from arguments
        local arg_key = table.concat(args, ",")
        
        if cache[arg_key] ~= nil then
            wezterm.log_info("Cache hit for " .. func_name)
            return cache[arg_key]
        else
            wezterm.log_info("Cache miss for " .. func_name)
            local result = listeners.state.functions.call(func_name, ...)
            cache[arg_key] = result
            listeners.state.data.set(cache_key, cache)
            return result
        end
    end
end)

-- Create an expensive function to memoize
listeners.state.functions.set("fibonacci", function(n)
    if n <= 1 then return n end
    return listeners.state.functions.call("fibonacci", n-1) + listeners.state.functions.call("fibonacci", n-2)
end)

-- Create a memoized version
local memo_fib = listeners.state.functions.call("memoize", "fibonacci")

-- Test the memoized function
wezterm.log_info("Starting memoized fibonacci calculation...")
local start_time = os.time()
local fib_result = memo_fib(20)
wezterm.log_info("Fibonacci result: " .. tostring(fib_result))
wezterm.log_info("Time taken: " .. tostring(os.time() - start_time) .. " seconds")

-- Call again to test caching
start_time = os.time()
fib_result = memo_fib(20)
wezterm.log_info("Cached fibonacci result: " .. tostring(fib_result))
wezterm.log_info("Time taken: " .. tostring(os.time() - start_time) .. " seconds")
