local AddonName, Addon = ...

local select = select
local unpack = unpack

local _G = _G
local CreateFrame = _G.CreateFrame
local UnitClass = _G.UnitClass
local UnitIsPlayer = _G.UnitIsPlayer
local issecure = _G.issecure
local GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit

local UNIT_TARGET = "target"
local LINE_THICKNESS = 3
local LINE_OFFSET = -25
local DEFAULT_LINE_COLOR = {.5, .5, .5, 1}

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

function Addon:GetNamePlateUnit()
  return self:GetNamePlate().namePlateUnitToken or nil
end

function Addon:GetNamePlate()
  return self.namePlate or {}
end

function Addon:AnchorLine(namePlate)
  if (namePlate and (self:GetNamePlate() ~= namePlate)) then
    self.line:SetStartPoint("CENTER", self.frame)
    self.line:SetEndPoint("CENTER", namePlate, 0, LINE_OFFSET)
  end
end

function Addon:SetupLine()
  self.line = self.frame:CreateLine()

  self.line:SetThickness(LINE_THICKNESS)
  self.line:SetColorTexture(unpack(DEFAULT_LINE_COLOR))

  self.line:SetStartPoint("CENTER", "UIParent")
end

function Addon:PLAYER_LOGIN()
  self:SetupLine()

  self.frame:UnregisterEvent("PLAYER_LOGIN")
end

function Addon:ColorLine()
  if (UnitIsPlayer(UNIT_TARGET)) then
    local color = RAID_CLASS_COLORS[select(2, UnitClass(UNIT_TARGET))]
    self.line:SetColorTexture(color.r, color.g, color.b, 1)
  else
    self.line:SetColorTexture(unpack(DEFAULT_LINE_COLOR))
  end
end

function Addon:UpdateLine()
  local namePlate = GetNamePlateForUnit(UNIT_TARGET, issecure())

  self:AnchorLine(namePlate)
  self:ColorLine()
  self:ToggleLine(namePlate ~= nil)

  self.namePlate = namePlate
end

function Addon:PLAYER_TARGET_CHANGED()
  self:UpdateLine()
end

function Addon:NAME_PLATE_UNIT_ADDED()
  self:UpdateLine()
end

function Addon:NAME_PLATE_UNIT_REMOVED()
  if (self:GetNamePlateUnit() == nil) then
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
    self.frame:SetPoint("CENTER", "UIParent")

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
