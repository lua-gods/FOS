local eventsManager = {}
local KattEventAPI = require(FOS_RELATIVE_PATH..".libraries.KattEventsAPI")

function eventsManager.newEventsTable()
    local tbl = KattEventAPI.eventifyTable({})

    tbl.INIT = KattEventAPI.newEvent()
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

function events.world_render(delta)
    if SYSTEM_REGISTRY.disable_system then
        return
    end

    eventsManager.runEvent("RENDER", delta)
end

return eventsManager