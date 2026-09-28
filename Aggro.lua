-- PaTiTank: aggro control rules, no WoW API calls (tested in tests/aggro_spec.lua).
-- Answers one question: which enemies do I not hold any more? Display only — no target, no taunt.
local _, ns = ...
local Aggro = {}
ns.Aggro = Aggro

-- Sentinel the threat adapter uses for any value it could not read safely (secret value, API error).
Aggro.UNREADABLE = {}
Aggro.MAX_ROWS = 4 -- problem rows shown under the summary

-- UnitThreatSituation(you, enemy): 3 = you tank securely, 2 = you tank but someone has more threat,
-- 1/0 = someone else tanks, nil = you are not on the enemy's threat list.
-- enemy = { playerStatus = 0-3 | nil | UNREADABLE, holder = { role?, name? } | nil, holderUnreadable = bool }
-- Returns "CONTROLLED" | "DANGER" | "LOST" | "UNKNOWN", or nil when nobody of the group fights it.
function Aggro.Classify(enemy)
    local status = enemy.playerStatus
    if status == Aggro.UNREADABLE then return "UNKNOWN" end -- never guess "controlled"
    if status == 3 then return "CONTROLLED" end
    if status == 2 then return "DANGER" end
    if enemy.holder then return "LOST" end
    if enemy.holderUnreadable then return "UNKNOWN" end
    if status == 0 or status == 1 then return "LOST" end -- someone outside your group (or unseen) holds it
    return nil
end

local ORDER = { LOST = 1, DANGER = 2, UNKNOWN = 3 }

-- enemies: list with .state set. Returns { held, total, rows = { enemy, … } } — held = CONTROLLED + DANGER
-- (you still have them), rows = the enemies that need attention: LOST first, then DANGER, then UNKNOWN.
function Aggro.Summarize(enemies)
    local summary = { held = 0, total = 0, rows = {} }
    for index, enemy in ipairs(enemies) do
        if enemy.state then
            summary.total = summary.total + 1
            if enemy.state == "CONTROLLED" or enemy.state == "DANGER" then summary.held = summary.held + 1 end
            if ORDER[enemy.state] then summary.rows[#summary.rows + 1] = { enemy = enemy, index = index } end
        end
    end
    table.sort(summary.rows, function(a, b)
        local oa, ob = ORDER[a.enemy.state], ORDER[b.enemy.state]
        if oa ~= ob then return oa < ob end
        return a.index < b.index -- stable: keep the adapter's order within a state
    end)
    for index, row in ipairs(summary.rows) do summary.rows[index] = row.enemy end
    return summary
end

-- What to show for the member holding a lost enemy: a role key, "NAME" (show holder.name as-is) or "OTHER".
-- Role first (quickest to read), then name, then "other player".
function Aggro.HolderLabel(holder)
    if not holder then return "OTHER" end
    if holder.role == "TANK" or holder.role == "HEALER" or holder.role == "DAMAGER" or holder.role == "PET" then
        return "ROLE_" .. holder.role
    end
    if holder.hasName then return "NAME" end
    return "OTHER"
end
