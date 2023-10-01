--#region Variables

local weapons = {
    -- Melee
    [`WEAPON_DAGGER`] = {
        name = 'WEAPON_DAGGER',
        hash = `WEAPON_DAGGER`,
        displayName = GetLabelText('WT_DAGGER'),
        weaponType = 'melee'
    },
    [`WEAPON_BAT`] = {
        name = 'WEAPON_BAT',
        hash = `WEAPON_BAT`,
        displayName = GetLabelText('WT_BAT'),
        weaponType = 'melee'
    },
    [`WEAPON_BOTTLE`] = {
        name = 'WEAPON_BOTTLE',
        hash = `WEAPON_BOTTLE`,
        displayName = GetLabelText('WT_BOTTLE'),
        weaponType = 'melee'
    },
    [`WEAPON_CROWBAR`] = {
        name = 'WEAPON_CROWBAR',
        hash = `WEAPON_CROWBAR`,
        displayName = GetLabelText('WT_CROWBAR'),
        weaponType = 'melee'
    },
    [`WEAPON_UNARMED`] = {
        name = 'WEAPON_UNARMED',
        hash = `WEAPON_UNARMED`,
        displayName = GetLabelText('WT_UNARMED'),
        weaponType = 'melee'
    },
    [`WEAPON_FLASHLIGHT`] = {
        name = 'WEAPON_FLASHLIGHT',
        hash = `WEAPON_FLASHLIGHT`,
        displayName = GetLabelText('WT_FLASHLIGHT'),
        weaponType = 'melee'
    },
    [`WEAPON_GOLFCLUB`] = {
        name = 'WEAPON_GOLFCLUB',
        hash = `WEAPON_GOLFCLUB`,
        displayName = GetLabelText('WT_GOLFCLUB'),
        weaponType = 'melee'
    },
    [`WEAPON_HAMMER`] = {
        name = 'WEAPON_HAMMER',
        hash = `WEAPON_HAMMER`,
        displayName = GetLabelText('WT_HAMMER'),
        weaponType = 'melee'
    },
    [`WEAPON_HATCHET`] = {
        name = 'WEAPON_HATCHET',
        hash = `WEAPON_HATCHET`,
        displayName = GetLabelText('WT_HATCHET'),
        weaponType = 'melee'
    },
    [`WEAPON_KNUCKLE`] = {
        name = 'WEAPON_KNUCKLE',
        hash = `WEAPON_KNUCKLE`,
        displayName = GetLabelText('WT_KNUCKLE'),
        weaponType = 'melee'
    },
    [`WEAPON_KNIFE`] = {
        name = 'WEAPON_KNIFE',
        hash = `WEAPON_KNIFE`,
        displayName = GetLabelText('WT_KNIFE'),
        weaponType = 'melee'
    },
    [`WEAPON_MACHETE`] = {
        name = 'WEAPON_MACHETE',
        hash = `WEAPON_MACHETE`,
        displayName = GetLabelText('WT_MACHETE'),
        weaponType = 'melee'
    },
    [`WEAPON_SWITCHBLADE`] = {
        name = 'WEAPON_SWITCHBLADE',
        hash = `WEAPON_SWITCHBLADE`,
        displayName = GetLabelText('WT_SWBLADE'),
        weaponType = 'melee'
    },
    [`WEAPON_NIGHTSTICK`] = {
        name = 'WEAPON_NIGHTSTICK',
        hash = `WEAPON_NIGHTSTICK`,
        displayName = GetLabelText('WT_NGTSTK'),
        weaponType = 'melee'
    },
    [`WEAPON_WRENCH`] = {
        name = 'WEAPON_WRENCH',
        hash = `WEAPON_WRENCH`,
        displayName = GetLabelText('WT_WRENCH'),
        weaponType = 'melee'
    },
    [`WEAPON_BATTLEAXE`] = {
        name = 'WEAPON_BATTLEAXE',
        hash = `WEAPON_BATTLEAXE`,
        displayName = GetLabelText('WT_BATTLEAXE'),
        weaponType = 'melee'
    },
    [`WEAPON_POOLCUE`] = {
        name = 'WEAPON_POOLCUE',
        hash = `WEAPON_POOLCUE`,
        displayName = GetLabelText('WT_POOLCUE'),
        weaponType = 'melee'
    },
    [`WEAPON_STONE_HATCHET`] = {
        name = 'WEAPON_STONE_HATCHET',
        hash = `WEAPON_STONE_HATCHET`,
        displayName = GetLabelText('WT_SHATCHET'),
        weaponType = 'melee'
    },
    [`WEAPON_CANDYCANE`] = {
        name = 'WEAPON_CANDYCANE',
        hash = `WEAPON_CANDYCANE`,
        displayName = GetLabelText('WT_CANDYCANE'),
        weaponType = 'melee'
    },

    -- Handguns
    [`WEAPON_PISTOL`] = {
        name = 'WEAPON_PISTOL',
        hash = `WEAPON_PISTOL`,
        displayName = GetLabelText('WT_PIST'),
        weaponType = 'handgun'
    },
    [`WEAPON_PISTOL_MK2`] = {
        name = 'WEAPON_PISTOL_MK2',
        hash = `WEAPON_PISTOL_MK2`,
        displayName = GetLabelText('WT_PIST2'),
        weaponType = 'handgun'
    },
    [`WEAPON_COMBATPISTOL`] = {
        name = 'WEAPON_COMBATPISTOL',
        hash = `WEAPON_COMBATPISTOL`,
        displayName = GetLabelText('WT_PIST_CBT'),
        weaponType = 'handgun'
    },
    [`WEAPON_APPISTOL`] = {
        name = 'WEAPON_APPISTOL',
        hash = `WEAPON_APPISTOL`,
        displayName = GetLabelText('WT_PIST_AP'),
        weaponType = 'handgun'
    },
    [`WEAPON_STUNGUN`] = {
        name = 'WEAPON_STUNGUN',
        hash = `WEAPON_STUNGUN`,
        displayName = GetLabelText('WT_STUN'),
        weaponType = 'handgun'
    },
    [`WEAPON_PISTOL50`] = {
        name = 'WEAPON_PISTOL50',
        hash = `WEAPON_PISTOL50`,
        displayName = GetLabelText('WT_PIST_50'),
        weaponType = 'handgun'
    },
    [`WEAPON_SNSPISTOL`] = {
        name = 'WEAPON_SNSPISTOL',
        hash = `WEAPON_SNSPISTOL`,
        displayName = GetLabelText('WT_SNSPISTOL'),
        weaponType = 'handgun'
    },
    [`WEAPON_SNSPISTOL_MK2`] = {
        name = 'WEAPON_SNSPISTOL_MK2',
        hash = `WEAPON_SNSPISTOL_MK2`,
        displayName = GetLabelText('WT_SNSPISTOL2'),
        weaponType = 'handgun'
    },
    [`WEAPON_HEAVYPISTOL`] = {
        name = 'WEAPON_HEAVYPISTOL',
        hash = `WEAPON_HEAVYPISTOL`,
        displayName = GetLabelText('WT_HVYPISTOL'),
        weaponType = 'handgun'
    },
    [`WEAPON_VINTAGEPISTOL`] = {
        name = 'WEAPON_VINTAGEPISTOL',
        hash = `WEAPON_VINTAGEPISTOL`,
        displayName = GetLabelText('WT_VPISTOL'),
        weaponType = 'handgun'
    },
    [`WEAPON_FLAREGUN`] = {
        name = 'WEAPON_FLAREGUN',
        hash = `WEAPON_FLAREGUN`,
        displayName = GetLabelText('WT_FLAREGUN'),
        weaponType = 'handgun'
    },
    [`WEAPON_MARKSMANPISTOL`] = {
        name = 'WEAPON_MARKSMANPISTOL',
        hash = `WEAPON_MARKSMANPISTOL`,
        displayName = GetLabelText('WT_MKPISTOL'),
        weaponType = 'handgun'
    },
    [`WEAPON_REVOLVER`] = {
        name = 'WEAPON_REVOLVER',
        hash = `WEAPON_REVOLVER`,
        displayName = GetLabelText('WT_REVOLVER'),
        weaponType = 'handgun'
    },
    [`WEAPON_REVOLVER_MK2`] = {
        name = 'WEAPON_REVOLVER_MK2',
        hash = `WEAPON_REVOLVER_MK2`,
        displayName = GetLabelText('WT_REVOLVER2'),
        weaponType = 'handgun'
    },
    [`WEAPON_DOUBLEACTION`] = {
        name = 'WEAPON_DOUBLEACTION',
        hash = `WEAPON_DOUBLEACTION`,
        displayName = GetLabelText('WT_REV_DA'),
        weaponType = 'handgun'
    },
    [`WEAPON_RAYPISTOL`] = {
        name = 'WEAPON_RAYPISTOL',
        hash = `WEAPON_RAYPISTOL`,
        displayName = GetLabelText('WT_RAYPISTOL'),
        weaponType = 'handgun'
    },
    [`WEAPON_CERAMICPISTOL`] = {
        name = 'WEAPON_CERAMICPISTOL',
        hash = `WEAPON_CERAMICPISTOL`,
        displayName = GetLabelText('WT_CERPST'),
        weaponType = 'handgun'
    },
    [`WEAPON_NAVYREVOLVER`] = {
        name = 'WEAPON_NAVYREVOLVER',
        hash = `WEAPON_NAVYREVOLVER`,
        displayName = GetLabelText('WT_REV_NV'),
        weaponType = 'handgun'
    },
    [`WEAPON_GADGETPISTOL`] = {
        name = 'WEAPON_GADGETPISTOL',
        hash = `WEAPON_GADGETPISTOL`,
        displayName = GetLabelText('WT_GDGTPST'),
        weaponType = 'handgun'
    },
    [`WEAPON_STUNGUN_MP`] = {
        name = 'WEAPON_STUNGUN_MP',
        hash = `WEAPON_STUNGUN_MP`,
        displayName = GetLabelText('WT_STNGUNMP'),
        weaponType = 'handgun'
    },
    [`WEAPON_PISTOLXM3`] = {
        name = 'WEAPON_PISTOLXM3',
        hash = `WEAPON_PISTOLXM3`,
        displayName = GetLabelText('WT_PISTOLXM3'),
        weaponType = 'handgun'
    },

    -- Submachine Guns
    [`WEAPON_MICROSMG`] = {
        name = 'WEAPON_MICROSMG',
        hash = `WEAPON_MICROSMG`,
        displayName = GetLabelText('WT_SMG_MCR'),
        weaponType = 'slmg'
    },
    [`WEAPON_SMG`] = {
        name = 'WEAPON_SMG',
        hash = `WEAPON_SMG`,
        displayName = GetLabelText('WT_SMG'),
        weaponType = 'slmg'
    },
    [`WEAPON_SMG_MK2`] = {
        name = 'WEAPON_SMG_MK2',
        hash = `WEAPON_SMG_MK2`,
        displayName = GetLabelText('WT_SMG2'),
        weaponType = 'slmg'
    },
    [`WEAPON_ASSAULTSMG`] = {
        name = 'WEAPON_ASSAULTSMG',
        hash = `WEAPON_ASSAULTSMG`,
        displayName = GetLabelText('WT_SMG_ASL'),
        weaponType = 'slmg'
    },
    [`WEAPON_COMBATPDW`] = {
        name = 'WEAPON_COMBATPDW',
        hash = `WEAPON_COMBATPDW`,
        displayName = GetLabelText('WT_COMBATPDW'),
        weaponType = 'slmg'
    },
    [`WEAPON_MACHINEPISTOL`] = {
        name = 'WEAPON_MACHINEPISTOL',
        hash = `WEAPON_MACHINEPISTOL`,
        displayName = GetLabelText('WT_MCHPIST'),
        weaponType = 'slmg'
    },
    [`WEAPON_MINISMG`] = {
        name = 'WEAPON_MINISMG',
        hash = `WEAPON_MINISMG`,
        displayName = GetLabelText('WT_MINISMG'),
        weaponType = 'slmg'
    },
    [`WEAPON_RAYCARBINE`] = {
        name = 'WEAPON_RAYCARBINE',
        hash = `WEAPON_RAYCARBINE`,
        displayName = GetLabelText('WT_RAYCARBINE'),
        weaponType = 'slmg'
    },

    -- Shotguns
    [`WEAPON_PUMPSHOTGUN`] = {
        name = 'WEAPON_PUMPSHOTGUN',
        hash = `WEAPON_PUMPSHOTGUN`,
        displayName = GetLabelText('WT_SG_PMP'),
        weaponType = 'shotgun'
    },
    [`WEAPON_PUMPSHOTGUN_MK2`] = {
        name = 'WEAPON_PUMPSHOTGUN_MK2',
        hash = `WEAPON_PUMPSHOTGUN_MK2`,
        displayName = GetLabelText('WT_SG_PMP2'),
        weaponType = 'shotgun'
    },
    [`WEAPON_SAWNOFFSHOTGUN`] = {
        name = 'WEAPON_SAWNOFFSHOTGUN',
        hash = `WEAPON_SAWNOFFSHOTGUN`,
        displayName = GetLabelText('WT_SG_SOF'),
        weaponType = 'shotgun'
    },
    [`WEAPON_ASSAULTSHOTGUN`] = {
        name = 'WEAPON_ASSAULTSHOTGUN',
        hash = `WEAPON_ASSAULTSHOTGUN`,
        displayName = GetLabelText('WT_SG_ASL'),
        weaponType = 'shotgun'
    },
    [`WEAPON_BULLPUPSHOTGUN`] = {
        name = 'WEAPON_BULLPUPSHOTGUN',
        hash = `WEAPON_BULLPUPSHOTGUN`,
        displayName = GetLabelText('WT_SG_BLP'),
        weaponType = 'shotgun'
    },
    [`WEAPON_MUSKET`] = {
        name = 'WEAPON_MUSKET',
        hash = `WEAPON_MUSKET`,
        displayName = GetLabelText('WT_MUSKET'),
        weaponType = 'shotgun'
    },
    [`WEAPON_HEAVYSHOTGUN`] = {
        name = 'WEAPON_HEAVYSHOTGUN',
        hash = `WEAPON_HEAVYSHOTGUN`,
        displayName = GetLabelText('WT_HVYSHGN'),
        weaponType = 'shotgun'
    },
    [`WEAPON_DBSHOTGUN`] = {
        name = 'WEAPON_DBSHOTGUN',
        hash = `WEAPON_DBSHOTGUN`,
        displayName = GetLabelText('WT_DBSHGN'),
        weaponType = 'shotgun'
    },
    [`WEAPON_AUTOSHOTGUN`] = {
        name = 'WEAPON_AUTOSHOTGUN',
        hash = `WEAPON_AUTOSHOTGUN`,
        displayName = GetLabelText('WT_AUTOSHGN'),
        weaponType = 'shotgun'
    },
    [`WEAPON_COMBATSHOTGUN`] = {
        name = 'WEAPON_COMBATSHOTGUN',
        hash = `WEAPON_COMBATSHOTGUN`,
        displayName = GetLabelText('WT_CMBSHGN'),
        weaponType = 'shotgun'
    },

    -- Assault Rifles
    [`WEAPON_ASSAULTRIFLE`] = {
        name = 'WEAPON_ASSAULTRIFLE',
        hash = `WEAPON_ASSAULTRIFLE`,
        displayName = GetLabelText('WT_RIFLE_ASL'),
        weaponType = 'rifle'
    },
    [`WEAPON_ASSAULTRIFLE_MK2`] = {
        name = 'WEAPON_ASSAULTRIFLE_MK2',
        hash = `WEAPON_ASSAULTRIFLE_MK2`,
        displayName = GetLabelText('WT_RIFLE_ASL2'),
        weaponType = 'rifle'
    },
    [`WEAPON_CARBINERIFLE`] = {
        name = 'WEAPON_CARBINERIFLE',
        hash = `WEAPON_CARBINERIFLE`,
        displayName = GetLabelText('WT_RIFLE_CBN'),
        weaponType = 'rifle'
    },
    [`WEAPON_CARBINERIFLE_MK2`] = {
        name = 'WEAPON_CARBINERIFLE_MK2',
        hash = `WEAPON_CARBINERIFLE_MK2`,
        displayName = GetLabelText('WT_RIFLE_CBN2'),
        weaponType = 'rifle'
    },
    [`WEAPON_ADVANCEDRIFLE`] = {
        name = 'WEAPON_ADVANCEDRIFLE',
        hash = `WEAPON_ADVANCEDRIFLE`,
        displayName = GetLabelText('WT_RIFLE_ADV'),
        weaponType = 'rifle'
    },
    [`WEAPON_SPECIALCARBINE`] = {
        name = 'WEAPON_SPECIALCARBINE',
        hash = `WEAPON_SPECIALCARBINE`,
        displayName = GetLabelText('WT_SPCARBINE'),
        weaponType = 'rifle'
    },
    [`WEAPON_SPECIALCARBINE_MK2`] = {
        name = 'WEAPON_SPECIALCARBINE_MK2',
        hash = `WEAPON_SPECIALCARBINE_MK2`,
        displayName = GetLabelText('WT_SPCARBINE2'),
        weaponType = 'rifle'
    },
    [`WEAPON_BULLPUPRIFLE`] = {
        name = 'WEAPON_BULLPUPRIFLE',
        hash = `WEAPON_BULLPUPRIFLE`,
        displayName = GetLabelText('WT_BULLRIFLE'),
        weaponType = 'rifle'
    },
    [`WEAPON_BULLPUPRIFLE_MK2`] = {
        name = 'WEAPON_BULLPUPRIFLE_MK2',
        hash = `WEAPON_BULLPUPRIFLE_MK2`,
        displayName = GetLabelText('WT_BULLRIFLE2'),
        weaponType = 'rifle'
    },
    [`WEAPON_COMPACTRIFLE`] = {
        name = 'WEAPON_COMPACTRIFLE',
        hash = `WEAPON_COMPACTRIFLE`,
        displayName = GetLabelText('WT_CMPRIFLE'),
        weaponType = 'rifle'
    },
    [`WEAPON_MILITARYRIFLE`] = {
        name = 'WEAPON_MILITARYRIFLE',
        hash = `WEAPON_MILITARYRIFLE`,
        displayName = GetLabelText('WT_MLTRYRFL'),
        weaponType = 'rifle'
    },
    [`WEAPON_HEAVYRIFLE`] = {
        name = 'WEAPON_HEAVYRIFLE',
        hash = `WEAPON_HEAVYRIFLE`,
        displayName = GetLabelText('WT_HEAVYRIFLE'),
        weaponType = 'rifle'
    },
    [`WEAPON_TACTICALRIFLE`] = {
        name = 'WEAPON_TACTICALRIFLE',
        hash = `WEAPON_TACTICALRIFLE`,
        displayName = GetLabelText('WT_TACRIFLE'),
        weaponType = 'rifle'
    },

    -- Light Machine Guns
    [`WEAPON_MG`] = {
        name = 'WEAPON_MG',
        hash = `WEAPON_MG`,
        displayName = GetLabelText('WT_MG'),
        weaponType = 'slmg'
    },
    [`WEAPON_COMBATMG`] = {
        name = 'WEAPON_COMBATMG',
        hash = `WEAPON_COMBATMG`,
        displayName = GetLabelText('WT_MG_CBT'),
        weaponType = 'slmg'
    },
    [`WEAPON_COMBATMG_MK2`] = {
        name = 'WEAPON_COMBATMG_MK2',
        hash = `WEAPON_COMBATMG_MK2`,
        displayName = GetLabelText('WT_MG_CBT2'),
        weaponType = 'slmg'
    },
    [`WEAPON_GUSENBERG`] = {
        name = 'WEAPON_GUSENBERG',
        hash = `WEAPON_GUSENBERG`,
        displayName = GetLabelText('WT_GUSNBRG'),
        weaponType = 'slmg'
    },

    -- Sniper Rifles
    [`WEAPON_SNIPERRIFLE`] = {
        name = 'WEAPON_SNIPERRIFLE',
        hash = `WEAPON_SNIPERRIFLE`,
        displayName = GetLabelText('WT_SNIP_RIF'),
        weaponType = 'sniper'
    },
    [`WEAPON_HEAVYSNIPER`] = {
        name = 'WEAPON_HEAVYSNIPER',
        hash = `WEAPON_HEAVYSNIPER`,
        displayName = GetLabelText('WT_SNIP_HVY'),
        weaponType = 'sniper'
    },
    [`WEAPON_HEAVYSNIPER_MK2`] = {
        name = 'WEAPON_HEAVYSNIPER_MK2',
        hash = `WEAPON_HEAVYSNIPER_MK2`,
        displayName = GetLabelText('WT_SNIP_HVY2'),
        weaponType = 'sniper'
    },
    [`WEAPON_MARKSMANRIFLE`] = {
        name = 'WEAPON_MARKSMANRIFLE',
        hash = `WEAPON_MARKSMANRIFLE`,
        displayName = GetLabelText('WT_MKRIFLE'),
        weaponType = 'sniper'
    },
    [`WEAPON_MARKSMANRIFLE_MK2`] = {
        name = 'WEAPON_MARKSMANRIFLE_MK2',
        hash = `WEAPON_MARKSMANRIFLE_MK2`,
        displayName = GetLabelText('WT_MKRIFLE2'),
        weaponType = 'sniper'
    },
    [`WEAPON_PRECISIONRIFLE`] = {
        name = 'WEAPON_PRECISIONRIFLE',
        hash = `WEAPON_PRECISIONRIFLE`,
        displayName = GetLabelText('WT_PRCSRIFLE'),
        weaponType = 'sniper'
    },

    -- Heavy Weapons
    [`WEAPON_RPG`] = {
        name = 'WEAPON_RPG',
        hash = `WEAPON_RPG`,
        displayName = GetLabelText('WT_RPG'),
        weaponType = 'heavy'
    },
    [`WEAPON_GRENADELAUNCHER`] = {
        name = 'WEAPON_GRENADELAUNCHER',
        hash = `WEAPON_GRENADELAUNCHER`,
        displayName = GetLabelText('WT_GL'),
        weaponType = 'heavy'
    },
    [`WEAPON_GRENADELAUNCHER_SMOKE`] = {
        name = 'WEAPON_GRENADELAUNCHER_SMOKE',
        hash = `WEAPON_GRENADELAUNCHER_SMOKE`,
        displayName = GetLabelText('WT_GL_SMOKE'),
        weaponType = 'heavy'
    },
    [`WEAPON_MINIGUN`] = {
        name = 'WEAPON_MINIGUN',
        hash = `WEAPON_MINIGUN`,
        displayName = GetLabelText('WT_MINIGUN'),
        weaponType = 'heavy'
    },
    [`WEAPON_FIREWORK`] = {
        name = 'WEAPON_FIREWORK',
        hash = `WEAPON_FIREWORK`,
        displayName = GetLabelText('WT_FIREWRK'),
        weaponType = 'heavy'
    },
    [`WEAPON_RAILGUN`] = {
        name = 'WEAPON_RAILGUN',
        hash = `WEAPON_RAILGUN`,
        displayName = GetLabelText('WT_RAILGUN'),
        weaponType = 'heavy'
    },
    [`WEAPON_HOMINGLAUNCHER`] = {
        name = 'WEAPON_HOMINGLAUNCHER',
        hash = `WEAPON_HOMINGLAUNCHER`,
        displayName = GetLabelText('WT_HOMLNCH'),
        weaponType = 'heavy'
    },
    [`WEAPON_COMPACTLAUNCHER`] = {
        name = 'WEAPON_COMPACTLAUNCHER',
        hash = `WEAPON_COMPACTLAUNCHER`,
        displayName = GetLabelText('WT_CMPGL'),
        weaponType = 'heavy'
    },
    [`WEAPON_RAYMINIGUN`] = {
        name = 'WEAPON_RAYMINIGUN',
        hash = `WEAPON_RAYMINIGUN`,
        displayName = GetLabelText('WT_RAYMINIGUN'),
        weaponType = 'heavy'
    },
    [`WEAPON_EMPLAUNCHER`] = {
        name = 'WEAPON_EMPLAUNCHER',
        hash = `WEAPON_EMPLAUNCHER`,
        displayName = GetLabelText('WT_EMPL'),
        weaponType = 'heavy'
    },
    [`WEAPON_RAILGUNXM3`] = {
        name = 'WEAPON_RAILGUNXM3',
        hash = `WEAPON_RAILGUNXM3`,
        displayName = GetLabelText('WT_RAILGUN'),
        weaponType = 'heavy'
    },

    -- Throwables
    [`WEAPON_GRENADE`] = {
        name = 'WEAPON_GRENADE',
        hash = `WEAPON_GRENADE`,
        displayName = GetLabelText('WT_GNADE'),
        weaponType = 'throwable'
    },
    [`WEAPON_BZGAS`] = {
        name = 'WEAPON_BZGAS',
        hash = `WEAPON_BZGAS`,
        displayName = GetLabelText('WT_BZGAS'),
        weaponType = 'throwable'
    },
    [`WEAPON_MOLOTOV`] = {
        name = 'WEAPON_MOLOTOV',
        hash = `WEAPON_MOLOTOV`,
        displayName = GetLabelText('WT_MOLOTOV'),
        weaponType = 'throwable'
    },
    [`WEAPON_STICKYBOMB`] = {
        name = 'WEAPON_STICKYBOMB',
        hash = `WEAPON_STICKYBOMB`,
        displayName = GetLabelText('WT_GNADE_STK'),
        weaponType = 'throwable'
    },
    [`WEAPON_PROXMINE`] = {
        name = 'WEAPON_PROXMINE',
        hash = `WEAPON_PROXMINE`,
        displayName = GetLabelText('WT_PRXMINE'),
        weaponType = 'throwable'
    },
    [`WEAPON_SNOWBALL`] = {
        name = 'WEAPON_SNOWBALL',
        hash = `WEAPON_SNOWBALL`,
        displayName = GetLabelText('WT_SNWBALL'),
        weaponType = 'throwable'
    },
    [`WEAPON_PIPEBOMB`] = {
        name = 'WEAPON_PIPEBOMB',
        hash = `WEAPON_PIPEBOMB`,
        displayName = GetLabelText('WT_PIPEBOMB'),
        weaponType = 'throwable'
    },
    [`WEAPON_BALL`] = {
        name = 'WEAPON_BALL',
        hash = `WEAPON_BALL`,
        displayName = GetLabelText('WT_BALL'),
        weaponType = 'throwable'
    },
    [`WEAPON_SMOKEGRENADE`] = {
        name = 'WEAPON_SMOKEGRENADE',
        hash = `WEAPON_SMOKEGRENADE`,
        displayName = GetLabelText('WT_GNADE_SMK'),
        weaponType = 'throwable'
    },
    [`WEAPON_FLARE`] = {
        name = 'WEAPON_FLARE',
        hash = `WEAPON_FLARE`,
        displayName = GetLabelText('WT_FLARE'),
        weaponType = 'throwable'
    },

    -- Miscellaneous
    [`WEAPON_PETROLCAN`] = {
        name = 'WEAPON_PETROLCAN',
        hash = `WEAPON_PETROLCAN`,
        displayName = GetLabelText('WT_PETROL'),
        weaponType = 'misc'
    },
    [`GADGET_PARACHUTE`] = {
        name = 'GADGET_PARACHUTE',
        hash = `GADGET_PARACHUTE`,
        displayName = GetLabelText('WT_PARA'),
        weaponType = 'misc'
    },
    [`WEAPON_FIREEXTINGUISHER`] = {
        name = 'WEAPON_FIREEXTINGUISHER',
        hash = `WEAPON_FIREEXTINGUISHER`,
        displayName = GetLabelText('WT_FIRE'),
        weaponType = 'misc'
    },
    [`WEAPON_HAZARDCAN`] = {
        name = 'WEAPON_HAZARDCAN',
        hash = `WEAPON_HAZARDCAN`,
        displayName = GetLabelText('WT_HAZARDCAN'),
        weaponType = 'misc'
    },
    [`WEAPON_FERTILIZERCAN`] = {
        name = 'WEAPON_FERTILIZERCAN',
        hash = `WEAPON_FERTILIZERCAN`,
        displayName = GetLabelText('WT_FERTILIZERCAN'),
        weaponType = 'misc'
    },
    [`GADGET_NIGHTVISION`] = {
        name = 'GADGET_NIGHTVISION',
        hash = `GADGET_NIGHTVISION`,
        displayName = GetLabelText('WT_NV'),
        weaponType = 'misc'
    },
    [`WEAPON_TRANQUILIZER`] = {
        name = 'WEAPON_TRANQUILIZER',
        hash = `WEAPON_TRANQUILIZER`,
        displayName = GetLabelText('WT_STUN'),
        weaponType = 'misc'
    },
    [`WEAPON_METALDETECTOR`] = {
        name = 'WEAPON_METALDETECTOR',
        hash = `WEAPON_METALDETECTOR`,
        displayName = GetLabelText('WT_METALDETECTOR'),
        weaponType = 'misc'
    }
}

local weaponCategories = {
    handgun = 'Handguns',
    rifle = 'Assault Rifles',
    shotgun = 'Shotguns',
    slmg = 'Sub/Light Machine Guns',
    throwable = 'Throwables',
    melee = 'Melee',
    heavy = 'Heavy Weapons',
    sniper = 'Snipers',
    misc = 'Miscellaneous'
}

local weaponCategoriesArray = {
    'rifle',
    'handgun',
    'heavy',
    'melee',
    'misc',
    'shotgun',
    'sniper',
    'slmg',
    'throwable'
}

local unlimitedAmmo = false
local unlimitedClip = false

--#endregion Variables

--#region Functions

function SetupWeaponsMenu()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'PlayerRelated', 'WeaponOptions'}, {'Get_All_Weapons', 'Remove_All_Weapons', 'Unlimited_Ammo', 'No_Reload', 'Set_All_Ammo_Count', 'Set_Max_Ammo', 'Spawn_Weapon_By_Name'})
    local categoryPerms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'PlayerRelated', 'WeaponOptions', 'Category'}, weaponCategoriesArray)
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_player_related_options'}}
    }
    local index = 1
    local id = 'bMenu_player_weapon_options'
    local indexes = {}

    if perms.Get_All_Weapons then
        menuOptions[index] = {label = 'Get All Weapons', args = {'get_all_weapons'}, close = false}
        index += 1
    end

    if perms.Remove_All_Weapons then
        menuOptions[index] = {label = 'Remove All Weapons', args = {'remove_all_weapons'}, close = false}
        index += 1
    end

    if perms.Unlimited_Ammo then
        menuOptions[index] = {label = 'Unlimited Ammo', args = {'unlimited_ammo'}, checked = unlimitedAmmo, close = false}
        index += 1
    end

    if perms.No_Reload then
        menuOptions[index] = {label = 'No Reload', description = 'Never have to reload your weapon anymore', args = {'no_reload'}, checked = unlimitedClip, close = false}
        index += 1
    end

    if perms.Set_All_Ammo_Count then
        menuOptions[index] = {label = 'Set All Ammo Count', description = 'Set the amount of ammo in all your weapons', args = {'set_all_ammo'}}
        index += 1
    end

    if perms.Set_Max_Ammo then
        menuOptions[index] = {label = 'Set Max Ammo', description = 'Give all your weapons max ammo', args = {'max_ammo'}, close = false}
        index += 1
    end

    if perms.Spawn_Weapon_By_Name then
        menuOptions[index] = {label = 'Spawn Weapon By Name', description = 'Enter a weapon name to spawn', args = {'weapon_name'}}
        index += 1
    end

    for i = 1, #weaponCategoriesArray do
        local category = weaponCategoriesArray[i]
        if categoryPerms[category] then
            local formattedId = ('%s_%s'):format(id, category)
            lib.registerMenu({
                id = formattedId,
                title = weaponCategories[category],
                position = MenuPosition,
                onClose = function(keyPressed)
                    CloseMenu(false, keyPressed, 'bMenu_player_weapon_options')
                end,
                options = {}
            }, function(_, _, args)
                if HasPedGotWeapon(cache.ped, args[1], false) then return end

                local _, ammo = GetMaxAmmo(cache.ped, args[1])
                GiveWeaponToPed(cache.ped, args[1], ammo == 0 and 200 or ammo, false, false)
            end)

            indexes[formattedId] = 1

            menuOptions[index] = {label = weaponCategories[category], args = {'weapon_category', formattedId}}
            index += 1
        end
    end

    for k, v in pairs(weapons) do
        local formattedId = ('%s_%s'):format(id, v.weaponType)
        if v.name ~= 'WEAPON_UNARMED' and indexes[formattedId] then
            lib.setMenuOptions(formattedId, {label = v.displayName, args = {k}, close = false}, indexes[formattedId])
            indexes[formattedId] += 1
        end
    end

    lib.registerMenu({
        id = 'bMenu_player_weapon_options',
        title = 'Weapon Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_player_related_options')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_player_weapon_options'] = selected
        end,
        onCheck =  function(selected, checked, args)
            if args[1] == 'unlimited_ammo' then
                unlimitedAmmo = checked
                lib.setMenuOptions('bMenu_player_weapon_options', {label = 'Unlimited Ammo', args = {'unlimited_ammo'}, checked = checked, close = false}, selected)
                local hasWeapon, currentWeapon = GetCurrentPedWeapon(cache.ped, true)
                if not hasWeapon then return end
                SetPedInfiniteAmmo(cache.ped, unlimitedAmmo, currentWeapon)
            elseif args[1] == 'no_reload' then
                unlimitedClip = checked
                lib.setMenuOptions('bMenu_player_weapon_options', {label = 'No Reload', description = 'Never have to reload your weapon anymore', args = {'no_reload'}, checked = checked, close = false}, selected)
                SetPedInfiniteAmmoClip(cache.ped, unlimitedClip)
            end
        end,
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'get_all_weapons' then
            for k in pairs(weapons) do
                local _, ammo = GetMaxAmmo(cache.ped, k)
                GiveWeaponToPed(cache.ped, k, ammo == 0 and 200 or ammo, false, false)
            end
        elseif args[1] == 'remove_all_weapons' then
            RemoveAllPedWeapons(cache.ped, false)
        elseif args[1] == 'set_all_ammo' then
            local dialog = lib.inputDialog('Set All Ammo Count', {
                { type = 'number', label = 'Ammo Count', default = 1 }
            })

            if not dialog or not dialog[1] or dialog[1] < 0 then
                if dialog[1] < 0 then
                    lib.notify({
                        description = 'The amount of ammo has to be 0 or above',
                        type = 'error'
                    })
                end
                Wait(200)
                lib.showMenu('bMenu_player_weapon_options', MenuIndexes['bMenu_player_weapon_options'])
                return
            end

            for k in pairs(weapons) do
                if HasPedGotWeapon(cache.ped, k, false) then
                    SetPedAmmo(cache.ped, k, dialog[1])
                end
            end

            lib.notify({
                description = ('All your weapons now have %s ammo'):format(dialog[1]),
                type = 'success'
            })

            Wait(200)
            lib.showMenu('bMenu_player_weapon_options', MenuIndexes['bMenu_player_weapon_options'])
        elseif args[1] == 'max_ammo' then
            for k in pairs(weapons) do
                local _, ammo = GetMaxAmmo(cache.ped, k)
                if HasPedGotWeapon(cache.ped, k, false) then
                    SetPedAmmo(cache.ped, k, ammo == 0 and 200 or ammo)
                end
            end
        elseif args[1] == 'weapon_name' then
            local dialog = lib.inputDialog('Spawn Weapon By Name', {
                { type = 'input', label = 'Weapon Name', placeholder = 'weapon_unarmed' },
                { type = 'checkbox', label = 'Force In Hand', description = 'Force the weapon to be in your hand when it spawns', checked = false }
            })

            if not dialog or not dialog[1] or dialog[1] == '' then
                Wait(200)
                lib.showMenu('bMenu_player_weapon_options', MenuIndexes['bMenu_player_weapon_options'])
                return
            end

            local data = weapons[joaat(dialog[1])]

            if not data then
                lib.notify({
                    description = ('Weapon %s doesn\'t exist, if this is an existing weapon, add it to the weapons.lua file in the config folder. If this weapon is a weapon from the game, make an issue on github about it and it will be added very soon.'):format(dialog[1]),
                    type = 'error',
                    duration = 10000
                })
                Wait(200)
                lib.showMenu('bMenu_player_weapon_options', MenuIndexes['bMenu_player_weapon_options'])
                return
            end

            local _, ammo = GetMaxAmmo(cache.ped, data.hash)
            GiveWeaponToPed(cache.ped, data.hash, ammo == 0 and 200 or ammo, false, dialog[2])

            Wait(200)
            lib.showMenu('bMenu_player_weapon_options', MenuIndexes['bMenu_player_weapon_options'])
        elseif args[1] == 'weapon_category' then
            lib.showMenu(args[2], MenuIndexes[args[2]])
        elseif args[1] == 'bMenu_player_related_options' then
            lib.showMenu(args[1], MenuIndexes[args[1]])
        end
    end)
end

--#endregion Functions

--#region Listeners

lib.onCache('weapon', function(value)
    if not value then return end

    SetPedInfiniteAmmo(cache.ped, unlimitedAmmo, value)
    SetPedInfiniteAmmoClip(cache.ped, unlimitedClip)
end)

--#endregion Listeners

--#region Threads

CreateThread(function()
    local newWeapons = lib.callback.await('bMenu:server:getConfig', false, 'weapons')

    if newWeapons and type(newWeapons) == 'table' then
        for k, v in pairs(newWeapons) do
            weapons[k] = v
        end
    end
end)

--#endregion Threads