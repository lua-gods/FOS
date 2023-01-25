--╔══════════════════════════════════════════════════════════════════════════╗--
--║                                                                          ║--
--║  ██  ██  ██████  ██████   █████    ██    ██████   ████    ████    ████   ║--
--║  ██ ██     ██      ██    ██       ████     ██    ██  ██  ██          ██  ║--
--║  ████      ██      ██    ██       █  █     ██     █████  █████    ████   ║--
--║  ██ ██     ██      ██    ██      ██████    ██        ██  ██  ██  ██      ║--
--║  ██  ██  ██████    ██     █████  ██  ██    ██     ████    ████    ████   ║--
--║                                                                          ║--
--╚══════════════════════════════════════════════════════════════════════════╝--

--v1.4.3

---@alias KattEvent.Subscription {func:function,name:string?}

---@class KattEvent
---@field subscribers KattEvent.Subscription[]
---@field addQueue KattEvent.Subscription[]
---@field removeQueue KattEvent.Subscription[]
---@field piped boolean
---@operator len:number
---@operator call:any?
local KattEvent = {}
local KattEventMetatable = {
  __index = KattEvent,
  __len = function(e)
    return #e.subscribers + #e.addQueue
  end,
  __call = function(self, ...)
    self:invoke(...)
  end,
  __type = "Event",
}

---Creates a new Event.
---@param piped? boolean
---@return KattEvent
function KattEvent.new(piped)
  ---@type KattEvent
  local event = {
    subscribers = {},
    addQueue = {},
    removeQueue = {},
    piped = type(piped) == "boolean" and piped or false,
  }
  setmetatable(event, KattEventMetatable)
  return event
end

---Forces all functions in `register` and `remove` queues to join/leave the main queue.
---Used internally.
function KattEvent:flush()
  for _, func in ipairs(self.removeQueue) do
    for index, sub in ipairs(self.subscribers) do
      if func == sub then
        table.remove(self.subscribers, index)
        break
      end
    end
  end
  while #self.removeQueue > 0 do
    table.remove(self.removeQueue)
  end
  for _, func in ipairs(self.addQueue) do
    table.insert(self.subscribers, func)
  end
  while #self.addQueue > 0 do
    table.remove(self.addQueue)
  end
end

---Invokes the event, calling all it's functions with the given arguments.
---If this is a piped KattEvent, returns the cumulative returns of the subscriber calls.
---@param ... any
---@return any?
function KattEvent:invoke(...)
  self:flush()
  local args = table.pack(...)
  local vargs = table.pack(...)
  for _, subscription in ipairs(self.subscribers) do
    vargs = table.pack(subscription.func(table.unpack(self.piped and vargs or args, 1, args.n)))
  end
  if self.piped then return table.unpack(vargs) end
end

---Registers the given function to the given event. When the event is invoked, the function will be run.
---Functions are run in the order they were registered. The optional name parameter is used when you wish to later remove a function from the event.
---@param func function
---@param name string?
function KattEvent:register(func, name)
  if type(func) ~= "function" then error('argument "func" must be a function.', 2) end
  if name ~= nil and type(name) ~= "string" then error('argument "name" must be a string or nil.', 2) end
  table.insert(self.addQueue, {func = func, name = name})
end

---Removes all of the functions with the given name from the Event.
---@param name string
---@return integer
function KattEvent:remove(name)
  if not name then error("KattEvent:remove does not allow nil values, expected string.", 2) end
  local removed = 0
  for _, sub in ipairs(self.subscribers) do
    if sub.name == name then
      table.insert(self.removeQueue, sub)
      removed = removed + 1
    end
  end
  return removed
end

---Clears the given event of all it's functions.
function KattEvent:clear()
  while #self.subscribers > 0 do
    table.remove(self.subscribers)
  end
  while #self.addQueue > 0 do
    table.remove(self.addQueue)
  end
  while #self.removeQueue > 0 do
    table.remove(self.removeQueue)
  end
end

---@deprecated
function KattEvent:runOnce()
  error("KattEvent:runOnce is deprecated and does not function.", 2)
end

---Adds the necessary metatable functionality for a table to behave like the `events` global.
---@param tbl table
---@return table
local function eventifyTable(tbl)
  return setmetatable({}, {
    __index = function(t, i)
      if type(i) == "string" then
        local eStr = i:upper()
        if type(tbl[eStr]) == "Event" then
          return tbl[eStr]
        end
      end
      return tbl[i]
    end,
    __newindex = function(t, i, v)
      if type(i) == "string" then
        local eStr = i:upper()
        if type(v) == "Event" then
          tbl[eStr] = v
          return
        elseif type(tbl[eStr]) == "Event" then
          if type(v) ~= "function" then error(("Cannot register non-functions to Event %s."):format(eStr)
            , 2) end
          tbl[eStr]:register(v)
          return
        end
      end
      tbl[i] = v
    end,
    __pairs = function(t)
      return pairs(tbl)
    end,
    __ipairs = function(t)
      return ipairs(tbl)
    end,
  })
end

---@class KattEvent.API
local KattEventsAPI = {
  newEvent = KattEvent.new,
  eventifyTable = eventifyTable,
  ---@deprecated
  ---The returned table is no longer a KattEvent. use the `newEvent` function indexed through this table.
  new = function()
    error("This is no longer a KattEvent. You can get an event through the `newEvent` function indexed through this table."
      , 2)
  end,
}
return KattEventsAPI
