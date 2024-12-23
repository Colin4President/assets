--[[
     __ _____ _____________  __ ____  _____ 
    / //_/ _ /_  __/ __/ _ \/ // / / / / _ )
   / ,< / __ |/ / / _// , _/ _  / /_/ / _  |
  /_/|_/_/ |_/_/ /___/_/|_/_//_/\____/____/ 
  
  KaterHub functions
  if somebody asks you were you skid this script from say from daddy Kater ❤
]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local module = {}

module.Functions = {
	IsClosure = is_synapse_function or iskrnlclosure or isexecutorclosure,
	SetIdentity = (syn and syn.set_thread_identity) or set_thread_identity or setthreadidentity or setthreadcontext,
	GetIdentity = (syn and syn.get_thread_identity) or get_thread_identity or getthreadidentity or getthreadcontext,
	Request = (syn and syn.request) or http_request or request,
	QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport),
	GetAsset = getsynasset or getcustomasset
}

module.Users = {
    admin = "https://raw.githubusercontent.com/KATERGaming/master/refs/heads/main/users/admin.lua",
    premium = "https://raw.githubusercontent.com/KATERGaming/master/refs/heads/main/users/premium.lua",
    bUserids = "https://raw.githubusercontent.com/KATERGaming/master/refs/heads/main/users/blacklist/userid.lua",
    bHwids = "https://raw.githubusercontent.com/KATERGaming/master/refs/heads/main/users/blacklist/hwid.lua"
}

module.Theme = {
    hovercolor = Color3.fromRGB(255, 34, 38),
    Primary = Color3.fromRGB(138, 146, 255),
    Background = Color3.fromRGB(138, 146, 255),
    ["icons"] = {
        closeicon = ""
    }
}

-- Functions
local function timestampToMillis(timestamp: string | number | DateTime)
    return (typeof(timestamp) == "string" and DateTime.fromIsoDate(timestamp).UnixTimestampMillis) or (typeof(timestamp) == "number" and timestamp) or timestamp.UnixTimestampMillis
end

module.BlockedUrl = function(v3: string)
	local v2, v1 = pcall(function() return HttpService:JSONDecode(module.Functions.Request({ Url = v3, Method = "GET" }).Body) end) return v2
end

module.LoadCustomAsset = function(url: string)
    if getcustomasset then
        if isfile(url) then
            return getcustomasset(url, true)
        elseif url:lower():sub(1, 4) == "http" then
            local fileName = `temp_{tick()}.txt`
            writefile(fileName, game:HttpGet(url))
            local result = getcustomasset(fileName, true)
            delfile(fileName)
            return result
        end
    else
        warn("Executor doesn't support 'getcustomasset', rbxassetid only.")
    end
    if url:find("rbxassetid") or tonumber(url) then
        return "rbxassetid://"..url:match("%d+")
    end
    error(debug.traceback("Failed to load custom asset for:\n"..url))
end

module.LoadCustomInstance = function(url: string)
    local success, result = pcall(function()
        return game:GetObjects(module.LoadCustomAsset(url))[1]
    end)
    if success then
        return result
    end
end

module.GetGameLastUpdate = function()
    return DateTime.fromIsoDate(MarketplaceService:GetProductInfo(game.PlaceId).Updated)
end

module.HasGameUpdated = function(timestamp: string | number | DateTime)
    local millis = timestampToMillis(timestamp)
    if millis then
        return millis < module.GetGameLastUpdate().UnixTimestampMillis
    end
    return false
end

module.GetGitLastUpdate = function(owner: string, repo: string, filePath: string)
    local url = `https://api.github.com/repos/{owner}/{repo}/commits?per_page=1&path={filePath}`
    local success, result = pcall(HttpService.JSONDecode, HttpService, game:HttpGet(url))
    if not success then
        error(debug.traceback("Failed to get last commit for:\n"..url))
    end
    return DateTime.fromIsoDate(result[1].commit.committer.date)
end

module.HasGitUpdated = function(owner: string, repo: string, filePath: string, timestamp: string | number | DateTime)
    local millis = timestampToMillis(timestamp)
    if millis then
        return millis < module.GetGitLastUpdate(owner, repo, filePath).UnixTimestampMillis
    end
    return false
end

module.TruncateNumber = function(num: number, decimals: number)
    local shift = 10 ^ (decimals and math.max(decimals, 0) or 0)
	return num * shift // 1 / shift
end

module.PlaySound = function(val,vol)
    local sound = Instance.new("Sound")
    sound.Name = "KH-"..tostring(math.random(1000,9999))
    sound.Volume = tonumber(vol)
    sound.PlayOnRemove = true
    sound.SoundId = val
    sound.Parent = CoreGui
    sound:Destroy()
    return
end

module.announce = function(title,text,dur)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = title;Text = text;Duration = dur; Button1 = "Continue";}) return
end

module.question = function(v5,v6,v78,OptionOne,OptionTwo,v2)
    local v3 = Instance.new("BindableFunction")
    v3.OnInvoke = function(v1) pcall(v2,v1) end
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = v5;Text = v6;Callback = v3; Duration = v78; Button1 = OptionOne; Button2 = OptionTwo;}) return
end

module.IsBlacklisted = function(v1: string)
    local v2 = {
        v3 = loadstring(game:HttpGet('https://raw.githubusercontent.com/KATERGaming/master/refs/heads/main/users/blacklist/hwid.lua'))(),
        v4 = loadstring(game:HttpGet('https://raw.githubusercontent.com/KATERGaming/master/refs/heads/main/users/blacklist/userid.lua'))()
    }
    local v5 = false
    if table.find(v2.v3,tostring(v1)) then
        v5 = true
    elseif table.find(v2.v4,tonumber(v1)) then
        v5 = true
    end
    return v5
end

module.GetAdminList = function()
    return loadstring(game:HttpGet(module.Users.admin))()
end

module.GetPremiumList = function()
    return loadstring(game:HttpGet(module.Users.premium))()
end

module.GetPlayerPos = function()
    local player = game:GetService("Players").LocalPlayer
    if player.Character then if player.Character.HumanoidRootPart then return player.Character.HumanoidRootPart.Position end
        print(player.Character.HumanoidRootPart.Position)
    end
end

module.SaveString = function(v1: string,v2)
    getgenv()[v1] = v2
end
module.Load = function(v1)
    return getgenv()[v1]
end

module.QueueOnTeleport = function(v1:string)
    if QueueOnTeleport then game:GetService("Players").LocalPlayer.OnTeleport:Connect(function() QueueOnTeleport(v1) end)
        return true else return 
    false end
end

module.GetTheme = function()
    return module.Theme
end

-- Main
--[[
for name, func in module do
    if typeof(func) == "function" then
        getgenv()[name] = func
    end
end
]]
return module
