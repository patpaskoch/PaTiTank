local DB
local testMode=false
local frame=CreateFrame("Frame","PaTiTankFrame",UIParent,"BackdropTemplate")
frame:SetSize(280,142); frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
frame:SetBackdrop({ bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=12, insets={left=3,right=3,top=3,bottom=3} })
local title=frame:CreateFontString(nil,"OVERLAY","GameFontNormal"); title:SetPoint("TOPLEFT",14,-12); title:SetText("PaTiTank")
local targetText=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); targetText:SetPoint("TOPLEFT",14,-38)
local health=CreateFrame("StatusBar",nil,frame); health:SetPoint("TOPLEFT",14,-58); health:SetSize(252,22); health:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8"); health:SetStatusBarColor(0.2,0.62,0.3,1)
local healthLabel=health:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); healthLabel:SetPoint("CENTER"); healthLabel:SetText("Eigene Gesundheit")
local threat=CreateFrame("StatusBar",nil,frame); threat:SetPoint("TOPLEFT",14,-91); threat:SetSize(252,16); threat:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8"); threat:SetStatusBarColor(0.85,0.3,0.12,1); threat:SetMinMaxValues(0,100)
local threatLabel=threat:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); threatLabel:SetPoint("CENTER"); threatLabel:SetText("Bedrohung auf Ziel")
local note=frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall"); note:SetPoint("BOTTOMLEFT",14,12); note:SetText("/pt test | /pt lock | /pt unlock")
title:Hide()
PaTiSharedPanel.Attach(frame,"PaTiTank",{targetText,health,threat,note},"/pt test zeigt die Vorschau.\n/pt lock und /pt unlock sperren das Fenster.")
local function update()
 if testMode then health:SetMinMaxValues(0,100); health:SetValue(68); threat:SetValue(72); targetText:SetText("Ziel: Testgegner"); return end
 local max=UnitHealthMax("player"); health:SetMinMaxValues(0,max); health:SetValue(UnitHealth("player"))
 if UnitExists("target") then
   targetText:SetText("Ziel: " .. (UnitName("target") or "Unbekannt"))
   local _,_,percent=UnitDetailedThreatSituation("player","target"); if percent then threat:SetValue(percent) else threat:SetValue(0) end
 else targetText:SetText("Kein Ziel ausgewaehlt"); threat:SetValue(0) end
end
frame:SetScript("OnDragStart",function(self) if not DB.locked then self:StartMoving() end end)
frame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing(); local _,_,_,x,y=self:GetPoint(); DB.x=x; DB.y=y end)
local events=CreateFrame("Frame"); for _,event in ipairs({"PLAYER_LOGIN","PLAYER_ENTERING_WORLD","UNIT_HEALTH","PLAYER_TARGET_CHANGED","UNIT_THREAT_LIST_UPDATE","UNIT_THREAT_SITUATION_UPDATE"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent",function(_,event) if event=="PLAYER_LOGIN" then PaTiTankDB=PaTiTankDB or {}; DB=PaTiTankDB; DB.x=DB.x or -330; DB.y=DB.y or 0; DB.locked=DB.locked or false; frame:ClearAllPoints(); frame:SetPoint("CENTER",UIParent,"CENTER",DB.x,DB.y) end; update() end)
SLASH_PATITANK1="/patitank"; SLASH_PATITANK2="/pt"; SlashCmdList.PATITANK=function(message) local c=(message or ""):match("^%s*(.-)%s*$"):lower(); if c=="test" then testMode=not testMode; update() elseif c=="show" then frame:Show() elseif c=="hide" then frame:Hide() elseif c=="lock" then DB.locked=true elseif c=="unlock" then DB.locked=false else print("|cff68caffPaTiTank:|r /pt test, show, hide, lock, unlock") end end
