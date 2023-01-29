local eventsManager = {}
local KattEventAPI = require(FOS_RELATIVE_PATH..".libraries.KattEventsAPI")

function eventsManager.newEventsTable()
    local tbl = KattEventAPI.eventifyTable({})

    tbl.INIT = KattEventAPI.newEvent()

    return tbl
end

return eventsManager