-- PaTiTank strings, English (source and fallback). One key per line: L.KEY = "Text".
local _, ns = ...
ns.Locales = ns.Locales or {}
local L = ns.Locales.enUS or {}
ns.Locales.enUS = L

L.TARGET = "Target:"
L.NO_TARGET = "No target selected"
L.OWN_HEALTH = "Own health"
L.THREAT = "Threat on target"
L.TEST_TARGET = "Test enemy"
L.LOCK_WINDOW = "Lock window"
L.SCALE = "Scale"
L.HIDDEN_HINT = "hidden. /pt show brings it back."
L.HELP = "/pt show, hide, test, lock, unlock, reset, settings, debug, version"
L.VERSION = "version %s"
