require "prefabutil"
require "vermicomposting_shared"

local Assets =
{
	Asset("ATLAS", "images/inventoryimages/wormhole_friendly_teleporter.xml"),
}

local function displaynamefn(inst)
	return "Friendly Teleporter"
end

local function caninteract(inst)
	return true
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wormhole_friendly_teleporter.xml"
	
	inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(VermicompostingTeleportTo)
	inst.components.useableitem.CanInteract = caninteract
	
	-- hack because useableitem requires things to be equipped to use them in DST
	inst:AddComponent("equippable")
	inst.components.equippable.isequipped = true
	
	inst.displaynamefn = displaynamefn

	return inst
end

return Prefab("vermicomposting/inventory/wormhole_friendly_teleporter", fn, Assets)