local wezterm = require("wezterm")
local listeners = require("plugin")

-- Example 1: Store a simple greeting function
listeners.state.functions.set("greet", function(name)
    return "Hello, " .. (name or "user") .. "!"
end)

-- Call the stored function
local greeting = listeners.state.functions.call("greet", "WezTerm")
wezterm.log_info("Greeting: " .. greeting)

-- Example 2: Store a calculation function
listeners.state.functions.set("calculate_area", function(width, height)
    return width * height
end)

-- Call the calculation function
local area = listeners.state.functions.call("calculate_area", 5, 10)
wezterm.log_info("Area: " .. area)

-- Example 3: Check if a function exists
if listeners.state.functions.exists("greet") then
    wezterm.log_info("Greet function exists")
else
    wezterm.log_info("Greet function does not exist")
end

-- Example 4: Update an existing function
listeners.state.functions.set("greet", function(name)
    return "Welcome, " .. (name or "user") .. "!"
end)

-- Call the updated function
greeting = listeners.state.functions.call("greet", "WezTerm")
wezterm.log_info("New greeting: " .. greeting)

-- Example 5: Remove a function
listeners.state.functions.remove("calculate_area")
if not listeners.state.functions.exists("calculate_area") then
    wezterm.log_info("Calculate area function has been removed")
end

-- Example 6: Store a complex function that uses saved state
listeners.state.counters.set("visits", 0)
listeners.state.functions.set("track_visit", function(page)
    local current = listeners.state.counters.get("visits")
    listeners.state.counters.set("visits", current + 1)
    return {
        page = page,
        visit_number = current + 1,
        timestamp = os.time()
    }
end)

-- Call the function that interacts with state
local visit1 = listeners.state.functions.call("track_visit", "home")
wezterm.log_info("Visit 1: Page=" .. visit1.page .. ", Number=" .. visit1.visit_number)

local visit2 = listeners.state.functions.call("track_visit", "settings")
wezterm.log_info("Visit 2: Page=" .. visit2.page .. ", Number=" .. visit2.visit_number)
