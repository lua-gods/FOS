local eventsManager = {}
local KattEventAPI = require(FOS_RELATIVE_PATH..".libraries.KattEventsAPI")

function eventsManager.newEventsTable()
    local tbl = KattEventAPI.eventifyTable({})

    tbl.OPEN = KattEventAPI.newEvent()
    tbl.CLOSE = KattEventAPI.newEvent()
    tbl.KEY_PRESS = KattEventAPI.newEvent()
    tbl.POST_KEY_PRESS = KattEventAPI.newEvent()
    tbl.TICK = KattEventAPI.newEvent()
    tbl.RENDER = KattEventAPI.newEvent()

    return tbl
end

function eventsManager.runEvent(event_name, ...)
    APP.app.events[event_name](...)
end

function events.tick()
    if SYSTEM_REGISTRY.disable_system then
        return
    end

    eventsManager.runEvent("TICK")
end

function events.render(delta, context)
    if SYSTEM_REGISTRY.disable_system then
        return
    end

    if context == "FIRST_PERSON" or context == "RENDER" then
        eventsManager.runEvent("RENDER", delta)
    end
end

return eventsManager