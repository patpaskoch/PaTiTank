-- PaTiTank: saved settings and value normalisation, no WoW API calls (tested in tests/logic_spec.lua).
local _, ns = ...
local Logic = {}
ns.Logic = Logic

Logic.SCHEMA = 1
Logic.SCALES = { 0.8, 0.9, 1, 1.1, 1.25, 1.5 }

Logic.DEFAULTS = {
    locked = false,
    collapsed = false,
    scale = 1,
    language = "auto",
}

-- 0.1.0 saved x, y (CENTER offsets) and locked; they are kept as they are, so the window stays where it was
-- (the PaTiShared window reads a missing point as CENTER). Missing values get defaults; saved false stays false.
function Logic.Migrate(db)
    db = db or {}
    for key, value in pairs(Logic.DEFAULTS) do
        if db[key] == nil then db[key] = value end
    end
    db.schema = Logic.SCHEMA
    return db
end

-- "Restore Defaults": settings back, position kept.
function Logic.RestoreDefaults(db)
    for key, value in pairs(Logic.DEFAULTS) do db[key] = value end
    return db
end

-- Value for the threat bar (0-100). A secret value is returned unchanged: it may only be handed to the
-- StatusBar widget, never compared. nil (no threat data, e.g. no target) becomes 0.
function Logic.ThreatValue(percent, isSecret)
    if isSecret(percent) then return percent end
    if type(percent) ~= "number" then return 0 end
    return math.max(0, math.min(100, percent))
end
