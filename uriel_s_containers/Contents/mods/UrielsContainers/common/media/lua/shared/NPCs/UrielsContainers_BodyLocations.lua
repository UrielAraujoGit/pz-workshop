require 'NPCs/BodyLocations'

-- Location IDs must match BodyLocation= and CanBeEquipped= values in items.txt.
local group = BodyLocations.getGroup("Human")

group:getOrCreateLocation("BulletsBandolierContainer")
group:getOrCreateLocation("BeltContainer")
group:getOrCreateLocation("CargoPantsContainer")
group:getOrCreateLocation("HatContainer")


