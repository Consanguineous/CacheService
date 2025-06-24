--!strict

local CacheService = {}

-- Union type for allowed locations 
export type ValidCacheLocation = ServerScriptService | ReplicatedStorage

type FolderStruct = {
    CacheFolder: Folder,
    FolderName: string,
    Location: ValidCacheLocation,
    Tag: string?
}

type Void = (...any) -> nil

function CacheService:CreateCacheFolder(FolderName: string, Location: ValidCacheLocation, tag: string?): FolderStruct
    local CachedFolder = Instance.new("Folder")
    if FolderName == "" or nil then
        warn("FolderName cannot be empty or nil.")
        return
    end
    CachedFolder.Name = FolderName
    CachedFolder.Parent = Location

    if tag then
        CachedFolder:SetAttribute("Tag", tag)
    else
        CachedFolder:SetAttribute("Tag", "Untagged")
    end

    return {
        CacheFolder = CachedFolder,
        FolderName = FolderName,
        Location = Location,
        Tag = tag,
    }
end

function CacheService:AddToCache(What: Instance, FolderName: string, Location: ValidCacheLocation, tag: string?): Void
    local SelectedFolder = Location:FindFirstChild(FolderName)
    if SelectedFolder and SelectedFolder:IsA("Folder") then
        What.Parent = SelectedFolder

        if tag then
            What:SetAttribute("Tag", tag)
        else
            What:SetAttribute("Tag", "Untagged")
        end
    else
        warn("Cache folder '" .. FolderName .. "' not found in " .. tostring(Location))
    end
end

function CacheService:RemoveFromCache(What: Instance, FolderName: string, Location: ValidCacheLocation): boolean
    local SelectedFolder = Location:FindFirstChild(FolderName)
    if SelectedFolder and SelectedFolder:IsA("Folder") then
        if What.Parent == SelectedFolder then
            What.Parent = nil
            return true
        else
            warn("Instance is not inside the cache folder.")
            return false
        end
    else
        warn("Cache folder '" .. FolderName .. "' not found in " .. tostring(Location))
        return false
    end
end

function CacheService:DestroyTaggedCache(FolderName: string, Location: ValidCacheLocation, tag: string?): Void
    local SelectedFolder = Location:FindFirstChild(FolderName)
    if SelectedFolder and SelectedFolder:IsA("Folder") then
        for _, child in ipairs(SelectedFolder:GetChildren()) do
            if child:GetAttribute("Tag") == tag then
                child:Destroy()
            end
        end
    else
        warn("Cache folder '" .. FolderName .. "' not found in " .. tostring(Location))
    end
end

function CacheService:DestroyCache(FolderName: string, Location: ValidCacheLocation): boolean
    if not Location then
        warn("Location in DestroyCache is nil.", debug.traceback("DestroyCache traceback: "))
        return false
    end
    local SelectedFolder = Location:FindFirstChild(FolderName)
    if SelectedFolder and SelectedFolder:IsA("Folder") then
        SelectedFolder:Destroy()
        return true
    else
        warn("Cache folder '" .. FolderName .. "' not found in " .. tostring(Location))
        return false
    end
end

function CacheService:MergeCache(Cache1: Folder, Cache2: Folder): Void --Cache1: First cache folder, Cache2: Second cache folder Cache1 -> Cache2
    if not Cache1:IsA("Folder") or not Cache2:IsA("Folder") then
        warn("Both arguments must be Folder instances.", debug.traceback("MergeCache traceback: "))
        return
    end
    
    for _, child in ipairs(Cache1:GetChildren()) do
        if not Cache2:FindFirstChild(child.Name) then
            child.Parent = Cache2
        else
            warn("Child '" .. child.Name .. "' already exists in the second cache folder.")
        end
    end
end

function CacheService:ReturnCacheContents(WhichCache: Folder): { Instance }
    if not WhichCache:IsA("Folder") then
        warn("Argument is not a Folder.")
        return {}
    end

    local CacheContents = WhichCache:GetChildren()
    if #CacheContents == 0 then
        warn("Cache folder '" .. WhichCache.Name .. "' is empty.")
    end

    return CacheContents
end

function CacheService:ClearCacheContents(WhichCache: Folder): Void
    if not WhichCache:IsA("Folder") then
        warn("Argument is not a Folder.")
        return
    end

    if WhichCache then
        for _, child in ipairs(WhichCache:GetChildren()) do
            if child then
                child:Destroy()
            end
        end
    end
end


return CacheService
