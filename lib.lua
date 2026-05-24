-- !strict
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local Library = {}

Library.Theme = {
    Background = Color3.fromRGB(16,16,16),
    Surface = Color3.fromRGB(22,22,22),
    Surface2 = Color3.fromRGB(28,28,28),
    Outline = Color3.fromRGB(40,40,40),

    Accent = Color3.fromRGB(170, 85, 255),

    Text = Color3.fromRGB(255,255,255),
    DarkText = Color3.fromRGB(170,170,170)
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

    local gui = game.CoreGui:FindFirstChild("gs_notify")

    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "gs_notify"
        gui.Parent = game.CoreGui
    end

    local frame = self:Create("Frame", {
        Parent = gui,
        BackgroundColor3 = self.Theme.Surface,
        BorderColor3 = self.Theme.Outline,
        Size = UDim2.new(0, 280, 0, 40),
        Position = UDim2.new(1, 300, 1, -60)
    })

    self:Create("Frame", {
        Parent = frame,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0)
    })

    self:Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 1, 0),
        Font = Enum.Font.Code,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    TweenService:Create(
        frame,
        TweenInfo.new(.2),
        {Position = UDim2.new(1, -290, 1, -60)}
    ):Play()

    task.delay(duration, function()
        TweenService:Create(
            frame,
            TweenInfo.new(.2),
            {Position = UDim2.new(1, 300, 1, -60)}
        ):Play()

        task.wait(.2)

        frame:Destroy()
    end)
end

function Library:CreateWindow(cfg)
    cfg = cfg or {}

    local Window = {}

    local ScreenGui = self:Create("ScreenGui", {
        Name = "gamesense_ui",
        ResetOnSpawn = false
    })

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
        end
    end)

    ScreenGui.Parent = game.CoreGui

    local Main = self:Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = self.Theme.Background,
        BorderColor3 = self.Theme.Outline,
        Position = UDim2.new(.5,-325,.5,-225),
        Size = cfg.Size or UDim2.fromOffset(650, 450)
    })

    self:Create("UIStroke", {
        Parent = Main,
        Color = self.Theme.Outline
    })

    local Topbar = self:Create("Frame", {
        Parent = Main,
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,32)
    })

    self:Create("TextLabel", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 1, 0),
        Font = Enum.Font.Code,
        Text = cfg.Title or "gamesense.pub",
        TextColor3 = self.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Sidebar = self:Create("Frame", {
        Parent = Main,
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,32),
        Size = UDim2.new(0,130,1,-32)
    })

    local SideLayout = self:Create("UIListLayout", {
        Parent = Sidebar,
        Padding = UDim.new(0,4)
    })

    local Content = self:Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0,140,0,42),
        Size = UDim2.new(1,-150,1,-52)
    })

    -- drag
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
            Parent = Sidebar,
            BackgroundColor3 = Library.Theme.Background,
            BorderColor3 = Library.Theme.Outline,
            Size = UDim2.new(1, -8, 0, 30),
            Position = UDim2.new(0,4,0,0),
            Font = Enum.Font.Code,
            Text = name,
            TextColor3 = Library.Theme.DarkText,
            TextSize = 14
        })

        local Page = Library:Create("ScrollingFrame", {
            Parent = Content,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            Size = UDim2.new(1,0,1,0),
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new()
        })

        local PageLayout = Library:Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0,8)
        })

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(
                0,
                0,
                0,
                PageLayout.AbsoluteContentSize.Y + 10
            )
        end)

        Button.MouseButton1Click:Connect(function()
            for _,v in pairs(Content:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end

            for _,v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    v.TextColor3 = Library.Theme.DarkText
                end
            end

            Button.TextColor3 = Library.Theme.Text
            Page.Visible = true
        end)

        if #Content:GetChildren() <= 1 then
            Page.Visible = true
            Button.TextColor3 = Library.Theme.Text
        end

        function Tab:CreateSection(title)
            local Section = {}

            local Holder = Library:Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Library.Theme.Surface,
                BorderColor3 = Library.Theme.Outline,
                Size = UDim2.new(1,-5,0,40)
            })

            local SectionLabel = Library:Create("TextLabel", {
                Parent = Holder,
                BackgroundTransparency = 1,
                Position = UDim2.new(0,10,0,0),
                Size = UDim2.new(1,-10,0,25),
                Font = Enum.Font.Code,
                Text = title,
                TextColor3 = Library.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Inline = Library:Create("Frame", {
                Parent = Holder,
                BackgroundTransparency = 1,
                Position = UDim2.new(0,8,0,28),
                Size = UDim2.new(1,-16,1,-35)
            })

            local InlineLayout = Library:Create("UIListLayout", {
                Parent = Inline,
                Padding = UDim.new(0,5)
            })

            InlineLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Holder.Size = UDim2.new(
                    1,
                    -5,
                    0,
                    InlineLayout.AbsoluteContentSize.Y + 38
                )
            end)

            function Section:CreateButton(cfg)
                local Button = Library:Create("TextButton", {
                    Parent = Inline,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderColor3 = Library.Theme.Outline,
                    Size = UDim2.new(1,0,0,24),
                    Font = Enum.Font.Code,
                    Text = cfg.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13
                })

                Button.MouseButton1Click:Connect(function()
                    cfg.Callback()
                end)
            end

            function Section:CreateToggle(cfg)
                local Enabled = cfg.Default or false

                local Toggle = Library:Create("TextButton", {
                    Parent = Inline,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderColor3 = Library.Theme.Outline,
                    Size = UDim2.new(1,0,0,24),
                    Font = Enum.Font.Code,
                    Text = cfg.Name,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13
                })

                local Indicator = Library:Create("Frame", {
                    Parent = Toggle,
                    BackgroundColor3 = Enabled and Library.Theme.Accent or Color3.fromRGB(60,60,60),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1,-18,.5,-5),
                    Size = UDim2.new(0,10,0,10)
                })

                Toggle.MouseButton1Click:Connect(function()
                    Enabled = not Enabled

                    TweenService:Create(
                        Indicator,
                        TweenInfo.new(.15),
                        {
                            BackgroundColor3 = Enabled
                                and Library.Theme.Accent
                                or Color3.fromRGB(60,60,60)
                        }
                    ):Play()

                    if cfg.Callback then
                        cfg.Callback(Enabled)
                    end
                end)
            end

            function Section:CreateSlider(cfg)
                local Value = cfg.Default or cfg.Min

                local SliderFrame = Library:Create("Frame", {
                    Parent = Inline,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderColor3 = Library.Theme.Outline,
                    Size = UDim2.new(1,0,0,38)
                })

                local Label = Library:Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,8,0,0),
                    Size = UDim2.new(1,-16,0,18),
                    Font = Enum.Font.Code,
                    Text = cfg.Name .. " : " .. tostring(Value),
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Bar = Library:Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Color3.fromRGB(45,45,45),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0,8,0,25),
                    Size = UDim2.new(1,-16,0,4)
                })

                local Fill = Library:Create("Frame", {
                    Parent = Bar,
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(
                        (Value-cfg.Min)/(cfg.Max-cfg.Min),
                        0,
                        1,
                        0
                    )
                })

                local dragging = false

                local function Update(input)
                    local percent = math.clamp(
                        (input.Position.X - Bar.AbsolutePosition.X)
                        / Bar.AbsoluteSize.X,
                        0,
                        1
                    )

                    Value = math.floor(
                        cfg.Min + ((cfg.Max-cfg.Min) * percent)
                    )

                    Fill.Size = UDim2.new(percent,0,1,0)

                    Label.Text = cfg.Name .. " : " .. tostring(Value)

                    if cfg.Callback then
                        cfg.Callback(Value)
                    end
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        Update(input)
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end)
            end

            function Section:CreateDropdown(cfg)
                local Open = false
                local Current = cfg.Default or cfg.Options[1]

                local Dropdown = Library:Create("TextButton", {
                    Parent = Inline,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderColor3 = Library.Theme.Outline,
                    Size = UDim2.new(1,0,0,24),
                    Font = Enum.Font.Code,
                    Text = cfg.Name .. " : " .. tostring(Current),
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13
                })

                local Container = Library:Create("Frame", {
                    Parent = Inline,
                    BackgroundColor3 = Library.Theme.Surface2,
                    BorderColor3 = Library.Theme.Outline,
                    Visible = false,
                    Size = UDim2.new(1,0,0,#cfg.Options * 22)
                })

                local Layout = Library:Create("UIListLayout", {
                    Parent = Container
                })

                for _,option in ipairs(cfg.Options) do
                    local Opt = Library:Create("TextButton", {
                        Parent = Container,
                        BackgroundColor3 = Library.Theme.Background,
                        BorderColor3 = Library.Theme.Outline,
                        Size = UDim2.new(1,0,0,20),
                        Font = Enum.Font.Code,
                        Text = option,
                        TextColor3 = Library.Theme.Text,
                        TextSize = 13
                    })

                    Opt.MouseButton1Click:Connect(function()
                        Current = option

                        Dropdown.Text =
                            cfg.Name .. " : " .. tostring(Current)

                        Container.Visible = false
                        Open = false

                        if cfg.Callback then
                            cfg.Callback(Current)
                        end
                    end)
                end

                Dropdown.MouseButton1Click:Connect(function()
                    Open = not Open
                    Container.Visible = Open
                end)
            end

            function Section:CreateLabel(text)
                Library:Create("TextLabel", {
                    Parent = Inline,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,0,18),
                    Font = Enum.Font.Code,
                    Text = text,
                    TextColor3 = Library.Theme.DarkText,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Library
