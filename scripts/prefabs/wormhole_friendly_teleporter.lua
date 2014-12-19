require "prefabutil"
require "vermicomposting_shared"

local Assets = {}

local function describe(inst)
	return "?????"
end

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

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = 1
	
	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = describe
	
	inst:AddComponent("inventoryitem")
	
    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(VermicompostingTeleportTo)
	inst.components.useableitem:SetCanInteractFn(caninteract)
	
	inst.displaynamefn = displaynamefn
		
	return inst
end

return Prefab("vermicomposting/inventory/wormhole_friendly_teleporter", fn, Assets)