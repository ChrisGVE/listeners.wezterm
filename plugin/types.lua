---@class EventListeners
---@type table<string, EventListener|EventListener[]>

---@alias args any[]
---
---@class EventListener
---@field fn? fun(args:args)
---@field toast_message? string
---@field toast_arg? number
---@field max_time? number
---@field log_message? string
---@field info? boolean
---@field warn? boolean
---@field error? boolean

---@class State
---@type table<string, any>
