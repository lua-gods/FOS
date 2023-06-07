local eventsManager = {}
local KattEventAPI = require(FOS_RELATIVE_PATH..".libraries.KattEventsAPI")

function eventsManager.newEventsTable()
    local tbl = KattEventAPI.eventifyTable({})

    tbl.OPEN = KattEventAPI.newEvent()
    tbl.CLOSE = KattEventAPI.newEvent()
    tbl.KEY_PRESS = KattEventAPI.newEvent()
    tbl.POST_KEY_PRESS = KattEventAPI.newEvent()
    tbl.KEYBOARD = KattEventAPI.newEvent()
    tbl.TICK = KattEventAPI.newEvent()
    tbl.RENDER = KattEventAPI.newEvent()

    return tbl
end

function eventsManager.runEvent(event_name, ...)
    if APP.app and APP.app.events then
        local success, err = pcall(APP.app.events[event_name], ...)
        if not success then
            if APP.app.id ~= SYSTEM_REGISTRY.error_app then
                APP.open(SYSTEM_REGISTRY.error_app, "app crashed:\n"..(APP.app.display_name or APP.app.id).."\n\npress enter to go to home screen\npress up to print\nerror\n\n"..tostring(err), tostring(err))
            end
        end
    end
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