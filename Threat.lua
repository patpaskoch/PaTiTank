-- PaTiTank: threat adapter (the only place with threat/nameplate API calls).
-- Reads the enemies WoW exposes through unit tokens — your target, visible nameplates, your party's targets —
-- and the threat situation of you and your group on each. It never targets or acts. Every value is checked for
-- secrecy before it is compared; anything unreadable becomes Aggro.UNREADABLE (→ state UNKNOWN).
local _, ns = ...
local Aggro = ns.Aggro

local Threat = {}
ns.Threat = Threat

local UNREADABLE = Aggro.UNREADABLE
local GROUP = { "party1", "party2", "party3", "party4", "pet" }
local PARTY_TARGETS = { "party1target", "party2target", "party3target", "party4target" }
local plates = {} -- nameplate tokens currently shown (NAME_PLATE_UNIT_ADDED/REMOVED), so we never loop 1..40

local function isSecret(value) return issecretvalue ~= nil and issecretvalue(value) == true end

-- true/false for a readable yes/no API value (true/false or 1/nil), nil when it is secret.
local function flag(value)
    if isSecret(value) then return nil end
    return value == true or value == 1
end

function Threat.PlateAdded(unit) if type(unit) == "string" then plates[unit] = true end end
function Threat.PlateRemoved(unit) if type(unit) == "string" then plates[unit] = nil end end

-- UnitThreatSituation(unit, enemy): 0-3 or nil; UNREADABLE for secret values, API errors or a missing API.
local function situation(unit, enemy)
    if not UnitThreatSituation then return UNREADABLE end
    local ok, status = pcall(UnitThreatSituation, unit, enemy)
    if not ok or isSecret(status) then return UNREADABLE end
    if status ~= nil and type(status) ~= "number" then return UNREADABLE end
    return status
end

-- A living enemy you could attack. Unreadable → not counted (we do not guess that it is hostile).
local function isEnemy(unit)
    if not (UnitCanAttack and UnitIsDead) then return false end -- APIs missing: show no enemies rather than error
    if flag(UnitExists(unit)) ~= true then return false end
    if flag(UnitCanAttack("player", unit)) ~= true then return false end
    return flag(UnitIsDead(unit)) == false
end

local function role(unit)
    if unit == "pet" then return "PET" end
    local value = UnitGroupRolesAssigned and UnitGroupRolesAssigned(unit)
    if isSecret(value) then return nil end
    if value == "TANK" or value == "HEALER" or value == "DAMAGER" then return value end
    return nil
end

-- Name values are only handed to SetText, never compared; hasName records whether there is one to show.
local function holderOf(member)
    local name = UnitName(member)
    return { unit = member, role = role(member), name = name, hasName = isSecret(name) or name ~= nil }
end

local function readEnemy(unit)
    local enemy = { unit = unit, name = UnitName(unit), playerStatus = situation("player", unit) }
    if enemy.playerStatus == 3 or enemy.playerStatus == 2 then return enemy end -- you hold it: no holder search
    local candidate
    for _, member in ipairs(GROUP) do
        if flag(UnitExists(member)) == true then
            local status = situation(member, unit)
            if status == UNREADABLE then
                enemy.holderUnreadable = true
            elseif status == 3 then
                enemy.holder = holderOf(member)
                return enemy
            elseif status == 2 and not candidate then
                candidate = member
            end
        end
    end
    if candidate then enemy.holder = holderOf(candidate) end
    return enemy
end

-- GUID for de-duplication (the same enemy can be target, nameplate and party target at once); nil if unreadable.
local function guidOf(unit)
    local guid = UnitGUID and UnitGUID(unit)
    if isSecret(guid) then return nil end
    return guid
end

-- All enemies the group fights, each with .state (Aggro.Classify). Called at most every SCAN_DELAY seconds.
function Threat.Scan()
    local enemies, seen = {}, {}
    local function consider(unit, needsGuid)
        if not isEnemy(unit) then return end
        local id = guidOf(unit)
        if id == nil then
            if needsGuid then return end -- could duplicate a nameplate; nameplates already cover it
            id = unit
        end
        if seen[id] then return end
        seen[id] = true
        local enemy = readEnemy(unit)
        enemy.state = Aggro.Classify(enemy)
        if enemy.state then enemies[#enemies + 1] = enemy end
    end
    -- Nameplates first: an enemy that is also your target keeps its nameplate token (Plates.lua marks that plate).
    local hasPlates = next(plates) ~= nil
    for unit in pairs(plates) do consider(unit, false) end
    consider("target", hasPlates)
    for _, unit in ipairs(PARTY_TARGETS) do consider(unit, true) end
    return enemies
end
