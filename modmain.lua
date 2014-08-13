GLOBAL.CHEATS_ENABLED = true
GLOBAL.require('debugkeys')

function wormholefriendlypostinit(inst)
	print "Wormhole Friendly Init"
end

PrefabFiles = {"wormhole_friendly",}

Assets = 
{
    Asset( "IMAGE", "minimap/wormhole_friendly.tex" ),
    Asset( "ATLAS", "minimap/wormhole_friendly.xml" ),	
}

AddMinimapAtlas("minimap/wormhole_friendly.xml")

AddPrefabPostInit("wormhole_friendly", wormholefriendlypostinit)