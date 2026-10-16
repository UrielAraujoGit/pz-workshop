
AcceptItemFunction = AcceptItemFunction or {}


function CassetteBandolierAcceptFunction(container, item)
    if not item then
        return false
    end


    local display_category = ScriptManager.instance:getItem(item:getFullType())

    if display_category then
        if display_category:getDisplayCategory() == "True Music" then
            return true
        end
    end


end