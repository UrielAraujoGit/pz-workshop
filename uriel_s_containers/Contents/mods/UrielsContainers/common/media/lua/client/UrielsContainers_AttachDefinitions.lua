require "Hotbar/ISHotbarAttachDefinition"
if not ISHotbarAttachDefinition then
    return
end

local HatContainerSlot = {
	type = "HatContainerSlot",
	name = "Hat Container Slot", -- Name shown in the slot icon
	animset = "back",
	attachments = { -- list of possible item category and their modelAttachement group, the item category is defined in the item script
		Knife = "HatContainer Knife", -- defined in AttachedLocations.lua
		Screwdriver  = "HatContainer Screwdriver",
		Scissors = "HatContainer Scissors",
		Walkie = "HatContainer Walkie",
	},
}
table.insert(ISHotbarAttachDefinition, HatContainerSlot);

local GarraLaPalaLeftSlot = {
	type = "GarraLaPalaLeftSlot",
	name = "GarraLaPala Left Slot", -- Name shown in the slot icon
	animset = "belt left",
	attachments = { -- list of possible item category and their modelAttachement group, the item category is defined in the item script
		Knife = "GarraLaPala Left Slot", -- defined in AttachedLocations.lua
		Hammer = "GarraLaPala Left Slot",
		HammerRotated = "GarraLaPala Left Slot",
		Nightstick = "GarraLaPala Left Slot",
		Screwdriver  = "GarraLaPala Left Slot",
		Wrench = "GarraLaPala Left Slot",
		MeatCleaver = "GarraLaPala Left Slot",
		Walkie = "GarraLaPala Left Slot",
	},
}
table.insert(ISHotbarAttachDefinition, GarraLaPalaLeftSlot);

local SmallBeltRightSlot = {
	type = "SmallBeltRightSlot",
	name = "GarraLaPala Right Slot",
	animset = "belt right",
	attachments = {
		Knife = "GarraLaPala Right Slot",
		Hammer = "GarraLaPala Right Slot",
		HammerRotated = "GarraLaPala Right Slot",
		Nightstick = "GarraLaPala Right Slot",
		Screwdriver  = "GarraLaPala Right Slot",
		Wrench = "GarraLaPala Right Slot",
		MeatCleaver = "GarraLaPala Right Slot",
		Walkie = "GarraLaPala Right Slot",
	},
}
table.insert(ISHotbarAttachDefinition, SmallBeltRightSlot);