require('NPCs/MainCreationMethods');
UrielItemsAllowed = UrielItemsAllowed or {}

function UrielItemsAllowed.BulletsBandolierContainer(container, item)
	return (
    item:getDisplayCategory() == "Ammo"
  )
end

function UrielItemsAllowed.BeltContainer(container, item)
	return (
    item:getDisplayCategory() == "Tool" or
    item:getDisplayCategory() == "ToolWeapon" or
    item:getDisplayCategory() == "Fishing" or
    item:getDisplayCategory() == "Cooking" or
    item:getDisplayCategory() == "LightSource" or
    item:getName() == "Pipe Wrench" or
    item:getName() == "Tongs" 
  )
end