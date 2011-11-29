local T, C, L = unpack(Tukui)

C['dots'] = C['dots'] or {
  ['spells'] = {
    ['MAGE'] = {
      {    -- arcane
      },{  -- fire
      },{  -- frost
        { id = 44572, unit = 'target', type = 'debuff' }, -- Deep Freeze
        { id = 118, unit = 'target', type = 'debuff' }, -- Polymorph
        { id = 28272, unit = 'target', type = 'debuff' }, -- Polymorph: Pig
        { id = 12472, unit = 'player', type = 'buff' }, -- Icy Veins
        { id = 44544, unit = 'player', type = 'buff', stacks = 2 }, -- Fingers of Frost
        { id = 57761, unit = 'player', type = 'buff' }, -- Brain Freeze
      },
    },
    ['PRIEST'] = {
      {    -- disc
      },{  -- holy
      },{  -- shadow
        { id = 589, unit = 'target', type = 'debuff', noRefresh = true },  -- Shadow Word: Pain
        { id = 34914, unit = 'target', type = 'debuff' },  -- Vampiric Touch
        { id = 2944, unit = 'target', type = 'debuff' },  -- Devouring Plague
        { id = 77487, unit = 'player', type = 'buff', stacks = 3 },  -- Shadow Orb
        { id = 95799, unit = 'player', type = 'buff' },  -- Empowered Shadow
        { id = 87118, unit = 'player', type = 'buff', stacks = 5, noRefresh = true },  -- Dark Evangelism
      },
    },
  },
}
