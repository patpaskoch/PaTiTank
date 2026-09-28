-- PaTiTank settings and threat value. Run via PaTiAdmin/tools/check.sh.
local wow = require("wow_api")

local function load()
    return wow.loadAddonFile("Logic.lua", {}).Logic
end

describe("Logic.Migrate", function()
    it("creates defaults for a new character", function()
        local db = load().Migrate(nil)
        assert.is_false(db.locked)
        assert.is_false(db.collapsed)
        assert.equal(1, db.scale)
        assert.equal("auto", db.language)
        assert.equal(1, db.schema)
    end)

    it("keeps the 0.1.0 position and lock state", function()
        local db = load().Migrate({ x = -330, y = 12, locked = true })
        assert.equal(-330, db.x)
        assert.equal(12, db.y)
        assert.is_true(db.locked)
        assert.is_nil(db.point) -- read as CENTER by the window, same as 0.1.0
    end)

    it("keeps saved false values", function()
        local db = load().Migrate({ schema = 1, locked = false, collapsed = false, scale = 1.25, language = "deDE" })
        assert.is_false(db.locked)
        assert.equal(1.25, db.scale)
        assert.equal("deDE", db.language)
    end)
end)

describe("Logic.RestoreDefaults", function()
    it("resets settings and keeps the position", function()
        local db = load().RestoreDefaults({ x = 5, y = 6, locked = true, scale = 1.5, collapsed = true })
        assert.is_false(db.locked)
        assert.is_false(db.collapsed)
        assert.equal(1, db.scale)
        assert.equal(5, db.x)
    end)
end)

describe("Logic.ThreatValue", function()
    local never = function() return false end

    it("clamps readable values to 0-100 and turns missing data into 0", function()
        local Logic = load()
        assert.equal(72, Logic.ThreatValue(72, never))
        assert.equal(100, Logic.ThreatValue(130, never))
        assert.equal(0, Logic.ThreatValue(nil, never))
    end)

    it("passes a secret value through without comparing it", function()
        local function trap() error("secret value was compared") end
        local secret = setmetatable({}, { __lt = trap, __le = trap })
        local isSecret = function(value) return rawequal(value, secret) end
        assert.is_true(rawequal(secret, load().ThreatValue(secret, isSecret)))
    end)
end)

describe("Collapse state", function()
    it("a saved collapsed = true stays; Restore Defaults expands (documented) and keeps the position", function()
        local Logic = load()
        local db = Logic.Migrate({ x = 7, collapsed = true })
        assert.is_true(db.collapsed)
        Logic.RestoreDefaults(db)
        assert.is_false(db.collapsed)
        assert.equal(7, db.x)
    end)
end)
