local AddonName, Addon = ...

local _G = _G
local CreateFrame = _G.CreateFrame
local C_NamePlate = _G.C_NamePlate
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local issecure = _G.issecure

local UNIT_TARGET = "target"
local LINE_THICKNESS = 3
local LINE_OFFSET = -10

function Addon:ShowLine()
  if (not self.line:IsVisible()) then
    self.line:Show()
  end
end

function Addon:HideLine()
  if (self.line:IsVisible()) then
    self.line:Hide()
  end
end

function Addon:ToggleLine(visible)
  if (visible) then
    self:ShowLine()
  else
    self:HideLine()
  end
end

function Addon:GetLastUnit()
  return self:GetLastNameplate().namePlateUnitToken or nil
end

function Addon:GetLastNameplate()
  return self.lastNameplate or {}
end

function Addon:AnchorLine(nameplate)
  local lastNameplate = self:GetLastNameplate()

  if (nameplate and (nameplate ~= lastNameplate)) then
    self.line:SetStartPoint("CENTER", self.frame)
    self.line:SetEndPoint("CENTER", nameplate, 0, LINE_OFFSET)

    -- self:ShowLine()

    self.lastNameplate = nameplate
  end

  self:ToggleLine(nameplate ~= nil)
end

function Addon:SetupLine()
  self.line = self.frame:CreateLine()

  self.line:SetThickness(LINE_THICKNESS)
  self.line:SetColorTexture(1, 1, 0, 1)

  self.line:SetStartPoint("CENTER", "UIParent")
end

function Addon:PLAYER_LOGIN()
  self:SetupLine()

  self.frame:UnregisterEvent("PLAYER_LOGIN")
end

function Addon:PLAYER_TARGET_CHANGED()
  local nameplate = GetNamePlateForUnit(UNIT_TARGET, issecure())
  self:AnchorLine(nameplate)
end

function Addon:NAME_PLATE_UNIT_ADDED()
  local nameplate = GetNamePlateForUnit(UNIT_TARGET, issecure())
  self:AnchorLine(nameplate)
end

function Addon:NAME_PLATE_UNIT_REMOVED()
  if (self:GetLastUnit() == nil) then
    self:HideLine()
  end
end

function Addon:OnEvent(event, ...)
  local action = self[event]

  if (action) then
    action(self, ...)
  end
end

do
  local function Frame_OnEvent(frame, ...)
    Addon:OnEvent(...)
  end

  function Addon:Load()
    self.frame = CreateFrame("Frame", nil)
    self.frame:SetPoint("CENTER", "UIParent", "CENTER")

    self.frame:SetHeight(LINE_THICKNESS)
    self.frame:SetWidth(LINE_THICKNESS)

    self.frame:SetScript("OnEvent", Frame_OnEvent)

    self.frame:RegisterEvent("PLAYER_LOGIN")
    self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self.frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  end
end

Addon:Load()
