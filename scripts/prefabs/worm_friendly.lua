require "prefabutil"

local Assets =
{
	Asset("ANIM", "anim/worm_friendly.zip"),
	Asset("ATLAS", "images/inventoryimages/worm_friendly.xml"),
}

local function plant(inst)
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

local notags = {'NOBLOCK', 'player', 'FX'}

local function test_ground(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.IMPASSABLE and tiletype ~= GROUND.UNDERROCK and tiletype < GROUND.UNDERGROUND
	
	if ground_OK then
		local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

		for k, v in pairs(ents) do
			if v ~= inst and v.entity:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing * min_spacing then
					return false
				end
			end
		end

		return true
	end

	return false
end

local function displaynamefn(inst)
	return "Friendly Worm"
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("worm_friendly")
	inst.AnimState:SetBuild("worm_friendly")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/worm_friendly.xml"
	
	inst:AddComponent("deployable")
	inst.components.deployable.test = test_ground
	inst.components.deployable.ondeploy = ondeploy
	
	inst.displaynamefn = displaynamefn

	return inst
end

return Prefab("vermicomposting/inventory/worm_friendly", fn, Assets),
	MakePlacer("vermicomposting/worm_friendly_placer", "teleporter_worm", "teleporter_worm_friendly_build", "idle_loop")