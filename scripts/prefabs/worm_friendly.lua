require "prefabutil"

local Assets =
{
	Asset("ANIM", "anim/worm_friendly.zip"),
	Asset("ATLAS", "images/inventoryimages/worm_friendly.xml"),
}

local prefabs =
{
	"wormhole_friendly",
}

local function plant(inst)
	if(table.getn(menu) >= 8) then
		ThePlayer.components.talker:Say("I can't plant any more worms!")
		
		return
	end
	
	inst:RemoveComponent("inventoryitem")
	inst.AnimState:PlayAnimation("idle_planted")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")

	local wormhole_friendly = SpawnPrefab("wormhole_friendly")

	if wormhole_friendly then
		wormhole_friendly.Transform:SetPosition(inst.Transform:GetWorldPosition())		
		inst:Remove()
	end
end

local function ondeploy (inst, pt)
	inst.Transform:SetPosition(pt:Get())

	plant(inst)
end

local function displaynamefn(inst)
	return "Friendly Worm"
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("worm_friendly")	
	inst.AnimState:SetBuild("worm_friendly")
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/worm_friendly.xml"
	
	inst:AddComponent("deployable")
	inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
	inst.components.deployable.ondeploy = ondeploy
	
	inst.displaynamefn = displaynamefn

	return inst
end

return Prefab("vermicomposting/inventory/worm_friendly", fn, Assets),
	MakePlacer("vermicomposting/worm_friendly_placer", "teleporter_worm", "teleporter_worm_friendly_build", "idle_loop")