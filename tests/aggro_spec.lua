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
