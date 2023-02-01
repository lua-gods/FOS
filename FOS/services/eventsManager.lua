local eventsManager = {}
local KattEventAPI = require(FOS_RELATIVE_PATH..".libraries.KattEventsAPI")

function eventsManager.newEventsTable()
    local tbl = KattEventAPI.eventifyTable({})

    tbl.INIT = KattEventAPI.newEvent()
    tbl.KEY_PRESS = KattEventAPI.newEvent()
    tbl.TICK = KattEventAPI.newEvent()

    return tbl
end

function eventsManager.runEvent(event_name, ...)
    APP.app.events[event_name](...)
end

function events.tick()
    eventsManager.runEvent("TICK")
end

return eventsManager