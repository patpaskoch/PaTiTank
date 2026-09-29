-- PaTiTank: a small "!" above the nameplate of an enemy you lost (red) or barely hold (yellow).
-- Why: a row in the aggro panel cannot target in combat — which enemy a row shows is decided by addon code, and
-- WoW forbids re-pointing, moving or showing secure buttons in combat (docs/WOW_API_COMPAT.md, FOLLOW_UPS F17).
-- The normal nameplate can: the player clicks it, Blizzard's own click targets exactly that enemy.
-- Display only: Blizzard's plates are never changed. Our own small frame is a child of the plate (so it moves and
-- hides with it); forbidden plates and missing APIs are skipped.
local _, ns = ...
local UI = ns.UI

local Plates = {}
ns.Plates = Plates

local markers = {} -- plate frame -> our marker frame

local function plateOf(unit)
    if not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) or type(unit) ~= "string" then return nil end
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if not ok or type(plate) ~= "table" then return nil end
    if plate.IsForbidden then
        local checked, forbidden = pcall(plate.IsForbidden, plate)
        if not checked or forbidden then return nil end
    end
    return plate
end

local function markerFor(plate)
    if markers[plate] then return markers[plate] end
    local ok, marker = pcall(CreateFrame, "Frame", nil, plate)
    if not ok or not marker then return nil end
    marker:SetSize(18, 22)
    marker:SetPoint("BOTTOM", plate, "TOP", 0, 2)
    marker.text = marker:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    marker.text:SetPoint("CENTER")
    marker.text:SetText("!")
    marker:Hide()
    markers[plate] = marker
    return marker
end

-- enemies: Threat.Scan() result (each with .unit and .state). LOST wins over DANGER on the same plate.
function Plates.Update(enemies, enabled)
    local wanted = {}
    if enabled then
        for _, enemy in ipairs(enemies) do
            if enemy.state == "LOST" or enemy.state == "DANGER" then
                local plate = plateOf(enemy.unit)
                if plate and wanted[plate] ~= "LOST" then wanted[plate] = enemy.state end
            end
        end
    end
    for plate in pairs(wanted) do markerFor(plate) end
    for plate, marker in pairs(markers) do
        local state = wanted[plate]
        if state then marker.text:SetTextColor(UI.Color(state == "LOST" and "Danger" or "Warning")) end
        marker:SetShown(state ~= nil)
    end
end

-- A plate got a new unit (NAME_PLATE_UNIT_ADDED) or loses its unit (…_REMOVED): its old marker must not stay on
-- the next enemy. Called synchronously from the event, before the next scan decides again.
function Plates.Clear(unit)
    local plate = plateOf(unit)
    if plate and markers[plate] then markers[plate]:Hide() end
end

function Plates.HideAll()
    for _, marker in pairs(markers) do marker:Hide() end
end
