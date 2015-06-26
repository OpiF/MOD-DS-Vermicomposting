require "stategraphs/SGwormhole_friendly"
require "vermicomposting_shared"

local Assets =
{
	Asset("ANIM", "anim/teleporter_worm.zip"),
	Asset("ANIM", "anim/teleporter_worm_friendly_build.zip"),
	Asset("SOUND", "sound/common.fsb"),
	Asset("ANIM", "anim/worm_menu.zip"),
}

local function onopen(inst)
	VermicompostingFillPack(inst)
	
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")
end

local function GetStatus(inst)
	if inst.sg.currentstate.name ~= "idle" then
		return "OPEN"
	end
end

local function OnActivate(inst, doer)
	if doer:HasTag("player") then
        ProfileStatsSet("wormhole_used", true)
		doer.components.health:SetInvincible(true)
		doer.components.playercontroller:Enable(false)
		
		if inst.components.teleporter.targetTeleporter ~= nil then
			DeleteCloseEntsWithTag(inst.components.teleporter.targetTeleporter, "WORM_DANGER", 15)
		end

		GetPlayer().HUD:Hide()
		TheFrontEnd:SetFadeLevel(1)
		doer:DoTaskInTime(0, function() 
			TheFrontEnd:Fade(true,1)
			GetPlayer().HUD:Show()
		end)
		doer:DoTaskInTime(0, function()
			doer.components.health:SetInvincible(false)
			doer.components.playercontroller:Enable(true)
		end)
	elseif doer.SoundEmitter then
		inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow", "wormhole_swallow")
	end
end

local function OnActivateOther(inst, other, doer)
	other.sg:GoToState("open")
end

local function displaynamefn(inst)
    return "Friendly Wormhole"
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("wormhole_" .. (table.getn(menu) + 1) .. ".tex")

	anim:SetBank("teleporter_worm")
	anim:SetBuild("teleporter_worm_friendly_build")
	anim:PlayAnimation("idle_loop", true)
	anim:SetLayer(LAYER_BACKGROUND)
	anim:SetSortOrder(3)
    
	inst:SetStateGraph("SGwormhole_friendly")
    
	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(4,5)
	inst.components.playerprox.onnear = function()
		if not inst.sg:HasStateTag("open") then
			inst.sg:GoToState("opening")
		end
	end
	
	inst.components.playerprox.onfar = function()
		if inst.sg:HasStateTag("open") then
			inst.sg:GoToState("closing")
		end
	end

	inst:AddComponent("teleporter")
	inst:AddComponent("inventory")
	inst:AddComponent("trader")

	inst.components.teleporter.onActivate = OnActivate
	inst.components.teleporter.onActivateOther = OnActivateOther

	inst.components.trader.onaccept = function(reciever, giver, item)
		-- pass this on to our better half
		reciever.components.inventory:DropItem(item)
		inst.components.teleporter:Activate(item)
	end

	inst.displaynamefn = displaynamefn
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(0)
    inst.components.container.widgetslotpos = slotpos	
    inst.components.container.widgetanimbank = "ui_backpack_2x4"
    inst.components.container.widgetanimbuild = "ui_worm_menu_2x4"
    inst.components.container.widgetpos = Vector3(-450, 0, 0)
    inst.components.container.side_widget = true
    inst.components.container.type = "pack"
   
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
		
	VermicompostingInsertWormhole(inst)
		
	return inst
end

return Prefab("vermicomposting/wormhole_friendly", fn, Assets)