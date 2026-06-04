local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Tiedoston nimi tallennusta varten
local SAVE_FILE = "SpeedHub_Settings.json"

local Settings = {
    WalkSpeedToggle = false,
    WalkSpeed = 16,
    Binds = {
        WalkSpeedToggle = "J"
    }
}

-- Tallennus ja lataus
local function SaveSettings()
    if writefile then
        local success, encoded = pcall(function()
            return HttpService:JSONEncode({
                WalkSpeed = Settings.WalkSpeed,
                Binds = Settings.Binds
            })
        end)
        if success then writefile(SAVE_FILE, encoded) end
    end
end

local function LoadSettings()
    if readfile and isfile and isfile(SAVE_FILE) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end)
        if success and decoded then
            if decoded.WalkSpeed then Settings.WalkSpeed = decoded.WalkSpeed end
            if decoded.Binds then
                for k, v in pairs(decoded.Binds) do Settings.Binds[k] = v end
            end
        end
    end
end

LoadSettings()

local function GetBindKeyCode(bindName)
    local bind = Settings.Binds[bindName]
    if bind == "None" then return nil end
    return Enum.KeyCode[bind]
end

local Connections = {}
local IsRunning = true
local IsMinimized = false
local FullSizeY = 150

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")

ScreenGui.Name = "SpeedHub_Persistent"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 200, 0, FullSizeY)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "  SPEED HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = Title
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 16

MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = not IsMinimized
    if IsMinimized then
        MainFrame.Size = UDim2.new(0, 200, 0, 35)
        ContentFrame.Visible = false
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 200, 0, FullSizeY)
        ContentFrame.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.Size = UDim2.new(1, 0, 1, -35)

-- Kytkinpainike
local WalkToggleBtn = Instance.new("TextButton")
WalkToggleBtn.Name = "WalkToggleBtn"
WalkToggleBtn.Parent = ContentFrame
WalkToggleBtn.Size = UDim2.new(0, 180, 0, 35)
WalkToggleBtn.Position = UDim2.new(0, 10, 0, 15)
WalkToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WalkToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkToggleBtn.TextSize = 13
WalkToggleBtn.Font = Enum.Font.SourceSansBold

local function UpdateText()
    WalkToggleBtn.Text = "Speed: " .. (Settings.WalkSpeedToggle and "ON" or "OFF") .. " (" .. Settings.Binds.WalkSpeedToggle .. ")"
    WalkToggleBtn.TextColor3 = Settings.WalkSpeedToggle and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end

local function ToggleWalkSpeed()
    Settings.WalkSpeedToggle = not Settings.WalkSpeedToggle
    UpdateText()
end
WalkToggleBtn.MouseButton1Click:Connect(ToggleWalkSpeed)

-- Slideri nopeuden säätöön
local SliderFrame = Instance.new("Frame")
local SliderBar = Instance.new("Frame")
local SliderDot = Instance.new("TextButton")
local SliderValueLabel = Instance.new("TextLabel")

SliderFrame.Parent = ContentFrame
SliderFrame.Size = UDim2.new(0, 180, 0, 45)
SliderFrame.Position = UDim2.new(0, 10, 0, 65)
SliderFrame.BackgroundTransparency = 1

SliderValueLabel.Parent = SliderFrame
SliderValueLabel.Size = UDim2.new(1, 0, 0, 15)
SliderValueLabel.BackgroundTransparency = 1
SliderValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderValueLabel.TextSize = 12
SliderValueLabel.Font = Enum.Font.SourceSans

SliderBar.Parent = SliderFrame
SliderBar.Size = UDim2.new(1, 0, 0, 4)
SliderBar.Position = UDim2.new(0, 0, 0, 25)
SliderBar.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
SliderBar.BorderSizePixel = 0

SliderDot.Parent = SliderBar
SliderDot.Size = UDim2.new(0, 14, 0, 14)
SliderDot.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
SliderDot.BorderSizePixel = 0
SliderDot.Text = ""

local startingPercent = math.clamp((Settings.WalkSpeed - 16) / 234, 0, 1)
SliderDot.Position = UDim2.new(startingPercent, -7, 0.5, -7)
SliderValueLabel.Text = "Walk Speed: " .. Settings.WalkSpeed

local dragging = false
local function UpdateWalkSlider(input)
    local relativeX = input.Position.X - SliderBar.AbsolutePosition.X
    local percentage = math.clamp(relativeX / SliderBar.AbsoluteSize.X, 0, 1)
    SliderDot.Position = UDim2.new(percentage, -7, 0.5, -7)
    Settings.WalkSpeed = math.floor(16 + (percentage * 234))
    SliderValueLabel.Text = "Walk Speed: " .. Settings.WalkSpeed
    SaveSettings()
end

SliderDot.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateWalkSlider(input) end end)

-- Keybindin muuttaminen oikealla klikkauksella
local listeningForBind = false
WalkToggleBtn.MouseButton2Click:Connect(function()
    WalkToggleBtn.Text = "Paina näppäintä..."
    listeningForBind = true
end)

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if listeningForBind then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Backspace then
                Settings.Binds.WalkSpeedToggle = "None"
            else
                Settings.Binds.WalkSpeedToggle = input.KeyCode.Name
            end
            listeningForBind = false
            UpdateText()
            SaveSettings()
        end
        return
    end
    
    local expectedKey = GetBindKeyCode("WalkSpeedToggle")
    if expectedKey and input.KeyCode == expectedKey then
        ToggleWalkSpeed()
    end
end))

-- Loputon looppi joka pitää nopeuden päällä
table.insert(Connections, RunService.RenderStepped:Connect(function()
    if IsRunning and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local targetSpeed = Settings.WalkSpeedToggle and Settings.WalkSpeed or 16
            if humanoid.WalkSpeed ~= targetSpeed then
                humanoid.WalkSpeed = targetSpeed
            end
        end
    end
end))

UpdateText()
