---@class listener_opt
---@field toast_timeout? number

---@alias args any[]

---@class EventListener
---@field fn? fun(args:args)
---@field toast_message? string
---@field toast_arg? number
---@field max_time? number
---@field log_message? string
---@field info? boolean
---@field warn? boolean
---@field error? boolean

---@class EventListeners
---@type table<string, EventListener|EventListener[]>

---@class InternalState
---@field flags table<string, boolean>
---@field data table<string, any>
---@field counters table<string, number>

---@class Flags
---@field get fun(key:string): boolean
---@field set fun(key:string, value: boolean): boolean
---@field toggle fun(key:string): boolean
---@field remove fun(key:string)

---@class Data
---@field get fun(key:string): any
---@field set fun(key:string, value:any): any
---@field remove fun(key:string)

---@class Counters
---@field get fun(key:string): number
---@field set fun(key:string, value?: number): number -- if no value is provided default to 0
---@field increment fun(key:string, increment?: number): number -- if no value is provided default to 1
---@field decrement fun(key:string, decrement?: number): number -- if no value is provided default to 1
---@field remove fun(key:string)

---@class State: InternalState
---@field flags Flags
---@field data Data
---@field counters Counters
