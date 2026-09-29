-- PaTiTank aggro control rules. Run via PaTiAdmin/tools/check.sh.
local wow = require("wow_api")

local function load()
    return wow.loadAddonFile("Aggro.lua", {}).Aggro
end

describe("Aggro.Classify", function()
    it("maps your threat situation to controlled / danger", function()
        local Aggro = load()
        assert.equal("CONTROLLED", Aggro.Classify({ playerStatus = 3 }))
        assert.equal("DANGER", Aggro.Classify({ playerStatus = 2 }))
    end)

    it("is LOST when a group member holds it, also if you never touched it", function()
        local Aggro = load()
        assert.equal("LOST", Aggro.Classify({ playerStatus = 0, holder = { role = "HEALER" } }))
        assert.equal("LOST", Aggro.Classify({ playerStatus = nil, holder = { role = "HEALER" } }))
        assert.equal("LOST", Aggro.Classify({ playerStatus = 1 })) -- held by someone outside the group
    end)

    it("never turns unreadable data into CONTROLLED", function()
        local Aggro = load()
        assert.equal("UNKNOWN", Aggro.Classify({ playerStatus = Aggro.UNREADABLE }))
        assert.equal("UNKNOWN", Aggro.Classify({ playerStatus = nil, holderUnreadable = true }))
    end)

    it("ignores enemies nobody of the group fights", function()
        assert.is_nil(load().Classify({ playerStatus = nil }))
    end)
end)

describe("Aggro.Summarize", function()
    it("counts held enemies and lists LOST before DANGER before UNKNOWN", function()
        local Aggro = load()
        local enemies = {
            { name = "a", state = "CONTROLLED" }, { name = "b", state = "UNKNOWN" }, { name = "c", state = "DANGER" },
            { name = "d", state = "LOST" }, { name = "e", state = "CONTROLLED" }, { name = "f", state = "LOST" },
            { name = "g" }, -- not our fight
        }
        local summary = Aggro.Summarize(enemies)
        assert.equal(3, summary.held)  -- 2 controlled + 1 danger
        assert.equal(6, summary.total)
        local names = {}
        for _, enemy in ipairs(summary.rows) do names[#names + 1] = enemy.name end
        assert.same({ "d", "f", "c", "b" }, names)
    end)

    it("is empty without enemies", function()
        assert.same({ held = 0, total = 0, rows = {} }, load().Summarize({}))
    end)
end)

describe("Aggro.HolderLabel", function()
    it("prefers the role, then the name, then 'other player'", function()
        local Aggro = load()
        assert.equal("ROLE_HEALER", Aggro.HolderLabel({ role = "HEALER", hasName = true }))
        assert.equal("NAME", Aggro.HolderLabel({ hasName = true }))
        assert.equal("OTHER", Aggro.HolderLabel({}))
        assert.equal("OTHER", Aggro.HolderLabel(nil))
    end)
end)

describe("Aggro.Number", function()
    local function row(unit, guid, state) return { unit = unit, guid = guid, state = state or "LOST" } end

    it("numbers the visible problem rows with their own nameplate, in row order", function()
        local Aggro = load()
        local numbers = Aggro.Number({ row("nameplate4", "A"), row("nameplate2", "B", "DANGER"),
            row("nameplate7", "C", "UNKNOWN") }, {})
        assert.same({ 1, 2, 3 }, numbers)
    end)

    it("gives no number to a row without a nameplate token, and none to two rows sharing a token", function()
        local Aggro = load()
        assert.same({ [1] = 1 }, (Aggro.Number({ row("nameplate1", "A"), row("target", "B"), row(nil, nil) }, {})))
        local numbers = Aggro.Number({ row("nameplate1", "A"), row("nameplate1", nil), row("nameplate2", "C") }, {})
        assert.is_nil(numbers[1])
        assert.is_nil(numbers[2])
        assert.equal(1, numbers[3])
    end)

    it("keeps an enemy's number while it stays visible, also when the row order changes", function()
        local Aggro = load()
        local _, map = Aggro.Number({ row("nameplate1", "A"), row("nameplate2", "B") }, {})
        assert.same({ A = 1, B = 2 }, map)
        local numbers = Aggro.Number({ row("nameplate2", "B"), row("nameplate1", "A") }, map) -- B now sorts first
        assert.same({ 2, 1 }, numbers)
    end)

    it("reuses freed numbers, forgets enemies that left, never keeps a number above MAX_ROWS", function()
        local Aggro = load()
        local numbers, map = Aggro.Number({ row("nameplate3", "C"), row("nameplate9", "N") }, { A = 1, C = 2, X = 9 })
        assert.same({ 2, 1 }, numbers) -- C keeps 2, the new enemy takes the free 1
        assert.same({ C = 2, N = 1 }, map)
        assert.same({ 1 }, (Aggro.Number({ row("nameplate1", "X") }, { X = 9 })))
    end)

    it("keeps no number for enemies without a readable GUID", function()
        local _, map = load().Number({ row("nameplate1", nil) }, {})
        assert.same({}, map)
    end)
end)
