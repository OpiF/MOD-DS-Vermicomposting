menu = {}
slotpos = {}

for y = 0, 3 do
	table.insert(slotpos, Vector3(-162, -y * 75 + 114, 0))
	table.insert(slotpos, Vector3(-162 + 75, -y * 75 + 114, 0))
end

function VermicompostingInsertWormhole(worm)
	table.insert(menu, worm)

	return menu
end

function VermicompostingPrintMenu()
	for key,value in pairs(menu) do print(value, value.components.container.menuslot) end
end

function VermicompostingTeleportTo(teleporter)
	local index = teleporter.index
	local player = GetPlayer()

	menu[index].components.teleporter:Target(menu[index])
	menu[index].components.teleporter:Activate(player)
	menu[index].components.teleporter:Target(nil)

	local bp = player.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
	if bp and bp.components.container then
		bp.components.container:Close()
		bp.components.container:Open(player)
	end
end

function VermicompostingFillPack(pack)
	for key,value in pairs(menu) do
		local teleporter = SpawnPrefab("wormhole_friendly_teleporter")
		teleporter.index = key
		teleporter.components.inventoryitem.imagename = "wormhole_friendly_teleporter_"..key

		pack.components.inventory:RemoveItemBySlot(key)
		pack.components.inventory:GiveItem(teleporter, key)
	end
end
