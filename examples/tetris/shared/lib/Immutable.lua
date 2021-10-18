local Immutable = {}

-- creates a new table with same shape as the given table, but with all values set to value
function Immutable.full_like(dict, value)
    local newDict = {}
    for i=1,#dict do
        if typeof(dict[i]) == "table" then
            newDict[i] = Immutable.full_like(dict[i], value)
        else
            newDict[i] = value
        end
    end
    return newDict
end

function Immutable.full_construct(dict, callback)
    local newDict = {}
    for i=1,#dict do
        if typeof(dict[i]) == "table" then
            newDict[i] = Immutable.full_construct(dict[i], callback)
        else
            newDict[i] = callback(dict[i])
        end
    end
    return newDict
end

return Immutable