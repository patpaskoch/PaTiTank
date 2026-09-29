-- PaTiTank nameplate markers with mocked plates. Run via PaTiAdmin/tools/check.sh. Frames are plain tables here;
-- whether WoW draws them on real nameplates is a manual test.
local wow = require("wow_api")

local function newFrame()
    local frame = { shown = true }
    function frame:SetSize() end
    function frame:SetPoint() end
    function frame:Hide() self.shown = false end
    function frame:Show() self.shown = true end
    function frame:SetShown(shown) self.shown = shown and true or false end
    function frame:CreateFontString()
        local text = {}
        text.SetPoint = function() end
        text.SetText = function(fontString, value) fontString.value = value end
        text.SetTextColor = function(fontString, r) fontString.red = r end
        return text
    end
    return frame
end

local plates, created

local function setup()
    wow.install()
    plates, created = {}, {}
    _G.C_NamePlate = { GetNamePlateForUnit = function(unit) return plates[unit] end }
    _G.CreateFrame = function(_, _, parent)
        local frame = newFrame()
        frame.parent = parent
        created[#created + 1] = frame
        return frame
    end
    local ns = { UI = { Color = function(name) return name == "Danger" and 1 or 0.5, 0, 0, 1 end } }
    return wow.loadAddonFile("Plates.lua", ns).Plates
end

local function plate(forbidden)
    local frame = newFrame()
    function frame:IsForbidden() return forbidden == true end
    return frame
end

local function markerOn(frame)
    for _, marker in ipairs(created) do
        if marker.parent == frame then return marker end
    end
end

describe("Plates", function()
    it("marks lost (red) and barely held enemies on their own plate, nothing for controlled or unknown", function()
        local Plates = setup()
        plates.nameplate1, plates.nameplate2, plates.nameplate3 = plate(), plate(), plate()
        Plates.Update({ { unit = "nameplate1", state = "LOST" }, { unit = "nameplate2", state = "DANGER" },
            { unit = "nameplate3", state = "CONTROLLED" }, { unit = "nameplate4", state = "UNKNOWN" } }, true)
        assert.is_true(markerOn(plates.nameplate1).shown)
        assert.equal(1, markerOn(plates.nameplate1).text.red)
        assert.is_true(markerOn(plates.nameplate2).shown)
        assert.equal(0.5, markerOn(plates.nameplate2).text.red)
        assert.is_nil(markerOn(plates.nameplate3))
    end)

    it("hides a marker when the enemy is controlled again, the plate is reused, or marking is off", function()
        local Plates = setup()
        plates.nameplate1 = plate()
        Plates.Update({ { unit = "nameplate1", state = "LOST" } }, true)
        local marker = markerOn(plates.nameplate1)
        Plates.Update({ { unit = "nameplate1", state = "CONTROLLED" } }, true)
        assert.is_false(marker.shown)
        Plates.Update({ { unit = "nameplate1", state = "LOST" } }, true)
        Plates.Clear("nameplate1") -- NAME_PLATE_UNIT_ADDED/REMOVED
        assert.is_false(marker.shown)
        Plates.Update({ { unit = "nameplate1", state = "LOST" } }, false)
        assert.is_false(marker.shown)
    end)

    it("never touches forbidden plates and survives a missing nameplate API", function()
        local Plates = setup()
        plates.nameplate1 = plate(true)
        Plates.Update({ { unit = "nameplate1", state = "LOST" } }, true)
        assert.equal(0, #created)
        _G.C_NamePlate = nil
        Plates.Update({ { unit = "nameplate1", state = "LOST" } }, true)
        Plates.Clear("nameplate1")
        assert.equal(0, #created)
    end)
end)
