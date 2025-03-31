---@class listener_opt
---@field toast_timeout? number
---@field function_options? FunctionOptions -- Default options for state functions

---@alias args any[]

---@class EventListener
---@field fn? fun(args:args)
---@field state_fn? string -- Key of a stored function in the state
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
---@field functions table<string, function>

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

---@class FunctionOptions
---@field timeout? number -- Timeout setting (currently not enforced due to WezTerm limitations)
---@field safe? boolean -- Whether to use safe execution with error handling (default: true)

---@class FunctionCallResult
---@field success boolean -- Whether the function executed successfully
---@field result any -- The result of the function call (if successful)
---@field error? string -- Error message (if not successful)
---@field timed_out? boolean -- Whether the function timed out

---@class Functions
---@field get fun(key:string): function
---@field set fun(key:string, value:function, options?:FunctionOptions): function
---@field call fun(key:string, ...): any, string? -- Call a function with variable arguments, returns result and error
---@field safecall fun(key:string, ...): FunctionCallResult -- Safe call with full result object
---@field remove fun(key:string)
---@field exists fun(key:string): boolean
---@field get_options fun(key:string): FunctionOptions? -- Get the options for a function

---@class State: InternalState
---@field flags Flags
---@field data Data
---@field counters Counters
---@field functions Functions
