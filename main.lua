local DataConverter = {}

local function isInstance(value)
    return typeof(value) == "Instance"
end

local function canBeConverted(value)
    local valueType = typeof(value)
    return valueType == "table" or isInstance(value) or valueType == "Vector3" or valueType == "CFrame" or valueType == "Color3" or valueType == "BrickColor" or valueType == "NumberSequence" or valueType == "ColorSequence"
end

function DataConverter.ToTable(instance)
    if not canBeConverted(instance) then
        return instance
    end

    local result = {}

    if isInstance(instance) then
        for _, child in ipairs(instance:GetChildren()) do
            result[child.Name] = DataConverter.ToTable(child)
        end

        for propName, propValue in pairs(instance:GetAttributes()) do
            result[propName] = DataConverter.ToTable(propValue)
        end
    elseif typeof(instance) == "table" then
        for key, value in pairs(instance) do
            result[key] = DataConverter.ToTable(value)
        end
    elseif typeof(instance) == "Vector3" then
        result = {X = instance.X, Y = instance.Y, Z = instance.Z}
    elseif typeof(instance) == "CFrame" then
        local position = instance.Position
        local xVector, yVector, zVector = instance.RightVector, instance.UpVector, instance.LookVector
        result = {
            Position = {X = position.X, Y = position.Y, Z = position.Z},
            RightVector = {X = xVector.X, Y = xVector.Y, Z = xVector.Z},
            UpVector = {X = yVector.X, Y = yVector.Y, Z = yVector.Z},
            LookVector = {X = zVector.X, Y = zVector.Y, Z = zVector.Z}
        }
    elseif typeof(instance) == "Color3" then
        result = {R = instance.R, G = instance.G, B = instance.B}
    elseif typeof(instance) == "BrickColor" then
        result = {Name = instance.Name}
    elseif typeof(instance) == "NumberSequence" then
        result = {Keypoints = {}}
        for i, keypoint in ipairs(instance.Keypoints) do
            result.Keypoints[i] = {Time = keypoint.Time, Value = keypoint.Value}
        end
    elseif typeof(instance) == "ColorSequence" then
        result = {Keypoints = {}}
        for i, keypoint in ipairs(instance.Keypoints) do
            result.Keypoints[i] = {Time = keypoint.Time, Color = {R = keypoint.Value.R, G = keypoint.Value.G, B = keypoint.Value.B}}
        end
    end

    return result
end

function DataConverter.ToInstance(data, instanceType)
    if not canBeConverted(data) then
        return data
    end

    if typeof(data) ~= "table" then
        return data
    end

    local instance

    if instanceType then
        instance = Instance.new(instanceType)

        for key, value in pairs(data) do
            if instance[key] ~= nil then
                instance[key] = DataConverter.ToInstance(value)
            else
                instance:SetAttribute(key, DataConverter.ToInstance(value))
            end
        end
    elseif data.X ~= nil and data.Y ~= nil and data.Z ~= nil then
        instance = Vector3.new(data.X, data.Y, data.Z)
    elseif data.Position and data.RightVector and data.UpVector and data.LookVector then
        local position = Vector3.new(data.Position.X, data.Position.Y, data.Position.Z)
        local rightVector = Vector3.new(data.RightVector.X, data.RightVector.Y, data.RightVector.Z)
        local upVector = Vector3.new(data.UpVector.X, data.UpVector.Y, data.UpVector.Z)
        local lookVector = Vector3.new(data.LookVector.X, data.LookVector.Y, data.LookVector.Z)
        instance = CFrame.fromMatrix(position, rightVector, upVector, lookVector)
    elseif data.R ~= nil and data.G ~= nil and data.B ~= nil then
        instance = Color3.new(data.R, data.G, data.B)
    elseif data.Name and BrickColor.new(data.Name) then
        instance = BrickColor.new(data.Name)
    elseif data.Keypoints then
        if data.Keypoints[1].Color then
            local keypoints = {}
            for i, kp in ipairs(data.Keypoints) do
                keypoints[i] = ColorSequenceKeypoint.new(kp.Time, Color3.new(kp.Color.R, kp.Color.G, kp.Color.B))
            end
            instance = ColorSequence.new(keypoints)
        else
            local keypoints = {}
            for i, kp in ipairs(data.Keypoints) do
                keypoints[i] = NumberSequenceKeypoint.new(kp.Time, kp.Value)
            end
            instance = NumberSequence.new(keypoints)
        end
    else
        instance = {}
        for key, value in pairs(data) do
            instance[key] = DataConverter.ToInstance(value)
        end
    end

    return instance
end

return DataConverter
