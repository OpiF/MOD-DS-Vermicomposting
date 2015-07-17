require "stategraphs/SGwormhole_friendly"
require "vermicomposting_shared"

local Assets =
{
	Asset("ANIM", "anim/teleporter_worm.zip"),
	Asset("ANIM", "anim/teleporter_worm_friendly_build.zip"),
	Asset("SOUND", "sound/common.fsb"),
	Asset("ANIM", "anim/worm_menu.zip"),
}

wormhole_container =
{
	widget =
		{
		slotpos = {},
		animbank = "ui_backpack_2x4",
		animbuild = "ui_worm_menu_2x4",
		pos = Vector3(-450, 0, 0),
	},
	issidewidget = true,
	type = "pack",
}

for y = 0, 3 do
	table.insert(wormhole_container.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
	table.insert(wormhole_container.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

local function onopen(inst)
	VermicompostingFillPack(inst)
	
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")
end

local function oncameraarrive(doer)
    doer:SnapCamera()
    doer:ScreenFade(true, 2)
end

local function ondoerarrive(doer)
    doer.sg:GoToState("jumpout")
end

local function ondoneteleporting(other)
    if other.teleporting ~= nil then
        if other.teleporting > 1 then
            other.teleporting = other.teleporting - 1
        else
            other.teleporting = nil
            if not other.components.playerprox:IsPlayerClose() then
                other.sg:GoToState("closing")
            end
        end
    end
end

local function GetStatus(inst)
	if inst.sg.currentstate.name ~= "idle" then
		return "OPEN"
	end
end

local function OnActivate(inst, doer)
    if doer:HasTag("player") then
        ProfileStatsSet("wormhole_used", true)

        local other = inst.components.teleporter.targetTeleporter
        if other ~= nil then
            DeleteCloseEntsWithTag("WORM_DANGER", other, 15)
        end

        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end

		GetPlayer().HUD:Hide()
		TheFrontEnd:SetFadeLevel(1)
		
		doer:DoTaskInTime(0, function() 
			TheFrontEnd:Fade(true, 1)
			GetPlayer().HUD:Show()
		end)
    elseif inst.SoundEmitter ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow")
    end
end

local function OnActivateOther(inst, other, doer)
	other.sg:GoToState("open")
end

local function onnear(inst)
	if not inst.sg:HasStateTag("open") then
		inst.sg:GoToState("opening")
	end
end

local function onfar(inst)
	if inst.sg:HasStateTag("open") then
		inst.sg:GoToState("closing")
	end
end

local function displaynamefn(inst)
    return "Friendly Wormhole"
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
	
	inst.MiniMapEntity:SetIcon("wormhole_" .. (table.getn(menu) + 1) .. ".tex")

	inst.AnimState:SetBank("teleporter_worm")
	inst.AnimState:SetBuild("teleporter_worm_friendly_build")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	
	--trader, alltrader (from trader component) added to pristine state for optimization
	inst:AddTag("trader")
	inst:AddTag("alltrader")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:SetStateGraph("SGwormhole_friendly")
    
	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(4, 5)
	inst.components.playerprox.onnear = onnear
	inst.components.playerprox.onfar = onfar

	inst.teleporting = nil
	
	inst:AddComponent("teleporter")
	inst.components.teleporter.onActivate = OnActivate
	inst.components.teleporter.onActivateOther = OnActivateOther
	inst.components.teleporter.offset = 0
	
	inst:AddComponent("inventory")

	inst.displaynamefn = displaynamefn
	
	inst:AddComponent("container")
	inst.components.container:WidgetSetup("wormhole_container", wormhole_container)
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose
	
	VermicompostingInsertWormhole(inst)
	
	return inst
end

return Prefab("vermicomposting/wormhole_friendly", fn, Assets)