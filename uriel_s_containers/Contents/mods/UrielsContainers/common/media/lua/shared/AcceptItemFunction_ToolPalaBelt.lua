
AcceptItemFunction = AcceptItemFunction or {}


function ToolPalaBelt(container, item)
    if not item then
        return false
    end

    local category = item:getCategory()

    if category == "Tool" then
        return true
    end

    local display_category = ScriptManager.instance:getItem(item:getFullType())

    if display_category then
        if display_category:getDisplayCategory() == "Tool" or  display_category:getDisplayCategory() == "ToolWeapon" then
            return true
        end
    end


end