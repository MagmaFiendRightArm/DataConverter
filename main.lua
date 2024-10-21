local DataConverter = {}

local function isInstance(value)
    return typeof(value) == "Instance"
end

local function canBeConverted(value)
    local valueType = typeof(value)
    return valueType == "table" or isInstance(value) or valueType == "Vector3" or valueType == "CFrame" or valueType == "Color3" or valueType == "BrickColor" or valueType == "NumberSequence" or valueType == "ColorSequence"
end

function DataConverter.toTable(instance)
    if not canBeConverted(instance) then return instance end

    local result = {}
    if isInstance(instance) then
        for _, child in ipairs(instance:GetChildren()) do
            result[child.Name] = DataConverter.toTable(child)
        end
        for propName, propValue in pairs(instance:GetAttributes()) do
            result[propName] = DataConverter.toTable(propValue)
        end
    elseif typeof(instance) == "table" then
        for key, value in pairs(instance) do
            result[key] = DataConverter.toTable(value)
        end
    elseif typeof(instance) == "Vector3" then
        result = {x = instance.X, y = instance.Y, z = instance.Z}
    elseif typeof(instance) == "CFrame" then
        local position = instance.Position
        local xVector, yVector, zVector = instance.RightVector, instance.UpVector, instance.LookVector
        result = {
            position = {x = position.X, y = position.Y, z = position.Z},
            rightVector = {x = xVector.X, y = xVector.Y, z = xVector.Z},
            upVector = {x = yVector.X, y = yVector.Y, z = yVector.Z},
            lookVector = {x = zVector.X, y = zVector.Y, z = zVector.Z}
        }
    elseif typeof(instance) == "Color3" then
        result = {r = instance.R, g = instance.G, b = instance.B}
    elseif typeof(instance) == "BrickColor" then
        result = {name = instance.Name}
    elseif typeof(instance) == "NumberSequence" then
        result = {keypoints = {}}
        for i, keypoint in ipairs(instance.Keypoints) do
            result.keypoints[i] = {time = keypoint.Time, value = keypoint.Value}
        end
    elseif typeof(instance) == "ColorSequence" then
        result = {keypoints = {}}
        for i, keypoint in ipairs(instance.Keypoints) do
            result.keypoints[i] = {time = keypoint.Time, color = {r = keypoint.Value.R, g = keypoint.Value.G, b = keypoint.Value.B}}
        end
    end
    return result
end

function DataConverter.toInstance(data, instanceType)
    if not canBeConverted(data) then return data end
    if typeof(data) ~= "table" then return data end

    local instance
    if instanceType then
        instance = Instance.new(instanceType)
        for key, value in pairs(data) do
            if instance[key] ~= nil then
                instance[key] = DataConverter.toInstance(value)
            else
                instance:SetAttribute(key, DataConverter.toInstance(value))
            end
        end
    elseif data.x and data.y and data.z then
        instance = Vector3.new(data.x, data.y, data.z)
    elseif data.position and data.rightVector and data.upVector and data.lookVector then
        local position = Vector3.new(data.position.x, data.position.y, data.position.z)
        local rightVector = Vector3.new(data.rightVector.x, data.rightVector.y, data.rightVector.z)
        local upVector = Vector3.new(data.upVector.x, data.upVector.y, data.upVector.z)
        local lookVector = Vector3.new(data.lookVector.x, data.lookVector.y, data.lookVector.z)
        instance = CFrame.fromMatrix(position, rightVector, upVector, lookVector)
    elseif data.r and data.g and data.b then
        instance = Color3.new(data.r, data.g, data.b)
    elseif data.name and BrickColor.new(data.name) then
        instance = BrickColor.new(data.name)
    elseif data.keypoints then
        if data.keypoints[1].color then
            local keypoints = {}
            for i, kp in ipairs(data.keypoints) do
                keypoints[i] = ColorSequenceKeypoint.new(kp.time, Color3.new(kp.color.r, kp.color.g, kp.color.b))
            end
            instance = ColorSequence.new(keypoints)
        else
            local keypoints = {}
            for i, kp in ipairs(data.keypoints) do
                keypoints[i] = NumberSequenceKeypoint.new(kp.time, kp.value)
            end
            instance = NumberSequence.new(keypoints)
        end
    else
        instance = {}
        for key, value in pairs(data) do
            instance[key] = DataConverter.toInstance(value)
        end
    end
    return instance
end

return DataConverter
