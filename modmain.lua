GLOBAL.CHEATS_ENABLED = true
GLOBAL.require('debugkeys')

PrefabFiles = {"wormhole_friendly", "worm_friendly", "wormhole_friendly_teleporter"}

Assets =
{
    Asset("IMAGE", "minimap/wormhole_friendly.tex"),
    Asset("ATLAS", "minimap/wormhole_friendly.xml"),
}

AddMinimapAtlas("minimap/wormhole_friendly.xml")