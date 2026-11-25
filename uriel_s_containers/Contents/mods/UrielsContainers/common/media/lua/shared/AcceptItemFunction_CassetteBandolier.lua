function CassetteBandolierAcceptFunction(container, item)
    if not item then
        return false
    end

    local scriptItem = ScriptManager.instance:getItem(item:getFullType())
    return scriptItem ~= nil and scriptItem:getDisplayCategory() == "True Music"
end
