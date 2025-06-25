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

type Void = (...any) -> ()

function CacheService:CreateCacheFolder(FolderName: string, Location: ValidCacheLocation, tag: string?): FolderStruct
    local CachedFolder = Instance.new("Folder")
    if not FolderName or FolderName == "" then
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

function CacheService:RemoveFromCache(What: Instance, FolderName: string, Location: ValidCacheLocation): boolean --#Completely removes instance altogther, But also from Cache#
    local SelectedFolder = Location:FindFirstChild(FolderName)
    if SelectedFolder and SelectedFolder:IsA("Folder") then
        if (What.Parent == SelectedFolder) then
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

function CacheService:MergeCache(cache1: Folder, cache2: Folder): Void
    assert(cache1:IsA("Folder") and cache2:IsA("Folder"), 
        "[CacheService.MergeCache] Both arguments must be Folder instances."
    )
    
    for _, child in ipairs(cache1:GetChildren()) do
        if not cache2:FindFirstChild(child.Name) then
            child.Parent = cache2
        else
            warn(("[CacheService.MergeCache] Duplicate child '%s' ignored."):format(child.Name))
        end
    end
end

function CacheService:ReturnCacheContents(WhichCache: Folder): { Instance }
    if not WhichCache:IsA("Folder") then
        warn("Argument is not a Folder.", debug.traceback("ReturnCacheContents traceback: "))
        return {} --#Dummy cache contents
    end

    local CacheChildren = WhichCache:GetChildren()


    return CacheChildren

end
--#ClearCacheContent
function CacheService:ClearCacheContents(WhichCache: Folder): Void
    if not WhichCache:IsA("Folder") then
        warn("Argument is not a Folder.", debug.traceback("ClearCacheContents traceback: "))
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
