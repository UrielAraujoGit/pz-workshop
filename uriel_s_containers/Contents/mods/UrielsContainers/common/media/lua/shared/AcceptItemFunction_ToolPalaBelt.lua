function ToolPalaBelt(container, item)
    if not item then
        return false
    end

    if item:getCategory() == "Tool" then
        return true
    end

    local scriptItem = ScriptManager.instance:getItem(item:getFullType())
    if not scriptItem then
        return false
    end

    local category = scriptItem:getDisplayCategory()
    return category == "Tool" or category == "ToolWeapon"
end
