--[[
    GameSense Inspired UI Library
    Minimal Executor-Friendly UI Library

    FEATURES:
    - Window
    - Tabs
    - Sections
    - Buttons
    - Toggles
    - Sliders
    - Dropdowns
    - Labels
    - Notifications

    DOCUMENTATION:
    local Library = loadstring(game:HttpGet("URL"))()

    local Window = Library:CreateWindow({
        Title = "gamesense.pub",
        Size = UDim2.fromOffset(600, 450)
    })

    local Rage = Window:CreateTab("Rage")
    local Main = Rage:CreateSection("Main")

    Main:CreateButton({
        Name = "Print Hello",
        Callback = function()
            print("hello")
        end
    })

    Main:CreateToggle({
        Name = "Silent Aim",
        Default = false,
        Callback = function(v)
            print(v)
        end
    })

    Main:CreateSlider({
        Name = "FOV",
        Min = 0,
        Max = 180,
        Default = 90,
        Callback = function(v)
            print(v)
        end
    })

    Main:CreateDropdown({
        Name = "Hitbox",
        Options = {"Head", "Torso", "Random"},
        Default = "Head",
        Callback = function(v)
            print(v)
        end
    })

    Library:Notify("Loaded", 3)
]]

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(17,17,17),
    LightBackground = Color3.fromRGB(24,24,24),
    Accent = Color3.fromRGB(140, 91, 255),
    Text = Color3.fromRGB(255,255,255),
    DarkText = Color3.fromRGB(170,170,170),
    Outline = Color3.fromRGB(40,40,40)
}

function Library:Create(class, props)
    local obj = Instance.new(class)

    for i,v in pairs(props) do
        obj[i] = v
    end

    return obj
end

function Library:Notify(text, duration)
    duration = duration or 3

    local gui = game.CoreGui:FindFirstChild("GS_Notify")

    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "GS_Notify"
        gui.Parent = game.CoreGui
    end

    local frame = self:Create("Frame", {
        Parent = gui,
        BackgroundColor3 = self.Theme.Background,
        BorderColor3 = self.Theme.Outline,
        Position = UDim2.new(1, -320, 1, -100),
        Size = UDim2.new(0, 300, 0, 40)
    })

    local accent = self:Create("Frame", {
        Parent = frame,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0)
    })

    local label = self:Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Enum.Font.Code,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    frame.Position = frame.Position + UDim2.new(0, 400, 0, 0)

    TweenService:Create(
        frame,
        TweenInfo.new(.2),
        {Position = UDim2.new(1, -320, 1, -100)}
    ):Play()

    task.delay(duration, function()
        TweenService:Create(
            frame,
            TweenInfo.new(.2),
            {Position = frame.Position + UDim2.new(0, 400, 0, 0)}
        ):Play()

        task.wait(.25)

        frame:Destroy()
    end)
end

function Library:CreateWindow(cfg)
    cfg = cfg or {}

    local Window = {}

    local ScreenGui = self:Create("ScreenGui", {
        Name = "gamesense",
        ResetOnSpawn = false
    })

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end

    ScreenGui.Parent = game.CoreGui

    local Main = self:Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = self.Theme.Background,
        BorderColor3 = self.Theme.Outline,
        Position = UDim2.new(.5,-300,.5,-225),
        Size = cfg.Size or UDim2.fromOffset(600,450)
    })

    local Topbar = self:Create("Frame", {
        Parent = Main,
        BackgroundColor3 = self.Theme.LightBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,30)
    })

    local Title = self:Create("TextLabel", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Font = Enum.Font.Code,
        Text = cfg.Title or "gamesense.pub",
        TextColor3 = self.Theme.Text,
        TextSize = 15
    })

    local TabButtons = self:Create("Frame", {
        Parent = Main,
        BackgroundColor3 = self.Theme.LightBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,30),
        Size = UDim2.new(0,120,1,-30)
    })

    local TabList = self:Create("UIListLayout", {
        Parent = TabButtons,
        Padding = UDim.new(0,2)
    })

    local Container = self:Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0,125,0,35),
        Size = UDim2.new(1,-130,1,-40)
    })

    -- dragging
    do
        local dragging
        local dragInput
        local dragStart
        local startPos

        Topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        Topbar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart

                Main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    function Window:CreateTab(name)
        local Tab = {}

        local Button = Library:Create("TextButton", {
            Parent = TabButtons,
            BackgroundColor3 = Library.Theme.Background,
            BorderColor3 = Library.Theme.Outline,
            Size = UDim2.new(1,0,0,30),
            Font = Enum.Font.Code,
            Text = name,
            TextColor3 = Library.Theme.DarkText,
            TextSize = 14
        })

        local Page = Library:Create("ScrollingFrame", {
            Parent = Container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,1,0),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarThickness = 3,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        local Layout = Library:Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0,8)
        })

        Button.MouseButton1Click:Connect(function()
            for _,v in pairs(Container:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end

            Page.Visible = true
        end)

        if #Container:GetChildren() <= 1 then
            Page.Visible = true
        end

        function Tab:CreateSection(sectionName)
            local Section = {}

            local Holder = Library:Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Library.Theme.LightBackground,
                BorderColor3 = Library.Theme.Outline,
                Size = UDim2.new(1,-5,0,35)
            })

            local SectionTitle = Library:Create("TextLabel", {
                Parent = Holder,
                BackgroundTransparency = 1,
                Position = UDim2.new(0,10,0,0),
                Size = UDim2.new(1,-10,0,25),
                Font = Enum.Font.Code,
                Text = sectionName,
                TextColor3 = Library.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Inner = Library:Create("Frame", {
                Parent = Holder,
                BackgroundTransparency = 1,
                Position = UDim2.new(0,5,0,30),
                Size = UDim2.new(1,-10,1,-35)
            })

            local InnerLayout = Library:Create("UIListLayout", {
                Parent = Inner,
                Padding = UDim.new(0,5)
            })

            local function Resize()
                Holder.Size = UDim2.new(
                    1,
                    -5,
                    0,
                    InnerLayout.AbsoluteContentSize.Y + 40
                )
            end

            InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Resize)

            function Section:CreateLabel(text)
                local Label = Library:Create("TextLabel", {
                    Parent = Inner,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,0,20),
                    Font = Enum.Font.Code,
                    Text = text,
                    TextColor3 = Library.Theme.DarkText,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                return Label
            end

            function Section:CreateButton(cfg)
                local Button = Library:Create("TextButton", {
                    Parent = Inner,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderColor3 = Library.Theme.Outline,
                    Size = UDim2.new(1,0,0,25),
                    Font = Enum.Font.Code,
                    Text = cfg.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13
                })

                Button.MouseButton1Click:Connect(function()
                    if cfg.Callback then
                        cfg.Callback()
                    end
                end)
            end

            function Section:CreateToggle(cfg)
                local State = cfg.Default or false

                local Toggle = Library:Create("TextButton", {
                    Parent = Inner,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderColor3 = Library.Theme.Outline,
                    Size = UDim2.new(1,0,0,25),
                    Font = Enum.Font.Code,
                    Text = cfg.Name .. " [" .. (State and "ON" or "OFF") .. "]",
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13
                })

                Toggle.MouseButton1Click:Connect(function()
                    State = not State

                    Toggle.Text = cfg.Name .. " [" .. (State and "ON" or "OFF") .. "]"

                    if cfg.Callback then
                        cfg.Callback(State)
                    end
                end)
            end

            function Section:CreateSlider(cfg)
                local Value = cfg.Default or cfg.Min

                local Slider = Library:Create("TextButton", {
                    Parent = Inner,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderColor3 = Library.Theme.Outline,
                    Size = UDim2.new(1,0,0,25),
                    Font = Enum.Font.Code,
                    Text = cfg.Name .. ": " .. Value,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13
                })

                Slider.MouseButton1Click:Connect(function()
                    Value += 1

                    if Value > cfg.Max then
                        Value = cfg.Min
                    end

                    Slider.Text = cfg.Name .. ": " .. Value

                    if cfg.Callback then
                        cfg.Callback(Value)
                    end
                end)
            end

            function Section:CreateDropdown(cfg)
                local Current = cfg.Default or cfg.Options[1]

                local Dropdown = Library:Create("TextButton", {
                    Parent = Inner,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderColor3 = Library.Theme.Outline,
                    Size = UDim2.new(1,0,0,25),
                    Font = Enum.Font.Code,
                    Text = cfg.Name .. ": " .. tostring(Current),
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13
                })

                local index = table.find(cfg.Options, Current) or 1

                Dropdown.MouseButton1Click:Connect(function()
                    index += 1

                    if index > #cfg.Options then
                        index = 1
                    end

                    Current = cfg.Options[index]

                    Dropdown.Text = cfg.Name .. ": " .. tostring(Current)

                    if cfg.Callback then
                        cfg.Callback(Current)
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Library
