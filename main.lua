local addon, ns = ...
local T, C, L = unpack(Tukui)
assert(C.dots, 'TukuiDOTs has not been added to config.lua')
local mod = CreateFrame('frame', addonName, UIParent)
mod:SetScript('OnEvent', function(self, event, ...)
  return self[event](self, ...)
end)
mod:RegisterEvent('PLAYER_ENTERING_WORLD')
local Icon = ns.Icon
local icons = { }
local spells = nil
ns.activeSpells = setmetatable({ }, {
  __index = function(self, index)
    self[index] = { }
    return self[index]
  end
})
mod.PLAYER_ENTERING_WORLD = function(self)
  spells = C.dots.spells[T.myclass] and C.dots.spells[select(2, UnitClass('player'))][GetPrimaryTalentTree()]
  C.dots = nil
  if not spells then
    return nil
  end
  ns.playerGUID = UnitGUID('player')
  for index, data in pairs(spells) do
    local icon = Icon(index, data)
    icons[icon.spellID] = icon
  end
  self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
  self:RegisterEvent('PLAYER_TARGET_CHANGED')
  self.PLAYER_ENTERING_WORLD = function(self)
    for _, data in pairs(ns.activeSpells) do
      wipe(data)
    end
    for _, icon in pairs(icons) do
      icon:Hide()
    end
    return true
  end
  return true
end
local events = {
  SPELL_AURA_APPLIED = true,
  SPELL_AURA_REMOVED = true,
  SPELL_AURA_REFRESH = true,
  SPELL_AURA_APPLIED_DOSE = true,
  SPELL_AURA_REMOVED_DOSE = true
}
mod.COMBAT_LOG_EVENT_UNFILTERED = function(self, ...)
  local _, event, _, source, _, _, _, dest, _, _, _, spellID = ...
  if source ~= ns.playerGUID then
    return nil
  end
  if not events[event] then
    return nil
  end
  local icon = icons[spellID]
  if not icon then
    return nil
  end
  if icon.unit == 'player' and dest ~= ns.playerGUID then
    return nil
  end
  if event == 'SPELL_AURA_APPLIED' then
    ns.activeSpells[spellID][dest] = true
  elseif event == 'SPELL_AURA_REMOVED' then
    ns.activeSpells[spellID][dest] = nil
  end
  icon:Resync()
  return true
end
mod.PLAYER_TARGET_CHANGED = function(self)
  ns.targetGUID = UnitGUID('target')
  for spell, icon in pairs(icons) do
    icon:Resync()
  end
  return true
end
