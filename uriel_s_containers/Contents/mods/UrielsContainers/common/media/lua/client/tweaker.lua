function BulletsBandolierContainerTweaker()
  local item;

  item = ScriptManager.instance:getItem("BulletsBandolierContainer.BulletsBandolierContainer");
  item:DoParam("ClothingItemExtra = BulletsBandolierContainer");
  item:DoParam("ClothingItemExtraOption = Wear");
end

Events.OnGameBoot.Add(BulletsBandolierContainerTweaker)


function CargoPantsContainerTweaker()
  local item;

  item = ScriptManager.instance:getItem("CargoPantsContainer.CargoPantsContainer");
  item:DoParam("ClothingItemExtra = CargoPantsContainer");
  item:DoParam("ClothingItemExtraOption = Wear");
end

Events.OnGameBoot.Add(CargoPantsContainerTweaker)


function HatContainerTweaker()
  local item;

  item = ScriptManager.instance:getItem("HatContainer.HatContainer");
  item:DoParam("ClothingItemExtra = HatContainer");
  item:DoParam("ClothingItemExtraOption = Wear");
end

Events.OnGameBoot.Add(HatContainerTweaker)


function BeltContainerTweaker()
  local item;

  item = ScriptManager.instance:getItem("BeltContainer.BeltContainer");
  item:DoParam("ClothingItemExtra = BeltContainer");
  item:DoParam("ClothingItemExtraOption = Wear");
end

Events.OnGameBoot.Add(BeltContainerTweaker)
