local addon, ns = ...
local T, C, L = unpack(Tukui)
local functions = {
  buff = UnitBuff,
  debuff = UnitDebuff
}
local params = {
  'unit',
  'type',
  'stacks'
}
local size = 36
local margin = 5
local Icon
Icon = (function(_parent_0)
  local _base_0 = {
    Resync = function(self)
      self.duration = nil
      self.numStacks = nil
      local guid
      if self.unit == 'player' then
        guid = ns.playerGUID
      else
        guid = ns.targetGUID
      end
      if ns.activeSpells[self.spellID][guid] then
        self:Show()
      else
        self:Hide()
      end
      return true
    end,
    OnUpdate = function(self, frame, delay)
      if (self.noRefresh or not self.duration) or (self.stacks and not self.numStacks) then
        for index = 1, 140 do
          local _, _, _, stacks, _, _, expires, caster, _, _, spellID = self.fn(self.unit, index)
          if caster == 'player' and spellID == self.spellID then
            self.duration = expires - GetTime()
            self.numStacks = stacks
            break
          elseif not spellID then
            break
          end
        end
      end
      if self.duration then
        self.duration = self.duration - delay
        local seconds = floor(self.duration)
        local milliseconds = floor((self.duration - seconds) * 100)
        if seconds > 0 or milliseconds > 0 then
          self.seconds:SetText(seconds)
          self.milliseconds:SetText(milliseconds)
          if seconds < 3 and not self.flashed then
            UIFrameFlash(self.frame, 0.25, 0.25, 0.5, true, 0, 0)
            self.flashed = true
          end
        else
          self.flashed = nil
          self:Hide()
          return nil
        end
      else
        self:Hide()
        return nil
      end
      if self.stacks and self.numStacks then
        if self.numStacks > 1 then
          self.stacks:Show()
          self.stacks:SetText(self.numStacks)
        else
          self.stacks:Hide()
        end
      end
      return true
    end,
    OnEnter = function(self, frame)
      GameTooltip:SetOwner(frame, 'ANCHOR_CURSOR')
      GameTooltip:ClearLines()
      if self.type == 'debuff' then
        GameTooltip:SetUnitDebuff(self.unit, self.spellName)
      else
        GameTooltip:SetUnitBuff(self.unit, self.spellName)
      end
      GameTooltip:Show()
      return true
    end,
    OnLeave = function(self, frame)
      GameTooltip:Hide()
      return true
    end,
    Show = function(self, ...)
      return self.frame:Show(...)
    end,
    Hide = function(self, ...)
      return self.frame:Hide(...)
    end
  }
  _base_0.__index = _base_0
  if _parent_0 then
    setmetatable(_base_0, getmetatable(_parent_0).__index)
  end
  local _class_0 = setmetatable({
    __init = function(self, index, data)
      self.unit = assert(data.unit, 'missing unit')
      self.type = assert(data.type, 'missing type')
      self.spellID = assert(data.id, 'missing spell id')
      self.fn = assert(functions[self.type], 'bad type')
      self.maxStacks = data.stacks
      self.noRefresh = data.noRefresh
      local name, _, texture = GetSpellInfo(self.spellID)
      self.spellName = name
      self.frame = CreateFrame('frame', string.format('TukuiDots%d', self.spellID), UIParent)
      self.frame:SetPoint('BOTTOMLEFT', TukuiPlayer, 'TOPLEFT', (margin * index) + (size * (index - 1)), 10)
      self.frame:SetAlpha(0.8)
      self.frame:SetWidth(size)
      self.frame:SetHeight(size)
      self.frame:SetTemplate()
      self.frame:CreateShadow()
      self.frame:SetScript('OnUpdate', function(...)
        return self:OnUpdate(...)
      end)
      self.frame:SetScript('OnEnter', function(...)
        return self:OnEnter(...)
      end)
      self.frame:SetScript('OnLeave', function(...)
        return self:OnLeave(...)
      end)
      self.texture = self.frame:CreateTexture(nil, 'ARTWORK')
      self.texture:SetTexture(texture)
      self.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
      self.texture:SetPoint('TOPLEFT', 2, -2)
      self.texture:SetPoint('BOTTOMRIGHT', -2, 2)
      self.seconds = self.frame:CreateFontString(nil, 'OVERLAY')
      self.seconds:SetFont('Fonts\\ARIALN.ttf', 16, 'THINOUTLINE')
      self.seconds:SetPoint('BOTTOMLEFT', self.frame, 'TOPLEFT', 1, size / 7)
      self.milliseconds = self.frame:CreateFontString(nil, 'OVERLAY')
      self.milliseconds:SetFont('Fonts\\ARIALN.ttf', 12, 'THINOUTLINE')
      self.milliseconds:SetPoint('LEFT', self.seconds, 'RIGHT', -2, 0)
      if self.maxStacks then
        self.stacks = self.frame:CreateFontString(nil, 'OVERLAY')
        self.stacks:SetPoint('CENTER')
        self.stacks:SetFont('Fonts\\ARIALN.ttf', 26, 'THINOUTLINE')
      end
      return true
    end
  }, {
    __index = _base_0,
    __call = function(mt, ...)
      local self = setmetatable({}, _base_0)
      mt.__init(self, ...)
      return self
    end
  })
  _base_0.__class = _class_0
  return _class_0
end)()
ns.Icon = Icon
