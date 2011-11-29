addon, ns = ...
T, C, L = unpack Tukui

assert(C.dots, 'TukuiDOTs has not been added to config.lua')

mod = CreateFrame('frame', addonName, UIParent)
mod\SetScript('OnEvent', (event, ...) => self[event](self, ...))
mod\RegisterEvent('PLAYER_ENTERING_WORLD')

Icon = ns.Icon
icons = { }

spells = nil

ns.activeSpells = setmetatable { },
  __index: (index) =>
    self[ index ] = { }
    self[ index ]

mod.PLAYER_ENTERING_WORLD = =>
  spells = C.dots.spells[ T.myclass ] and C.dots.spells[ select 2, UnitClass('player') ][ GetPrimaryTalentTree! ]
  C.dots = nil

  return nil if not spells

  ns.playerGUID = UnitGUID('player')

  for index, data in pairs(spells)
    icon = Icon(index, data)
    icons[ icon.spellID ] = icon

  self\RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
  self\RegisterEvent('PLAYER_TARGET_CHANGED')

  self.PLAYER_ENTERING_WORLD = =>
    wipe(data) for _, data in pairs(ns.activeSpells)
    icon\Hide! for _, icon in pairs(icons)
    true

  true

events =
  SPELL_AURA_APPLIED: true
  SPELL_AURA_REMOVED: true
  SPELL_AURA_REFRESH: true
  SPELL_AURA_APPLIED_DOSE: true
  SPELL_AURA_REMOVED_DOSE: true

mod.COMBAT_LOG_EVENT_UNFILTERED = (...) =>
  _, event, _, source, _, _, _, dest, _, _, _, spellID = ...

  if source ~= ns.playerGUID
    return nil

  if not events[ event ]
    return nil

  icon = icons[ spellID ]
  if not icon
    return nil

  if icon.unit == 'player' and dest ~= ns.playerGUID
    return nil

  if event == 'SPELL_AURA_APPLIED'
    ns.activeSpells[ spellID ][ dest ] = true
  elseif event == 'SPELL_AURA_REMOVED'
    ns.activeSpells[ spellID ][ dest ] = nil

  icon\Resync!

  true

mod.PLAYER_TARGET_CHANGED = =>
  ns.targetGUID = UnitGUID('target')

  for spell, icon in pairs(icons)
    icon\Resync!

  true
