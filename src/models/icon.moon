addon, ns = ...
T, C, L = unpack Tukui

functions =
  buff: UnitBuff
  debuff: UnitDebuff

params = { 'unit', 'type', 'stacks' }

size = 36
margin = 5

class Icon
  new: (index, data) =>
    @unit = assert data.unit, 'missing unit'
    @type = assert data.type, 'missing type'
    @spellID = assert data.id, 'missing spell id'
    @fn = assert functions[@type], 'bad type'
    @maxStacks = data.stacks
    @noRefresh = data.noRefresh

    name, _, texture = GetSpellInfo(@spellID)
    @spellName = name

    @frame = CreateFrame('frame', string.format('TukuiDots%d', @spellID), UIParent)
    @frame\SetPoint('BOTTOMLEFT', TukuiPlayer, 'TOPLEFT', (margin * index) + (size * (index - 1)), 10) -- gl
    @frame\SetAlpha(0.8)
    @frame\SetWidth(size)
    @frame\SetHeight(size)
    @frame\SetTemplate!
    @frame\CreateShadow!

    @frame\SetScript('OnUpdate', (...) -> @OnUpdate(...))
    @frame\SetScript('OnEnter', (...) -> @OnEnter(...))
    @frame\SetScript('OnLeave', (...) -> @OnLeave(...))

    @texture = @frame\CreateTexture(nil, 'ARTWORK')
    @texture\SetTexture(texture)
    @texture\SetTexCoord(0.1, 0.9, 0.1, 0.9)
    @texture\SetPoint('TOPLEFT', 2, -2)
    @texture\SetPoint('BOTTOMRIGHT', -2, 2)

    @seconds = @frame\CreateFontString(nil, 'OVERLAY')
    @seconds\SetFont('Fonts\\ARIALN.ttf', 16, 'THINOUTLINE')
    @seconds\SetPoint('BOTTOMLEFT', @frame, 'TOPLEFT', 1, size/7)

    @milliseconds = @frame\CreateFontString(nil, 'OVERLAY')
    @milliseconds\SetFont('Fonts\\ARIALN.ttf', 12, 'THINOUTLINE')
    @milliseconds\SetPoint('LEFT', @seconds, 'RIGHT', -2, 0)

    if @maxStacks
      @stacks = @frame\CreateFontString(nil, 'OVERLAY')
      @stacks\SetPoint('CENTER')
      @stacks\SetFont('Fonts\\ARIALN.ttf', 26, 'THINOUTLINE')

    true

  Resync: =>
    @duration = nil
    @numStacks = nil

    guid = if @unit == 'player'
      ns.playerGUID
    else
      ns.targetGUID

    if ns.activeSpells[ @spellID ][ guid ]
      @Show!
    else
      @Hide!

    true

  OnUpdate: (frame, delay) =>
    if (@noRefresh or not @duration) or (@stacks and not @numStacks)
      for index = 1, 140
        _, _, _, stacks, _, _, expires, caster, _, _, spellID = self.fn(@unit, index) -- dont use @ here!
        if caster == 'player' and spellID == @spellID
          @duration = expires - GetTime!
          @numStacks = stacks
          break
        elseif not spellID
          break

    if @duration
      @duration -= delay
      seconds = floor(@duration)
      milliseconds = floor( (@duration - seconds) * 100 )

      if seconds > 0 or milliseconds > 0
        @seconds\SetText(seconds)
        @milliseconds\SetText(milliseconds)

        if seconds < 3 and not @flashed
          UIFrameFlash(@frame, 0.25, 0.25, 0.5, true, 0, 0)
          @flashed = true

      else
        @flashed = nil
        @Hide!
        return nil

    else
      @Hide!
      return nil

    if @stacks and @numStacks
      if @numStacks > 1
        @stacks\Show!
        @stacks\SetText(@numStacks)
      else
        @stacks\Hide!

    true

  OnEnter: (frame) =>
    GameTooltip\SetOwner(frame, 'ANCHOR_CURSOR')
    GameTooltip\ClearLines!

    if @type == 'debuff'
      GameTooltip\SetUnitDebuff(@unit, @spellName)
    else -- buff
      GameTooltip\SetUnitBuff(@unit, @spellName)

    GameTooltip\Show!
    true

  OnLeave: (frame) =>
    GameTooltip\Hide!
    true

  Show: (...) => @frame\Show(...)
  Hide: (...) => @frame\Hide(...)

ns.Icon = Icon
