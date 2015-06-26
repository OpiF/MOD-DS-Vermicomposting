PrefabFiles = {"wormhole_friendly", "worm_friendly", "wormhole_friendly_teleporter"}

Assets =
{
    Asset("IMAGE", "minimap/wormhole_friendly.tex"),
    Asset("ATLAS", "minimap/wormhole_friendly.xml"),
}

AddMinimapAtlas("minimap/wormhole_friendly.xml")

local original_tall = nil

local function vermicomposting_tall(inst)
	original_tall.tall(inst)
	
	if(inst.build == "sparse" and math.random() < 0.2) then
		inst.components.lootdropper:SetLoot({"worm_friendly", "log", "log"})
	end
end

local function addtreeloot(inst)
	if (original_tall == nil) then
		original_tall = {}

		for key, val in pairs(inst.components.growable.stages) do
			if (val.name == "tall") then
				original_tall.tall = val.fn
				val.fn = vermicomposting_tall
			end
		end
	end
end

AddPrefabPostInit("evergreen_sparse", addtreeloot)
AddPrefabPostInit("evergreen_sparse_tall", addtreeloot)