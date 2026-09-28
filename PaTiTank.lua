-- PaTiTank: own health, current target and your threat on it. Display only; no secure frames.
local addonName, ns = ...
local UI, L, Logic = ns.UI, ns.UI.L, ns.Logic

local DB
local testMode = false

local WIDTH, BAR_WIDTH, PAD, LINE = 280, 252, UI.Spacing.MD, 18
local HEALTH_HEIGHT, THREAT_HEIGHT = 22, 16
local TEST = { health = 68, threat = 72 } -- test mode values in percent

local function say(key, ...)
    print("|cff68caffPaTiTank:|r " .. L[key]:format(...))
end

local function isSecret(value) return issecretvalue ~= nil and issecretvalue(value) == true end

local function addonVersion()
    local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    return getMetadata and getMetadata(addonName, "Version") or "?"
end

-- Window ---------------------------------------------------------------------------------------

local window = UI.CreateWindow("PaTiTankFrame", "PaTiTank", WIDTH, 120)
local content = CreateFrame("Frame", nil, window) -- everything below the header; hidden when collapsed
content:SetPoint("TOPLEFT", 0, -UI.Sizes.HeaderHeight)
content:SetPoint("BOTTOMRIGHT")

-- Target line: label + name. The name goes straight to SetText (it may be a secret value).
local targetLabel = content:CreateFontString(nil, "OVERLAY", UI.Fonts.Muted)
targetLabel:SetPoint("TOPLEFT", PAD, -UI.Spacing.SM - 2)
UI.BindText(targetLabel, "TARGET")
local targetName = content:CreateFontString(nil, "OVERLAY", UI.Fonts.Text)
targetName:SetPoint("LEFT", targetLabel, "RIGHT", UI.Spacing.SM, 0)
targetName:SetPoint("RIGHT", content, "RIGHT", -PAD, 0)
targetName:SetJustifyH("LEFT")
targetName:SetWordWrap(false)

local function makeBar(top, height, color, labelKey)
    local background = content:CreateTexture(nil, "BACKGROUND")
    background:SetPoint("TOPLEFT", PAD, -top)
    background:SetSize(BAR_WIDTH, height)
    background:SetColorTexture(UI.Color("Panel"))
    local bar = CreateFrame("StatusBar", nil, content)
    bar:SetPoint("TOPLEFT", PAD, -top)
    bar:SetSize(BAR_WIDTH, height)
    bar:SetStatusBarTexture(UI.WHITE)
    bar:SetStatusBarColor(UI.Color(color))
    local label = bar:CreateFontString(nil, "OVERLAY", UI.Fonts.Text)
    label:SetPoint("CENTER")
    UI.BindText(label, labelKey)
    return bar
end

local healthTop = UI.Spacing.SM + LINE + UI.Spacing.SM
local threatTop = healthTop + HEALTH_HEIGHT + UI.Spacing.MD
local health = makeBar(healthTop, HEALTH_HEIGHT, "Health", "OWN_HEALTH")
local threat = makeBar(threatTop, THREAT_HEIGHT, "Danger", "THREAT")
threat:SetMinMaxValues(0, 100)
local FULL_HEIGHT = UI.Sizes.HeaderHeight + threatTop + THREAT_HEIGHT + PAD

-- Paint (health and threat values may be secret: they only reach StatusBar widgets) --------------

local function paintHealth()
    if testMode then
        health:SetMinMaxValues(0, 100)
        health:SetValue(TEST.health)
        return
    end
    health:SetMinMaxValues(0, UnitHealthMax("player"))
    health:SetValue(UnitHealth("player"))
end

local function paintTarget()
    if testMode then
        targetName:SetText(L.TEST_TARGET)
        threat:SetValue(TEST.threat)
    elseif UnitExists("target") then
        targetName:SetText(UnitName("target"))
        local _, _, percent = UnitDetailedThreatSituation("player", "target")
        threat:SetValue(Logic.ThreatValue(percent, isSecret))
    else
        targetName:SetText(L.NO_TARGET)
        threat:SetValue(0)
    end
end

local function paintAll()
    if not DB then return end
    paintHealth()
    paintTarget()
end

local function applyLayout()
    content:SetShown(not DB.collapsed)
    window:SetHeight(DB.collapsed and UI.Sizes.HeaderHeight or FULL_HEIGHT)
    window:SetTestMode(testMode)
end

-- Settings -------------------------------------------------------------------------------------

local modal

local function buildSettings()
    modal = UI.CreateModal("PaTiTankSettings", function() return "PaTiTank " .. L.SETTINGS end, 380)
    local scales = {}
    for _, scale in ipairs(Logic.SCALES) do
        scales[#scales + 1] = { value = scale, text = function() return ("%d %%"):format(scale * 100 + 0.5) end }
    end
    modal:AddSection("GENERAL")
    modal:AddRow("LANGUAGE", UI.CreateLanguageDropdown(modal, DB, 170))
    modal:AddRow("SCALE", UI.CreateDropdown(modal, 170, {
        items = function() return scales end,
        get = function() return DB.scale end,
        set = function(scale) DB.scale = scale; window:SetScale(scale) end,
    }))
    modal:AddControls(UI.CreateCheckbox(modal, "LOCK_WINDOW", {
        get = function() return window:IsLocked() end,
        set = function(locked) window:SetLocked(locked) end,
    }))
    modal:Finish(function()
        Logic.RestoreDefaults(DB)
        UI.SetLanguage(DB.language)
        window:SetLocked(DB.locked)
        window:SetScale(DB.scale)
        applyLayout()
        paintAll()
    end)
end

local function openSettings()
    if not modal then buildSettings() end
    modal:Show()
end

-- Commands -------------------------------------------------------------------------------------

local function toggleTestMode()
    testMode = not testMode
    applyLayout()
    paintAll()
end

local function toggleCollapsed()
    DB.collapsed = not DB.collapsed
    applyLayout()
end

local function setShown(shown)
    window:SetShown(shown)
    if not shown then say("HIDDEN_HINT") end
end

local function resetPosition()
    DB.point, DB.relativePoint, DB.x, DB.y = nil, nil, nil, nil
    window:Attach(DB, -330, 0)
end

local function printDebug()
    local version, build, _, interface = GetBuildInfo()
    print("|cff68caffPaTiTank Debug:|r")
    for _, line in ipairs({
        ("Addon %s %s · PaTiShared UI %s"):format(addonName, addonVersion(), tostring(UI.VERSION)),
        ("WoW %s (build %s, interface %s) · locale %s · UI language %s"):format(tostring(version), tostring(build),
            tostring(interface), GetLocale(), UI.GetLanguage()),
        ("Threat API %s · issecretvalue %s · combat %s · test mode %s"):format(
            UnitDetailedThreatSituation and "yes" or "no", issecretvalue and "yes" or "no",
            InCombatLockdown() and "yes" or "no", testMode and "on" or "off"),
    }) do print("  " .. line) end
end

local COMMANDS = {
    [""] = function() setShown(not window:IsShown()) end,
    show = function() setShown(true) end,
    hide = function() setShown(false) end,
    test = toggleTestMode,
    lock = function() window:SetLocked(true) end,
    unlock = function() window:SetLocked(false) end,
    reset = resetPosition,
    settings = openSettings,
    debug = printDebug,
    version = function() say("VERSION", addonVersion()) end,
}

SLASH_PATITANK1 = "/patitank"
SLASH_PATITANK2 = "/pt"
SlashCmdList.PATITANK = function(message)
    local command = COMMANDS[(message or ""):match("^%s*(.-)%s*$"):lower()]
    if command and DB then command() else say("HELP") end
end

window:SetMenu(function()
    if not DB then return {} end
    return {
        { text = "SETTINGS", onClick = openSettings },
        { text = window:IsLocked() and "UNLOCK" or "LOCK", onClick = function() window:SetLocked(not window:IsLocked()) end },
        { text = DB.collapsed and "EXPAND" or "COLLAPSE", onClick = toggleCollapsed },
        { text = "TEST_MODE", checked = testMode, onClick = toggleTestMode },
        { text = "HIDE", onClick = function() setShown(false) end },
    }
end)

-- Events ---------------------------------------------------------------------------------------

local events = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UNIT_HEALTH", "UNIT_MAXHEALTH",
    "PLAYER_TARGET_CHANGED", "UNIT_THREAT_LIST_UPDATE", "UNIT_THREAT_SITUATION_UPDATE" }) do
    events:RegisterEvent(event)
end

events:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_LOGIN" then
        PaTiTankDB = Logic.Migrate(PaTiTankDB)
        DB = PaTiTankDB
        UI.SetLanguage(DB.language)
        window:Attach(DB, -330, 0)
        window:SetScale(DB.scale)
        applyLayout()
        paintAll()
    elseif not DB or testMode then
        return
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        if unit == "player" then paintHealth() end -- hot path: every unit fires this; only yours matters
    elseif event == "PLAYER_ENTERING_WORLD" then
        paintAll()
    else -- target changed or threat changed
        paintTarget()
    end
end)
UI.OnLanguageChanged(paintAll)
