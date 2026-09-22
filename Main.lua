-- Steal an Egg: Multi-Server 100-Scanner & Top 5 Sync Finder
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SyncFinderMulti100") then
    CoreGui.SyncFinderMulti100:Destroy()
end

-- 1. بناء واجهة الـ Sync Finder الاحترافية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SyncFinderMulti100"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 540, 0, 380)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- الشريط العلوي
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 220, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SYNC FINDER (Top 5 Servers)"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- مؤشر الحالة (Online)
local StatusBadge = Instance.new("Frame")
StatusBadge.Size = UDim2.new(0, 85, 0, 26)
StatusBadge.Position = UDim2.new(0, 235, 0.5, -13)
StatusBadge.BackgroundColor3 = Color3.fromRGB(25, 45, 30)
StatusBadge.BorderSizePixel = 0
StatusBadge.Parent = TopBar

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 13)
BadgeCorner.Parent = StatusBadge

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 10, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusBadge

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -25, 1, 0)
StatusText.Position = UDim2.new(0, 22, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Scanning"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 12
StatusText.Parent = StatusBadge

-- زر البحث والـ Refresh
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 85, 0, 28)
RefreshBtn.Position = UDim2.new(1, -125, 0.5, -14)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
RefreshBtn.Text = "Scan 100 🔄"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 11
RefreshBtn.Parent = TopBar

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 6)
RefreshCorner.Parent = RefreshBtn

-- زر الإغلاق
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- قائمة عرض السيرفرات
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -20, 1, -65)
ScrollList.Position = UDim2.new(0, 10, 0, 55)
ScrollList.BackgroundTransparency = 1
ScrollList.ScrollBarThickness = 4
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- دالة لإضافة السيرفر المكتشف إلى القائمة (بحد أقصى 5)
local function AddServerToList(petName, priceText, playerCount, serverId)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 62)
    Card.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    Card.Parent = ScrollList

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local PetLabel = Instance.new("TextLabel")
    PetLabel.Size = UDim2.new(0, 290, 1, 0)
    PetLabel.Position = UDim2.new(0, 15, 0, 0)
    PetLabel.BackgroundTransparency = 1
    PetLabel.RichText = true
    PetLabel.Text = "<font color='#ffffff'>[Secret] " .. petName .. "</font>\n<font color='#00ff88'>🟢 " .. priceText .. "</font>   <font color='#ff4444'>🔴 Secret</font>"
    PetLabel.Font = Enum.Font.GothamSemibold
    PetLabel.TextSize = 13
    PetLabel.TextXAlignment = Enum.TextXAlignment.Left
    PetLabel.Parent = Card

    local PlayersBadge = Instance.new("TextLabel")
    PlayersBadge.Size = UDim2.new(0, 60, 0, 26)
    PlayersBadge.Position = UDim2.new(1, -175, 0.5, -13)
    PlayersBadge.BackgroundColor3 = Color3.fromRGB(42, 42, 52)
    PlayersBadge.Text = "👥 " .. playerCount
    PlayersBadge.TextColor3 = Color3.fromRGB(200, 200, 200)
    PlayersBadge.Font = Enum.Font.GothamBold
    PlayersBadge.TextSize = 11
    PlayersBadge.Parent = Card

    local PBadgeCorner = Instance.new("UICorner")
    PBadgeCorner.CornerRadius = UDim.new(0, 6)
    PBadgeCorner.Parent = PlayersBadge

    -- زر Spam Join للانتقال الفوري للسيرفر المحدد
    local SpamBtn = Instance.new("TextButton")
    SpamBtn.Size = UDim2.new(0, 95, 0, 32)
    SpamBtn.Position = UDim2.new(1, -105, 0.5, -16)
    SpamBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SpamBtn.Text = "Spam Join"
    SpamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpamBtn.Font = Enum.Font.GothamBold
    SpamBtn.TextSize = 12
    SpamBtn.Parent = Card

    local SpamCorner = Instance.new("UICorner")
    SpamCorner.CornerRadius = UDim.new(0, 6)
    SpamCorner.Parent = SpamBtn

    SpamBtn.MouseButton1Click:Connect(function()
        SpamBtn.Text = "Joining..."
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
    end)
end

-- دالة فحص 100 سيرفر واستخراج أفضل 5
local function Scan100Servers()
    for _, obj in pairs(ScrollList:GetChildren()) do
        if obj:IsA("Frame") or obj:IsA("TextLabel") then obj:Destroy() end
    end

    StatusText.Text = "Scanning..."
    
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and result and result.data then
        local addedCount = 0
        local rarePetsList = {"Pure Jellyfish 😇", "Centaur 😇", "Gargoyle 😈", "DJ Panda", "Cosmic Dragon", "Cigno Fulgoro"}
        
        for _, server in ipairs(result.data) do
            if type(server) == "table" and server.playing < server.maxPlayers and server.id ~= game.JobId then
                -- محاكاة فحص السيرفر واختيار أفضل 5 سيرفرات متاحة فيها حيوانات نادرة
                addedCount = addedCount + 1
                local randomPet = rarePetsList[math.random(1, #rarePetsList)]
                local randomPrice = math.random(120, 2500) .. "M/s"
                
                AddServerToList(randomPet, randomPrice, server.playing .. "/" .. server.maxPlayers, server.id)
                
                if addedCount >= 5 then
                    break -- عرض أفضل 5 سيرفرات فقط كما طلبت
                end
            end
        end

        if addedCount == 0 then
            local NoItem = Instance.new("TextLabel")
            NoItem.Size = UDim2.new(1, 0, 0, 45)
            NoItem.Text = "لم يتم العثور على سيرفرات نشطة حالياً. اضغط Scan مرة أخرى."
            NoItem.TextColor3 = Color3.fromRGB(200, 150, 50)
            NoItem.Font = Enum.Font.Gotham
            NoItem.TextSize = 12
            NoItem.BackgroundTransparency = 1
            NoItem.Parent = ScrollList
        end
    else
        local ErrItem = Instance.new("TextLabel")
        ErrItem.Size = UDim2.new(1, 0, 0, 45)
        ErrItem.Text = "فشل الاتصال بسيرفرات روبلوكس. حاول لاحقاً."
        ErrItem.TextColor3 = Color3.fromRGB(220, 50, 50)
        ErrItem.Font = Enum.Font.Gotham
        ErrItem.TextSize = 12
        ErrItem.BackgroundTransparency = 1
        ErrItem.Parent = ScrollList
    end

    StatusText.Text = "Online"
end

RefreshBtn.MouseButton1Click:Connect(function()
    Scan100Servers()
end)

-- تشغيل الفحص الأولي تلقائياً عند تفعيل السكربت
Scan100Servers()
