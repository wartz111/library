--!nocheck
--================================================--
-- PREMIUM LIBRARY v10.3 (módulo)
-- Carregado pelo main.lua via loadstring
--================================================--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

local IS_BLOX_FRUITS, IS_DOORS, IS_MM2 = false, false, false
local GAME_NAME = "Unknown"
local ChatRemote = nil
local _CommF = nil

pcall(function()
    local ce = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if ce then ChatRemote = ce:FindFirstChild("SayMessageRequest") end
end)

local function detectGame()
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name then
        GAME_NAME = info.Name
        local n = info.Name:lower()
        if n:find("doors") then IS_DOORS = true end
        if n:find("blox") and n:find("fruit") then IS_BLOX_FRUITS = true end
        if n:find("murder") and n:find("mystery") then IS_MM2 = true end
    end
    if game.PlaceId == 6516141723 then IS_DOORS = true end
    if game.PlaceId == 142823291 then IS_MM2 = true end
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if r and r:FindFirstChild("CommF_") then IS_BLOX_FRUITS = true end
        if LP:FindFirstChild("Data") and LP.Data:FindFirstChild("Level") then IS_BLOX_FRUITS = true end
    end)
end
detectGame()
task.spawn(function()
    for _ = 1, 30 do
        if IS_BLOX_FRUITS or IS_DOORS or IS_MM2 then break end
        task.wait(1); detectGame()
    end
end)

local function getCommF()
    if _CommF and _CommF.Parent then return _CommF end
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if not r then local ok, res = pcall(function() return ReplicatedStorage:WaitForChild("Remotes", 5) end); if ok then r = res end end
    if r then local ok2, cf = pcall(function() return r:FindFirstChild("CommF_") or r:WaitForChild("CommF_", 5) end); if ok2 then _CommF = cf end end
    return _CommF
end

local function RGB(r, g, b) return Color3.fromRGB(r, g, b) end
local Themes = {
    Dark = { Bg=RGB(20,20,25), Panel=RGB(25,25,32), Section=RGB(28,28,36), Item=RGB(40,40,50), ItemHover=RGB(55,55,68), Border=RGB(45,45,55), Text=RGB(230,230,238), TextDim=RGB(175,175,190) },
    Light = { Bg=RGB(242,243,248), Panel=RGB(230,232,240), Section=RGB(250,250,253), Item=RGB(222,224,234), ItemHover=RGB(208,211,224), Border=RGB(200,203,215), Text=RGB(30,32,42), TextDim=RGB(100,104,120) },
    Midnight = { Bg=RGB(8,10,20), Panel=RGB(12,15,28), Section=RGB(16,20,36), Item=RGB(26,32,54), ItemHover=RGB(38,46,74), Border=RGB(30,38,64), Text=RGB(225,230,245), TextDim=RGB(150,160,190) },
    Ocean = { Bg=RGB(10,24,32), Panel=RGB(14,32,42), Section=RGB(18,40,52), Item=RGB(26,56,72), ItemHover=RGB(36,74,94), Border=RGB(30,64,82), Text=RGB(225,242,248), TextDim=RGB(150,185,200) },
    Rose = { Bg=RGB(26,16,22), Panel=RGB(34,20,28), Section=RGB(42,25,35), Item=RGB(62,36,50), ItemHover=RGB(84,50,68), Border=RGB(70,42,56), Text=RGB(248,230,238), TextDim=RGB(200,160,178) },
}
local ThemeOrder = { "Dark", "Light", "Midnight", "Ocean", "Rose" }
local C = {}
for k, v in pairs(Themes.Dark) do C[k] = v end

local Library = {
    Flags = {}, Setters = {}, Accent = RGB(170, 0, 255), ThemeName = "Dark",
    Themes = Themes, ThemeOrder = ThemeOrder, Capturing = false,
    ConfigFolder = "MenuLib", BgTransp = 0, Roundness = 8, LockInput = true,
    BlurEnabled = true, _cleanups = {}, _notifs = {},
    _scaleObj = nil, Gui = nil, Window = nil, _lastNotif = {},
}

local Connections = {}
local function Connect(sig, fn) local c = sig:Connect(fn); table.insert(Connections, c); return c end
local function Tween(o, t, p, s, d) local tw = TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out), p); tw:Play(); return tw end
local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end
local order = 0
local function Order() order += 1; return order end

local Registry, Corners, Hooks = {}, {}, {}
local function applyEntry(e)
    local inst = e.inst
    if e.kind == "theme" then
        inst[e.prop] = C[e.key]
        if e.prop == "BackgroundColor3" and (e.key == "Bg" or e.key == "Panel" or e.key == "Section") then inst.BackgroundTransparency = Library.BgTransp end
    else inst[e.prop] = Library.Accent end
end
local function Refresh(onlyA)
    for i = #Registry, 1, -1 do
        local e = Registry[i]
        if e.inst.Parent == nil then table.remove(Registry, i)
        elseif not onlyA or e.kind == "accent" then pcall(applyEntry, e) end
    end
    for _, fn in ipairs(Hooks) do pcall(fn) end
end
local function OnTheme(fn) table.insert(Hooks, fn); pcall(fn) end
local function Paint(p, prop, key)
    if typeof(key) == "Color3" then p[prop] = key
    elseif key == "Accent" then p._A = p._A or {}; table.insert(p._A, prop)
    else p._T = p._T or {}; p._T[prop] = key end
end
local function Create(class, props)
    local inst = Instance.new(class)
    local par, T, A
    for k, v in pairs(props or {}) do
        if k == "Parent" then par = v
        elseif k == "_T" then T = v
        elseif k == "_A" then A = v
        else inst[k] = v end
    end
    if par then inst.Parent = par end
    if T then for prop, key in pairs(T) do local e = { inst = inst, prop = prop, kind = "theme", key = key }; table.insert(Registry, e); applyEntry(e) end end
    if A then for _, prop in ipairs(A) do local e = { inst = inst, prop = prop, kind = "accent" }; table.insert(Registry, e); applyEntry(e) end end
    return inst
end
local function Corner(inst, r, fixed)
    r = r or 8
    local u = Create("UICorner", { Parent = inst })
    table.insert(Corners, { u = u, base = r, fixed = fixed })
    u.CornerRadius = UDim.new(0, fixed and r or math.floor(r * Library.Roundness / 8 + 0.5))
    return u
end
local function Stroke(inst, key, thick, transp)
    local p = { Thickness = thick or 1, Transparency = transp or 0.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = inst }
    Paint(p, "Color", key or "Border")
    return Create("UIStroke", p)
end
local function Label(par, text, size, font, colorKey, props)
    local p = { Text = text, TextSize = size or 13, Font = font or Enum.Font.Gotham, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = par }
    Paint(p, "TextColor3", colorKey or "Text")
    for k, v in pairs(props or {}) do p[k] = v end
    return Create("TextLabel", p)
end
local function HoverEffect(btn, nK, hK)
    Connect(btn.MouseEnter, function() Tween(btn, 0.15, { BackgroundColor3 = C[hK] }) end)
    Connect(btn.MouseLeave, function() Tween(btn, 0.15, { BackgroundColor3 = C[nK] }) end)
end
local function Ripple(btn, i)
    local abs = btn.AbsolutePosition
    local sc = Library._scaleObj and Library._scaleObj.Scale or 1
    if sc <= 0 then return end
    local x, y = (i.Position.X - abs.X) / sc, (i.Position.Y - abs.Y) / sc
    local d = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) / sc * 2.2
    local r = Create("Frame", { Size = UDim2.new(), Position = UDim2.new(0, x, 0, y), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.75, BorderSizePixel = 0, Parent = btn })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = r })
    Tween(r, 0.55, { Size = UDim2.new(0, d, 0, d), BackgroundTransparency = 1 })
    task.delay(0.6, function() r:Destroy() end)
end
local function AddRipple(btn)
    btn.ClipsDescendants = true
    Connect(btn.InputBegan, function(i) if isPress(i) then Ripple(btn, i) end end)
end
local function GetFlag(o) return o.Flag == nil and o.Name or o.Flag end
local function Register(flag, value, setter)
    if not flag then return end
    Library.Flags[flag] = value
    Library.Setters[flag] = setter
end

function Library:SetAccent(c) self.Accent = c; Refresh(true) end
function Library:SetTheme(name)
    local t = Themes[name]; if not t then return end
    self.ThemeName = name
    for k, v in pairs(t) do C[k] = v end
    Refresh(false)
end
function Library:SetOpacity(p) self.BgTransp = 1 - math.clamp(p, 30, 100) / 100; Refresh(false) end
function Library:SetRoundness(r)
    self.Roundness = r
    for i = #Corners, 1, -1 do
        local e = Corners[i]
        if e.u.Parent == nil then table.remove(Corners, i)
        elseif not e.fixed then e.u.CornerRadius = UDim.new(0, math.floor(e.base * r / 8 + 0.5)) end
    end
end

local Components = {}
function Components.Toggle(par, o)
    local state = o.Default or false
    local flag = GetFlag(o)
    local c = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = Order(), Parent = par })
    Label(c, o.Name, 13, nil, "Text", { Size = UDim2.new(1, -60, 1, 0) })
    local track = Create("TextButton", { Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -42, 0.5, -11), Text = "", AutoButtonColor = false, _T = { BackgroundColor3 = "Item" }, Parent = c })
    Corner(track, 11, true)
    local knob = Create("Frame", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0.5, -8), BorderSizePixel = 0, _T = { BackgroundColor3 = "Text" }, Parent = track })
    Corner(knob, 8, true)
    local function render()
        Tween(track, 0.2, { BackgroundColor3 = state and Library.Accent or C.Item })
        Tween(knob, 0.2, { Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
    end
    local function set(v, silent)
        state = v and true or false
        if flag then Library.Flags[flag] = state end
        render()
        if not silent and o.Callback then task.spawn(o.Callback, state) end
    end
    OnTheme(render)
    Connect(track.MouseButton1Click, function() set(not state) end)
    Register(flag, state, set)
    local api = {}
    function api:Set(v, s) set(v, s) end
    function api:Get() return state end
    api.Frame = c
    return api
end

function Components.Slider(par, o)
    local mn, mx, st = o.Min or 0, o.Max or 100, o.Step or 1
    local flag = GetFlag(o)
    local val = math.clamp(o.Default or mn, mn, mx)
    local dec = 0
    local f = tostring(st):match("%.(%d+)")
    if f then dec = #f end
    local c = Create("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, LayoutOrder = Order(), Parent = par })
    Label(c, o.Name, 13, nil, "Text", { Size = UDim2.new(0.7, 0, 0, 18) })
    local vl = Label(c, "", 12, Enum.Font.GothamBold, "Accent", { Size = UDim2.new(0.3, 0, 0, 18), Position = UDim2.new(0.7, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Right })
    local hit = Create("Frame", { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 22), BackgroundTransparency = 1, Active = true, Parent = c })
    local bar = Create("Frame", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0.5, -3), BorderSizePixel = 0, _T = { BackgroundColor3 = "Item" }, Parent = hit })
    Corner(bar, 3, true)
    local fill = Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, _A = { "BackgroundColor3" }, Parent = bar })
    Corner(fill, 3, true)
    local knob = Create("Frame", { Size = UDim2.new(0, 12, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, Parent = bar })
    Corner(knob, 6, true)
    local function render()
        local pct = (mx == mn) and 0 or (val - mn) / (mx - mn)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        vl.Text = string.format("%." .. dec .. "f", val) .. (o.Suffix or "")
    end
    local function set(v, silent)
        v = math.clamp(math.floor(v / st + 0.5) * st, mn, mx)
        local ch = v ~= val
        val = v
        if flag then Library.Flags[flag] = v end
        render()
        if ch and not silent and o.Callback then task.spawn(o.Callback, v) end
    end
    local function setX(x)
        local pct = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        set(mn + (mx - mn) * pct)
    end
    local drag = false
    Connect(hit.InputBegan, function(i) if isPress(i) then drag = true; setX(i.Position.X) end end)
    Connect(UIS.InputEnded, function(i) if isPress(i) then drag = false end end)
    Connect(UIS.InputChanged, function(i) if drag and isMove(i) then setX(i.Position.X) end end)
    render(); Register(flag, val, set)
    local api = {}
    function api:Set(v, s) set(v, s) end
    function api:Get() return val end
    api.Frame = c
    return api
end

function Components.Button(par, o)
    local b = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), Text = o.Name, Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false, LayoutOrder = Order(), _T = { BackgroundColor3 = "Item", TextColor3 = "Text" }, Parent = par })
    Corner(b, 8); Stroke(b, "Border", 1, 0.5); AddRipple(b); HoverEffect(b, "Item", "ItemHover")
    Connect(b.MouseButton1Down, function() Tween(b, 0.08, { BackgroundColor3 = Library.Accent }) end)
    Connect(b.MouseButton1Up, function() Tween(b, 0.15, { BackgroundColor3 = C.ItemHover }) end)
    Connect(b.MouseButton1Click, function() if o.Callback then task.spawn(o.Callback) end end)
    local api = {}; api.Frame = b; return api
end

function Components.Keybind(par, o)
    local key = o.Default or Enum.KeyCode.Unknown
    local flag = GetFlag(o)
    local c = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = Order(), Parent = par })
    Label(c, o.Name, 13, nil, "Text", { Size = UDim2.new(0.6, 0, 1, 0) })
    local b = Create("TextButton", { Size = UDim2.new(0, 90, 0, 26), Position = UDim2.new(1, -90, 0.5, -13), Text = key.Name, Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false, _T = { BackgroundColor3 = "Item" }, _A = { "TextColor3" }, Parent = c })
    Corner(b, 6)
    local function set(k, silent)
        key = k; b.Text = key.Name
        if flag then Library.Flags[flag] = key end
        if not silent and o.Changed then task.spawn(o.Changed, key) end
    end
    Register(flag, key, set)
    local wait = false
    Connect(b.MouseButton1Click, function()
        if wait then return end
        wait = true; Library.Capturing = true; b.Text = "..."
        local conn
        local function fin() wait = false; conn:Disconnect(); task.delay(0.1, function() Library.Capturing = false end) end
        conn = UIS.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                fin()
                if i.KeyCode == Enum.KeyCode.Escape then b.Text = key.Name else set(i.KeyCode) end
            elseif isPress(i) then
                local p, ap, as = i.Position, b.AbsolutePosition, b.AbsoluteSize
                if p.X < ap.X or p.X > ap.X + as.X or p.Y < ap.Y or p.Y > ap.Y + as.Y then fin(); b.Text = key.Name end
            end
        end)
    end)
    Connect(UIS.InputBegan, function(i, gp)
        if gp or Library.Capturing or key == Enum.KeyCode.Unknown then return end
        if i.KeyCode == key and o.Callback then task.spawn(o.Callback, key) end
    end)
    local api = {}
    function api:Set(k, s) set(k, s) end
    function api:Get() return key end
    api.Frame = c
    return api
end

function Components.Dropdown(par, o)
    local multi = o.Multi == true
    local options = o.Options or {}
    local flag = GetFlag(o)
    local sel = {}; local btns = {}; local open = false
    local c = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = Order(), Parent = par })
    Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = c })
    local head = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), Text = "", AutoButtonColor = false, LayoutOrder = 1, _T = { BackgroundColor3 = "Item" }, Parent = c })
    Corner(head, 8); Stroke(head, "Border", 1, 0.5); AddRipple(head); HoverEffect(head, "Item", "ItemHover")
    local title = Label(head, "", 13, Enum.Font.GothamMedium, "Text", { Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextTruncate = Enum.TextTruncate.AtEnd })
    local arrow = Label(head, "v", 10, nil, "TextDim", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -26, 0, 0), TextXAlignment = Enum.TextXAlignment.Center })
    local list = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 0), BorderSizePixel = 0, ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false, LayoutOrder = 2, _T = { BackgroundColor3 = "Panel" }, _A = { "ScrollBarImageColor3" }, Parent = c })
    Corner(list, 8)
    Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
    Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 6), Parent = list })
    local function getVal()
        if multi then local t = {}; for _, op in ipairs(options) do if sel[op] then table.insert(t, op) end end; return t end
        for _, op in ipairs(options) do if sel[op] then return op end end
        return nil
    end
    local function render()
        local v = getVal()
        local txt
        if multi then txt = (#v > 0) and table.concat(v, ", ") or "Nenhum" else txt = v or "Nenhum" end
        title.Text = o.Name .. ": " .. txt
        for op, b in pairs(btns) do
            local on = sel[op]
            b.TextColor3 = on and Library.Accent or C.TextDim
            b.BackgroundColor3 = Library.Accent
            b.BackgroundTransparency = on and 0.8 or 1
        end
    end
    OnTheme(render)
    local function commit(silent)
        local v = getVal()
        if flag then Library.Flags[flag] = v end
        render()
        if not silent and o.Callback then task.spawn(o.Callback, v) end
    end
    local function setOpen(v)
        open = v; arrow.Text = open and "^" or "v"
        list.Visible = open
        list.Size = UDim2.new(1, 0, 0, open and math.min(#options * 28 + 8, 150) or 0)
    end
    local function rebuild()
        for _, b in pairs(btns) do b:Destroy() end
        btns = {}
        for idx, op in ipairs(options) do
            local b = Create("TextButton", { Size = UDim2.new(1, 0, 0, 26), Text = op, Font = Enum.Font.Gotham, TextSize = 12, AutoButtonColor = false, LayoutOrder = idx, BackgroundTransparency = 1, Parent = list })
            Corner(b, 6)
            Connect(b.MouseButton1Click, function()
                if multi then sel[op] = not sel[op] or nil
                else sel = { [op] = true }; setOpen(false) end
                commit()
            end)
            btns[op] = b
        end
        if open then setOpen(true) end
        render()
    end
    local function set(v, silent)
        sel = {}
        if type(v) == "table" then for _, op in ipairs(v) do sel[op] = true end
        elseif type(v) == "string" then sel[v] = true end
        commit(silent)
    end
    Connect(head.MouseButton1Click, function() setOpen(not open) end)
    rebuild()
    if o.Default then set(o.Default, true) else commit(true) end
    Register(flag, flag and Library.Flags[flag], set)
    local api = {}
    function api:Set(v, s) set(v, s) end
    function api:Get() return getVal() end
    function api:Refresh(new, keep) options = new or {}; if not keep then sel = {} end; rebuild(); commit(true) end
    api.Frame = c
    return api
end

function Components.Textbox(par, o)
    local flag = GetFlag(o)
    local c = Create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = Order(), Parent = par })
    Label(c, o.Name, 13, nil, "Text", { Size = UDim2.new(0.4, 0, 1, 0) })
    local box = Create("TextBox", { Size = UDim2.new(0.58, 0, 0, 26), Position = UDim2.new(0.42, 0, 0.5, -13), Text = o.Default or "", PlaceholderText = o.Placeholder or "", PlaceholderColor3 = RGB(130,130,145), Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd, _T = { BackgroundColor3 = "Item", TextColor3 = "Text" }, Parent = c })
    Corner(box, 6)
    local st = Stroke(box, "Border", 1, 0.4)
    Connect(box.Focused, function() Tween(st, 0.15, { Color = Library.Accent, Transparency = 0 }) end)
    local function set(v, silent)
        box.Text = tostring(v)
        if flag then Library.Flags[flag] = box.Text end
        if not silent and o.Callback then task.spawn(o.Callback, box.Text) end
    end
    Connect(box.FocusLost, function() Tween(st, 0.15, { Color = C.Border, Transparency = 0.4 }); set(box.Text) end)
    Register(flag, box.Text, set)
    local api = {}
    function api:Set(v, s) set(v, s) end
    function api:Get() return box.Text end
    api.Frame = c
    return api
end

function Components.Label(par, o)
    local l = Label(par, o.Text or o.Name or "", o.Size or 12, nil, "TextDim", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, LayoutOrder = Order() })
    local api = {}
    function api:Set(t) l.Text = t end
    api.Frame = l
    return api
end

function Components.Separator(par)
    local f = Create("Frame", { Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, LayoutOrder = Order(), _T = { BackgroundColor3 = "Border" }, Parent = par })
    local api = {}; api.Frame = f; return api
end

function Components.ColorPicker(par, o)
    local flag = GetFlag(o)
    local color = o.Default or Color3.new(1, 1, 1)
    local h, s, v = color:ToHSV()
    local open = false
    local c = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = Order(), Parent = par })
    Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = c })
    local row = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 1, Parent = c })
    Label(row, o.Name, 13, nil, "Text", { Size = UDim2.new(1, -60, 1, 0) })
    local swatch = Create("TextButton", { Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -42, 0.5, -11), BackgroundColor3 = color, Text = "", AutoButtonColor = false, Parent = row })
    Corner(swatch, 6); Stroke(swatch, Color3.new(1,1,1), 1, 0.7)
    local panel = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, LayoutOrder = 2, _T = { BackgroundColor3 = "Panel" }, Parent = c })
    Corner(panel, 8)
    Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = panel })
    Create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = panel })
    local function apply(silent)
        color = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = color
        if flag then Library.Flags[flag] = color end
        if not silent and o.Callback then task.spawn(o.Callback, color) end
    end
    local sH = Components.Slider(panel, { Name = "Matiz", Min = 0, Max = 360, Default = h * 360, Step = 1, Flag = false, Callback = function(x) h = x / 360; apply() end })
    local sS = Components.Slider(panel, { Name = "Saturacao", Min = 0, Max = 100, Default = s * 100, Step = 1, Flag = false, Callback = function(x) s = x / 100; apply() end })
    local sV = Components.Slider(panel, { Name = "Brilho", Min = 0, Max = 100, Default = v * 100, Step = 1, Flag = false, Callback = function(x) v = x / 100; apply() end })
    Connect(swatch.MouseButton1Click, function() open = not open; panel.Visible = open end)
    local function set(col, silent)
        if typeof(col) ~= "Color3" then return end
        h, s, v = col:ToHSV()
        sH:Set(h * 360, true); sS:Set(s * 100, true); sV:Set(v * 100, true)
        apply(silent)
    end
    apply(true); Register(flag, color, set)
    local api = {}
    function api:Set(col, s) set(col, s) end
    function api:Get() return color end
    api.Frame = c
    return api
end

function Library:CreateWindow(opts)
    opts = opts or {}
    local Window = { Tabs = {}, Current = nil, ToggleKey = opts.ToggleKey or Enum.KeyCode.P, Open = false, Loaded = false }
    if opts.Accent then self.Accent = opts.Accent end
    if opts.Theme and Themes[opts.Theme] then self:SetTheme(opts.Theme) end
    local compact = opts.Compact
    if compact == nil then compact = UIS.TouchEnabled and not UIS.KeyboardEnabled end
    local mobileOnly = UIS.TouchEnabled and not UIS.KeyboardEnabled
    local parGui
    local ok, res = pcall(function() return gethui and gethui() end)
    if ok and res then parGui = res else parGui = LP:WaitForChild("PlayerGui") end
    local GUI = Create("ScreenGui", { Name = "MenuLib", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parGui })
    self.Gui = GUI
    local fullSize = opts.Size or Vector2.new(620, 440)
    local compactSize = Vector2.new(430, 340)
    local baseScale = 1
    local splashG, splashS, splashF
    if opts.Splash ~= false then
        splashG = Create("CanvasGroup", { Size = UDim2.new(0, 300, 0, 110), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BorderSizePixel = 0, _T = { BackgroundColor3 = "Section" }, Parent = GUI })
        Corner(splashG, 12); Stroke(splashG, "Accent", 1.5, 0.3)
        Label(splashG, opts.Title or "MENU LIB", 18, Enum.Font.GothamBold, "Text", { Size = UDim2.new(1, -40, 0, 26), Position = UDim2.new(0, 20, 0, 16) })
        splashS = Label(splashG, "Iniciando...", 12, nil, "TextDim", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.new(0, 20, 0, 48) })
        local track = Create("Frame", { Size = UDim2.new(1, -40, 0, 6), Position = UDim2.new(0, 20, 0, 80), BorderSizePixel = 0, _T = { BackgroundColor3 = "Item" }, Parent = splashG })
        Corner(track, 3, true)
        splashF = Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, _A = { "BackgroundColor3" }, Parent = track })
        Corner(splashF, 3, true)
    end
    local Root = Create("Frame", { Size = UDim2.new(0, fullSize.X, 0, fullSize.Y), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, Visible = false, Parent = GUI })
    local Scale = Create("UIScale", { Scale = 0, Parent = Root })
    self._scaleObj = Scale
    local SHADOW = "rbxassetid://6014261993"
    Create("ImageLabel", { Size = UDim2.new(1, 40, 1, 40), Position = UDim2.new(0, -20, 0, -14), BackgroundTransparency = 1, Image = SHADOW, ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49,49,450,450), Parent = Root })
    local Glow = Create("ImageLabel", { Size = UDim2.new(1, 60, 1, 60), Position = UDim2.new(0, -30, 0, -30), BackgroundTransparency = 1, Image = SHADOW, ImageTransparency = 1, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49,49,450,450), _A = { "ImageColor3" }, Parent = Root })
    local Main = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, _T = { BackgroundColor3 = "Bg" }, Parent = Root })
    Corner(Main, 12)
    local MainStroke = Stroke(Main, "Accent", 1.5, 0.3)
    local TopBar = Create("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, Active = true, Parent = Main })
    local dot = Create("Frame", { Size = UDim2.new(0, 6, 0, 6), Position = UDim2.new(0, 14, 0.5, -3), BorderSizePixel = 0, _A = { "BackgroundColor3" }, Parent = TopBar })
    Corner(dot, 3, true)
    Label(TopBar, opts.Title or "MENU LIB", 15, Enum.Font.GothamBold, "Text", { Size = UDim2.new(1, -120, 1, 0), Position = UDim2.new(0, 28, 0, 0) })
    local drag, dStart, sPos
    Connect(TopBar.InputBegan, function(i) if isPress(i) then drag, dStart, sPos = true, i.Position, Root.Position end end)
    Connect(UIS.InputChanged, function(i)
        if drag and isMove(i) then
            local d = i.Position - dStart
            Root.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end)
    Connect(UIS.InputEnded, function(i) if isPress(i) then drag = false end end)
    local function WBtn(icon, cK, xOff, cb)
        local p = { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, xOff, 0.5, -15), Text = icon, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false, _T = { BackgroundColor3 = "Item" }, Parent = TopBar }
        Paint(p, "TextColor3", cK)
        local b = Create("TextButton", p)
        Corner(b, 15, true); HoverEffect(b, "Item", "ItemHover")
        Connect(b.MouseButton1Click, cb)
    end
    WBtn("-", "TextDim", -76, function() Window:Toggle(false) end)
    WBtn("x", RGB(255, 90, 90), -40, function() Library:Unload() end)
    Create("Frame", { Size = UDim2.new(1, -32, 0, 1), Position = UDim2.new(0, 16, 0, 44), BorderSizePixel = 0, _T = { BackgroundColor3 = "Border" }, Parent = Main })
    local Sidebar = Create("Frame", { Size = UDim2.new(0, 150, 1, -82), Position = UDim2.new(0, 12, 0, 50), BorderSizePixel = 0, _T = { BackgroundColor3 = "Panel" }, Parent = Main })
    Corner(Sidebar, 10)
    local TabList = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -58), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Sidebar })
    Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = TabList })
    Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = TabList })
    local Profile = Create("Frame", { Size = UDim2.new(1, -12, 0, 44), Position = UDim2.new(0, 6, 1, -50), BorderSizePixel = 0, _T = { BackgroundColor3 = "Item" }, Parent = Sidebar })
    Corner(Profile, 8)
    local Avatar = Create("ImageLabel", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 7, 0.5, -15), Image = "", BorderSizePixel = 0, _T = { BackgroundColor3 = "Border" }, Parent = Profile })
    Corner(Avatar, 15, true)
    local PName = Label(Profile, LP.DisplayName, 12, Enum.Font.GothamBold, "Text", { Size = UDim2.new(1, -46, 0, 16), Position = UDim2.new(0, 44, 0, 6), TextTruncate = Enum.TextTruncate.AtEnd })
    local PUser = Label(Profile, "@" .. LP.Name, 10, nil, "TextDim", { Size = UDim2.new(1, -46, 0, 14), Position = UDim2.new(0, 44, 0, 23), TextTruncate = Enum.TextTruncate.AtEnd })
    task.spawn(function()
        local okT, img = pcall(function() return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
        if okT and img and Avatar.Parent then Avatar.Image = img end
    end)
    local PageC = Create("Frame", { Size = UDim2.new(1, -186, 1, -82), Position = UDim2.new(0, 174, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Parent = Main })
    local FooterFrame = Create("Frame", { Size = UDim2.new(1, -24, 0, 18), Position = UDim2.new(0, 12, 1, -22), BackgroundTransparency = 1, Parent = Main })
    local FooterText = Label(FooterFrame, "Carregando...", 10, nil, "TextDim", { Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Center })
    function Window:SetFooter(text) FooterText.Text = text end
    local grip = Create("TextButton", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -18, 1, -18), BackgroundTransparency = 1, Text = "", Font = Enum.Font.Gotham, AutoButtonColor = false, _T = { TextColor3 = "TextDim" }, Parent = Main })
    local resiz, rStart, rSize, rPos
    Connect(grip.InputBegan, function(i) if isPress(i) then resiz, rStart = true, i.Position; rSize = Vector2.new(Root.Size.X.Offset, Root.Size.Y.Offset); rPos = Root.Position end end)
    Connect(UIS.InputChanged, function(i)
        if resiz and isMove(i) then
            local sc = math.max(Scale.Scale, 0.1)
            local d = (i.Position - rStart) / sc
            local w = math.max(compact and 340 or 480, rSize.X + d.X)
            local hg = math.max(compact and 260 or 320, rSize.Y + d.Y)
            Root.Size = UDim2.new(0, w, 0, hg)
            local dw, dh = (w - rSize.X) * sc / 2, (hg - rSize.Y) * sc / 2
            Root.Position = UDim2.new(rPos.X.Scale, rPos.X.Offset + dw, rPos.Y.Scale, rPos.Y.Offset + dh)
        end
    end)
    Connect(UIS.InputEnded, function(i) if isPress(i) then resiz = false end end)
    local NotifH = Create("Frame", { Size = UDim2.new(0, 290, 1, -40), Position = UDim2.new(1, -310, 0, 20), BackgroundTransparency = 1, Parent = GUI })
    Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = NotifH })
    self._notifHolder = NotifH
    local Blur = Create("BlurEffect", { Name = "MenuLibBlur", Size = 0, Parent = Lighting })
    local Modal = Create("TextButton", { Size = UDim2.new(), BackgroundTransparency = 1, Text = "", Parent = GUI })
    local SINK = "MenuLibSink"
    local lockC
    local function updateBlur() Tween(Blur, 0.3, { Size = (Window.Open and Library.BlurEnabled) and 18 or 0 }) end
    local function applyLock(on)
        if not Library.LockInput or mobileOnly then on = false end
        Modal.Modal = on
        pcall(function() UIS.ModalEnabled = on end)
        if lockC then lockC:Disconnect(); lockC = nil end
        ContextActionService:UnbindAction(SINK)
        if on then
            lockC = RunService.RenderStepped:Connect(function()
                if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
                UIS.MouseIconEnabled = true
            end)
            ContextActionService:BindActionAtPriority(SINK, function() return Enum.ContextActionResult.Sink end, false, Enum.ContextActionPriority.High.Value + 1, Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseWheel, Enum.UserInputType.MouseMovement)
        end
    end
    table.insert(self._cleanups, function() applyLock(false); if Blur then Blur:Destroy() end end)
    function Window:SetLockInput(v) Library.LockInput = v; applyLock(self.Open) end
    function Window:SetBlur(v) Library.BlurEnabled = v; updateBlur() end
    local glowC
    function Window:SetGlow(on)
        if glowC then glowC:Disconnect(); glowC = nil end
        if on then
            glowC = Connect(RunService.RenderStepped, function()
                if not Root.Visible then return end
                local s = math.sin(tick() * 2.2)
                Glow.ImageTransparency = 0.72 + 0.12 * s
                MainStroke.Thickness = 1.5 + 0.5 * s
            end)
        else Glow.ImageTransparency = 1; MainStroke.Thickness = 1.5 end
    end
    function Window:_paintTabs(inst)
        local function set(o, p) if inst then for k, v in pairs(p) do o[k] = v end else Tween(o, 0.25, p) end end
        for _, t in ipairs(self.Tabs) do
            local act = (t == self.Current)
            set(t.Button, { BackgroundColor3 = Library.Accent, BackgroundTransparency = act and 0.8 or 1 })
            if t.IconIsImage then set(t.Icon, { ImageColor3 = act and Library.Accent or C.TextDim })
            else set(t.Icon, { TextColor3 = act and Library.Accent or C.TextDim }) end
            set(t.Label, { TextColor3 = act and C.Text or C.TextDim })
            set(t.Bar, { Size = UDim2.new(0, 3, 0, act and 18 or 0) })
        end
    end
    OnTheme(function() Window:_paintTabs(true) end)
    function Window:_layoutTabs() for _, t in ipairs(self.Tabs) do t._layout() end end
    function Window:AnimateTab()
        local tab = self.Current
        if not tab then return end
        for idx, sec in ipairs(tab.Sections) do
            sec.GroupTransparency = 1
            task.delay((idx - 1) * 0.07, function() if sec.Parent then Tween(sec, 0.35, { GroupTransparency = 0 }) end end)
        end
    end
    function Window:SelectTab(tab)
        self.Current = tab
        for _, t in ipairs(self.Tabs) do t.Page.Visible = (t == tab) end
        self:_paintTabs(false)
        if tab then
            tab.Page.Position = UDim2.new(0, 0, 0, 10)
            Tween(tab.Page, 0.25, { Position = UDim2.new(0, 0, 0, 0) })
            self:AnimateTab()
        end
    end
    function Window:AddTab(name, icon)
        local Tab = { Sections = {}, Name = name }
        local page = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, _A = { "ScrollBarImageColor3" }, Parent = PageC })
        Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
        Create("UIPadding", { PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 6), Parent = page })
        local btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 36), Text = "", AutoButtonColor = false, BackgroundTransparency = 1, LayoutOrder = #Window.Tabs + 1, Parent = TabList })
        Corner(btn, 8); AddRipple(btn)
        local hI = icon ~= nil
        local isImg = hI and (type(icon) == "number" or tostring(icon):find("rbxasset") ~= nil)
        local ico
        if isImg then ico = Create("ImageLabel", { Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1, Image = type(icon) == "number" and ("rbxassetid://" .. icon) or icon, Parent = btn })
        else ico = Create("TextLabel", { Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1, Text = hI and tostring(icon) or name:sub(1, 1):upper(), Font = Enum.Font.GothamBold, TextSize = 15, Parent = btn }) end
        local lbl = Create("TextLabel", { Text = name, Font = Enum.Font.GothamMedium, TextSize = 13, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
        local bar = Create("Frame", { Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BorderSizePixel = 0, _A = { "BackgroundColor3" }, Parent = btn })
        Corner(bar, 2, true)
        Tab.Page, Tab.Button, Tab.Bar, Tab.Icon, Tab.Label = page, btn, bar, ico, lbl
        Tab.IconIsImage = isImg
        Tab._layout = function()
            if compact then ico.Visible = true; ico.Position = UDim2.new(0.5, -9, 0.5, -9); lbl.Visible = false
            else
                ico.Visible = hI
                ico.Position = UDim2.new(0, 14, 0.5, -9)
                local x = hI and 40 or 14
                lbl.Visible = true
                lbl.Position = UDim2.new(0, x, 0, 0)
                lbl.Size = UDim2.new(1, -(x + 4), 1, 0)
            end
        end
        Tab._layout()
        table.insert(Window.Tabs, Tab)
        Connect(btn.MouseButton1Click, function() Window:SelectTab(Tab) end)
        if #Window.Tabs == 1 then Window.Current = Tab; Window:SelectTab(Tab) else Window:_paintTabs(true) end
        function Tab:AddSection(title)
            local S = {}
            local frame = Create("CanvasGroup", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, LayoutOrder = Order(), _T = { BackgroundColor3 = "Section" }, Parent = page })
            Corner(frame, 10); Stroke(frame, "Border", 1, 0.4)
            Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })
            Create("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = frame })
            Label(frame, title, 13, Enum.Font.GothamBold, "Accent", { Size = UDim2.new(1, 0, 0, 20), LayoutOrder = Order() })
            table.insert(Tab.Sections, frame)
            S.Frame = frame
            function S:AddToggle(o) return Components.Toggle(frame, o) end
            function S:AddSlider(o) return Components.Slider(frame, o) end
            function S:AddButton(o) return Components.Button(frame, o) end
            function S:AddKeybind(o) return Components.Keybind(frame, o) end
            function S:AddDropdown(o) return Components.Dropdown(frame, o) end
            function S:AddTextbox(o) return Components.Textbox(frame, o) end
            function S:AddLabel(o) return Components.Label(frame, type(o) == "string" and { Text = o } or o) end
            function S:AddSeparator() return Components.Separator(frame) end
            function S:AddColorPicker(o) return Components.ColorPicker(frame, o) end
            return S
        end
        return Tab
    end
    local Float = Create("TextButton", { Size = UDim2.new(0, 48, 0, 48), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0), Text = "=", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Visible = false, _A = { "BackgroundColor3" }, Parent = GUI })
    Corner(Float, 24, true); Stroke(Float, Color3.new(1,1,1), 1.5, 0.7)
    local fDrag, fStart, fPos, fMoved
    Connect(Float.InputBegan, function(i) if isPress(i) then fDrag, fMoved, fStart, fPos = true, false, i.Position, Float.Position end end)
    Connect(UIS.InputChanged, function(i)
        if fDrag and isMove(i) then
            local d = i.Position - fStart
            if d.Magnitude > 8 then fMoved = true end
            if fMoved then Float.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y) end
        end
    end)
    Connect(UIS.InputEnded, function(i) if fDrag and isPress(i) then fDrag = false; if not fMoved then Window:Toggle() end end end)
    local function ApplyLayout()
        local sw = compact and 56 or 150
        Sidebar.Size = UDim2.new(0, sw, 1, -82)
        PageC.Size = UDim2.new(1, -(sw + 36), 1, -82)
        PageC.Position = UDim2.new(0, sw + 24, 0, 50)
        PName.Visible = not compact; PUser.Visible = not compact
        Avatar.Position = compact and UDim2.new(0.5, -15, 0.5, -15) or UDim2.new(0, 7, 0.5, -15)
        local sz = compact and compactSize or fullSize
        Root.Size = UDim2.new(0, sz.X, 0, sz.Y)
        grip.Visible = not compact; Float.Visible = compact
        local cam = workspace.CurrentCamera
        baseScale = 1
        if cam then baseScale = math.clamp(cam.ViewportSize.X / (sz.X + 60), 0.5, 1) end
        if Window.Open then Scale.Scale = baseScale end
        Window:_layoutTabs()
    end
    function Window:SetCompact(v) compact = v and true or false; ApplyLayout() end
    function Window:Toggle(force)
        if not self.Loaded then return end
        if force == nil then force = not self.Open end
        self.Open = force
        if force then
            Root.Visible = true
            Tween(Scale, 0.3, { Scale = baseScale }, Enum.EasingStyle.Back)
            self:AnimateTab()
        else
            Tween(Scale, 0.18, { Scale = 0 })
            task.delay(0.19, function() if not self.Open then Root.Visible = false end end)
        end
        applyLock(force); updateBlur()
    end
    function Window:WaitLoaded() while not self.Loaded do task.wait() end end
    function Window:SetOpacity(p) Library:SetOpacity(p) end
    Connect(UIS.InputBegan, function(i, gp) if gp or Library.Capturing then return end; if i.KeyCode == Window.ToggleKey then Window:Toggle() end end)
    ApplyLayout(); Window:_paintTabs(true)
    local function finishLoad() Window.Loaded = true; Window:Toggle(true) end
    if splashG then
        task.spawn(function()
            local steps = { "Carregando tema...", "Montando interface...", "Aplicando configs...", "Pronto!" }
            local total = opts.SplashTime or 1.4
            for idx, txt in ipairs(steps) do
                splashS.Text = txt
                Tween(splashF, total / #steps, { Size = UDim2.new(idx / #steps, 0, 1, 0) }, Enum.EasingStyle.Linear)
                task.wait(total / #steps)
            end
            Tween(splashG, 0.3, { GroupTransparency = 1 })
            task.wait(0.3); splashG:Destroy(); finishLoad()
        end)
    else finishLoad() end
    self.Window = Window
    return Window
end

function Library:Notify(o)
    if not self._notifHolder then return end
    o = o or {}
    local key = (o.Title or "") .. "|" .. (o.Message or "")
    local now = tick()
    if self._lastNotif[key] and (now - self._lastNotif[key]) < 0.5 then return function() end end
    self._lastNotif[key] = now
    for k, t in pairs(self._lastNotif) do if (now - t) > 5 then self._lastNotif[k] = nil end end
    local kind = o.Type or "info"
    local colors = { info = self.Accent, success = RGB(80, 220, 120), warn = RGB(255, 190, 60), error = RGB(255, 90, 90) }
    local glyphs = { info = "i", success = "+", warn = "!", error = "x" }
    local col = colors[kind] or self.Accent
    local dur = o.Duration or 3
    while #self._notifs >= 5 do local oldest = table.remove(self._notifs, 1); oldest() end
    local wrap = Create("Frame", { Size = UDim2.new(1, 0, 0, 66), BackgroundTransparency = 1, LayoutOrder = Order(), Parent = self._notifHolder })
    local n = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(1.2, 0, 0, 0), Text = "", AutoButtonColor = false, BorderSizePixel = 0, ClipsDescendants = true, BackgroundColor3 = C.Section, BackgroundTransparency = self.BgTransp, Parent = wrap })
    Create("UICorner", { CornerRadius = UDim.new(0, math.floor(10 * self.Roundness / 8 + 0.5)), Parent = n })
    Create("UIStroke", { Color = col, Thickness = 1, Transparency = 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = n })
    local badge = Create("Frame", { Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 12, 0, 12), BackgroundColor3 = col, BackgroundTransparency = 0.8, BorderSizePixel = 0, Parent = n })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badge })
    Create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = glyphs[kind] or "i", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = col, Parent = badge })
    Create("TextLabel", { Size = UDim2.new(1, -62, 0, 20), Position = UDim2.new(0, 50, 0, 8), BackgroundTransparency = 1, Text = o.Title or "Aviso", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = n })
    Create("TextLabel", { Size = UDim2.new(1, -62, 0, 28), Position = UDim2.new(0, 50, 0, 28), BackgroundTransparency = 1, Text = o.Message or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.TextDim, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Parent = n })
    local closed = false
    local function close()
        if closed then return end
        closed = true
        local idx = table.find(self._notifs, close)
        if idx then table.remove(self._notifs, idx) end
        Tween(n, 0.3, { Position = UDim2.new(1.2, 0, 0, 0) }, Enum.EasingStyle.Quint)
        task.delay(0.32, function() wrap:Destroy() end)
    end
    table.insert(self._notifs, close)
    n.MouseButton1Click:Connect(close)
    Tween(n, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)
    if dur > 0 then
        local prog = Create("Frame", { Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3), BackgroundColor3 = col, BorderSizePixel = 0, Parent = n })
        Tween(prog, dur, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)
        task.delay(dur, close)
    end
    return close
end

local function encode(v)
    local t = typeof(v)
    if t == "Color3" then return { __t = "Color3", r = v.R, g = v.G, b = v.B } end
    if t == "EnumItem" then return { __t = "Key", n = v.Name } end
    return v
end
local function decode(v)
    if type(v) == "table" then
        if v.__t == "Color3" then return Color3.new(v.r, v.g, v.b) end
        if v.__t == "Key" then return Enum.KeyCode[v.n] end
    end
    return v
end
function Library:SaveConfig(name)
    if not (writefile and isfolder and makefolder) then return false, "sem suporte" end
    local data = {}
    for k, v in pairs(self.Flags) do data[k] = encode(v) end
    local ok, err = pcall(function()
        if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
        writefile(self.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
    return ok, err
end
function Library:LoadConfig(name)
    if not (readfile and isfile) then return false, "sem suporte" end
    local path = self.ConfigFolder .. "/" .. name .. ".json"
    if not isfile(path) then return false, "nao encontrada" end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok then return false, "invalido" end
    for k, v in pairs(data) do
        local setter = self.Setters[k]
        if setter then pcall(setter, decode(v)) end
    end
    return true
end
function Library:Unload()
    for _, fn in ipairs(self._cleanups) do pcall(fn) end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Connections); table.clear(Registry); table.clear(Corners); table.clear(Hooks)
    table.clear(self._cleanups); table.clear(self._notifs)
    self._lastNotif = nil
    if self.Gui then self.Gui:Destroy() end
    self._notifHolder = nil
end

--================================================--
-- CFG (compartilhado)
--================================================--
local CFG = {
    Aimbot=false, Trigger=false, TeamCheck=false, WallCheck=false, AimPart="Head", FOV=120, FOVVisible=true, Smooth=0.15,
    HitboxSize=2, HitboxEnabled=false, KillAura=false, KillAuraRange=20,
    SilentAim=false, AutoShoot=false, AutoShootFOV=5, FOVChanger=false, FOVValue=90,
    WalkSpeed=16, JumpPower=50, Noclip=false, InfJump=false,
    Fly=false, FlySpeed=18, Spin=false, SpinSpeed=150, Invisible=false,
    BHop=false, CrouchSpam=false, AntiFling=false,
    ESP=false, Tracers=false, Chams=false, Skeleton=false, ESPColor=RGB(170,0,255),
    FullBright=false, NoFog=false, RainbowFloor=false, WeaponESP=false, HealthNum=false,
    StreamerMode=false, StreamerFull=false, StreamerHideWM=false,
    ThirdPerson=false, TP_Distance=14, TP_Height=2, TP_Shoulder=0, TP_Sensitivity=0.15, TP_InvertY=false,
    AutoClicker=false, AntiAFK=false, AntiAFKv2=false, InstantPrompt=false, ClickTP=false,
    ZoomKey=Enum.KeyCode.RightShift, ZoomValue=30, GhostMode=true, GhostDistance=60,
    MobMagnet=false, MobMagnetRadius=60,
    AntiFlingV2=false, AntiStun=false, ReduceLag=false, ReduceLagNPCs=false, ReduceLagParticles=true,
    AutoRaidComplete=false, FruitSniperHop=false, AutoFarmRoute=false,
    D_WalkSpeed=16, D_Noclip=false, D_InfJump=false, D_InstantInteract=false, D_AutoHeartbeat=false,
    D_Brightness=0, D_FullBright=false, D_NoFog=false,
    D_ESPEntities=false, D_ESPObjective=false, D_ESPItems=false,
    D_AntiJumpscare=false, D_FigureGod=false, D_ChatNotif=false, D_AutoLoot=false, D_MuteJeff=false,
    D_AntiA90=false, D_AntiDread=false, D_AntiScreech=false, D_AntiGiggle=false, D_AntiHaste=false, D_AntiCamShake=false,
    MM2_ESP_Murderer=false, MM2_ESP_Sheriff=false, MM2_ESP_Innocent=false,
    MM2_AutoShoot=false, MM2_ShootRange=100, MM2_Speed=16, MM2_Jump=50, MM2_InfJump=false,
    MM2_AntiFling=false, MM2_FullBright=false,
    MM2_KillAura=false, MM2_KA_Range=10, MM2_AutoThrow=false, MM2_AutoPickupGun=false,
    MM2_DropESP=false, MM2_EspPro=true, MM2_AntiTP=false,
    AdminDetect=true, AdminNotify=true,
    QuickSaveKey=Enum.KeyCode.F1, QuickLoadKey=Enum.KeyCode.F2,
    AutoFruitSniper=false, FruitESP=false, AutoStoreFruit=false, AutoFarmBoss=false,
    AutoFarmMasteryMelee=false, AutoFarmChest=false, AutoFarmMaterials=false,
    AutoEliteHunter=false, AutoFishing=false, AutoRaceEvo=false,
    AutoBuyMelee=false, AutoBuySword=false, AutoBuyGun=false,
}

--================================================--
-- HELPERS DE JOGO
--================================================--
local function GetChar(plr)
    local ch = plr.Character
    if not ch or not ch.Parent then return nil, nil, nil end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return ch, nil, nil end
    local hrp = hum.RootPart or ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart
    if not hrp then
        for _, v in ipairs(ch:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then hrp = v; break end
        end
    end
    return ch, hum, hrp
end
local function FindPart(ch, names)
    for _, n in ipairs(names) do
        local p = ch:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    for _, v in ipairs(ch:GetDescendants()) do
        if v:IsA("BasePart") then
            for _, n in ipairs(names) do if v.Name == n then return v end end
        end
    end
    return nil
end
local function GetAim(char) return FindPart(char, { CFG.AimPart, "Head", "UpperTorso", "Torso", "HumanoidRootPart" }) end
local function DetectRig(ch)
    if ch:FindFirstChild("UpperTorso") then return "R15" end
    if ch:FindFirstChild("Torso") then return "R6" end
    return "Unknown"
end
local function GetBones(rig)
    if rig == "R15" then
        return {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
    else
        return {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
    end
end
local function click1()
    local x, y = Mouse.X, Mouse.Y
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end
local function IsVis(p)
    if not p then return false end
    local o = Camera:GetPartsObscuringTarget({p.Position}, {LP.Character, p.Parent})
    return #o == 0
end
local function getChat()
    if ChatRemote and ChatRemote.Parent then return ChatRemote end
    pcall(function()
        local ce = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if ce then ChatRemote = ce:FindFirstChild("SayMessageRequest") end
    end)
    return ChatRemote
end
local function sendChat(m) local r = getChat(); if r then pcall(function() r:FireServer(m, "All") end) end end
local function reduceLag()
    local n = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            if CFG.ReduceLagParticles then v.Enabled = false; n += 1 end
        elseif CFG.ReduceLagNPCs and v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(v) then
            v:Destroy(); n += 1
        end
    end
    return n
end
local function serverHop()
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    if not ok then return false end
    for _, s in pairs(res) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id); return true
        end
    end
    return false
end
local function getMM2Role(plr)
    local ch = plr.Character
    if not ch then return "Innocent" end
    if ch:FindFirstChild("Knife") then return "Murderer" end
    if ch:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end
local function getMM2List()
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then table.insert(l, { plr = p, role = getMM2Role(p) }) end
    end
    return l
end

--================================================--
-- HOOKS
--================================================--
local FlyState = { Active = false }
local flying = false
if getrawmetatable and setreadonly then
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        pcall(function()
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local m = getnamecallmethod()
                if FlyState.Active and m == "FireServer" then
                    if self.Name == "SetInAir" or self.Name == "Jump" then return nil end
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end)
    end
end

local SilentAim = { Enabled = false, Target = nil, Part = "Head" }
if hookmetamethod then
    local oldI
    pcall(function()
        oldI = hookmetamethod(game, "__index", function(self, k)
            if SilentAim.Enabled and SilentAim.Target then
                local ch = SilentAim.Target.Character
                local p = ch and ch:FindFirstChild(SilentAim.Part)
                if p then
                    if k == "Hit" then return CFrame.new(p.Position)
                    elseif k == "Target" then return p end
                end
            end
            return oldI(self, k)
        end)
    end)
end

--================================================--
-- THIRD PERSON
--================================================--
local TPCam = { Yaw = 0, Pitch = -15, Active = false }
UIS.InputChanged:Connect(function(i)
    if not CFG.ThirdPerson then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement then
        local s = CFG.TP_Sensitivity
        TPCam.Yaw = TPCam.Yaw - i.Delta.X * s
        TPCam.Pitch = TPCam.Pitch - i.Delta.Y * s * (CFG.TP_InvertY and -1 or 1)
        TPCam.Pitch = math.clamp(TPCam.Pitch, -80, 80)
    end
end)
RunService:BindToRenderStep("PTPCam", Enum.RenderPriority.Camera.Value + 1, function(_dt)
    if not CFG.ThirdPerson then
        if TPCam.Active then
            TPCam.Active = false
            local ch = LP.Character
            local h = ch and ch:FindFirstChildOfClass("Humanoid")
            if h then Camera.CameraSubject = h; Camera.CameraType = Enum.CameraType.Custom end
        end
        return
    end
    local ch = LP.Character; if not ch then return end
    local h = ch:FindFirstChildOfClass("Humanoid"); local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not h or not hrp or h.Health <= 0 then return end
    TPCam.Active = true
    Camera.CameraType = Enum.CameraType.Scriptable
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
    local fp = hrp.Position + Vector3.new(0, CFG.TP_Height, 0)
    local rot = CFrame.fromEulerAnglesYXZ(math.rad(TPCam.Pitch), math.rad(TPCam.Yaw), 0)
    local co = rot.LookVector * -CFG.TP_Distance
    local so = rot.RightVector * CFG.TP_Shoulder
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { ch }
    rp.IgnoreWater = true
    local rr = workspace:Raycast(fp, co, rp)
    if rr then co = co.Unit * (rr.Distance - 0.5) end
    Camera.CFrame = CFrame.lookAt(fp + co + so, fp)
end)

--================================================--
-- ANTIPEEK
--================================================--
local AntiPeek = { Enabled = true }
task.spawn(function()
    while task.wait(0.15) do
        if not AntiPeek.Enabled then continue end
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LP or not p.Character then continue end
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if part.LocalTransparencyModifier >= 0.95 and part.Transparency < 0.95 then
                            part.LocalTransparencyModifier = part.Transparency
                        end
                    end
                end
            end
        end)
    end
end)

--================================================--
-- BYPASS
--================================================--
local Bypass = {
    Enabled = true,
    Modules = { PositionIntegrity = true, VelocityGuard = true, LOSValidator = true },
    Config = { MaxWalkSpeed = 20, MaxJumpPower = 150, MaxFlySpeed = 18 }
}
function Bypass:SafeTeleport(hrp, cfr)
    if not self.Enabled or not self.Modules.PositionIntegrity then hrp.CFrame = cfr; return end
    local sp = hrp.Position; local tp = cfr.Position
    local d = tp - sp; local dist = d.Magnitude
    if dist < 1 then hrp.CFrame = cfr; return end
    local steps = math.max(1, math.ceil(dist / 0.9)); local sv = d / steps
    task.spawn(function()
        for i = 1, steps do
            if not hrp or not hrp.Parent then break end
            local np = sp + sv * i
            if not pcall(function() hrp.CFrame = CFrame.new(np, np + hrp.CFrame.LookVector) end) then break end
            task.wait(0.05)
        end
        pcall(function() hrp.CFrame = CFrame.new(hrp.Position, cfr.Position + cfr.LookVector) end)
    end)
end
function Bypass:SafeWalkSpeed(h, d)
    if not self.Enabled or not self.Modules.VelocityGuard then h.WalkSpeed = d; return end
    local c = math.clamp(d, 16, self.Config.MaxWalkSpeed)
    if math.abs(h.WalkSpeed - c) < 0.1 then return end
    pcall(function() h.WalkSpeed = c end)
end
function Bypass:SafeJumpPower(h, d)
    if not self.Enabled or not self.Modules.VelocityGuard then h.JumpPower = d; return end
    local c = math.clamp(d, 50, self.Config.MaxJumpPower)
    pcall(function() h.JumpPower = c end)
end
local LOSP = RaycastParams.new()
LOSP.IgnoreWater = true
function Bypass:HasLOS(fp, tp, maxD)
    if not self.Enabled or not self.Modules.LOSValidator then return true end
    if not fp or not tp then return false end
    local o = fp.Position; local t = tp.Position
    local d = t - o; local dist = d.Magnitude
    if maxD and dist > maxD then return false end
    LOSP.FilterDescendantsInstances = { LP.Character, tp.Parent }
    LOSP.FilterType = Enum.RaycastFilterType.Exclude
    local r = workspace:Raycast(o, d, LOSP)
    if not r then return true end
    return r.Distance >= dist - 0.5
end
local PartB = {}
function Bypass:SafeHitbox(p, size)
    if not p then return end
    if not PartB[p] then PartB[p] = { Size = p.Size } end
    local om = math.max(p.Size.X, p.Size.Y, p.Size.Z)
    local c = math.clamp(size.X, om, 8)
    pcall(function() p.Size = Vector3.new(c, c, c) end)
end
function Bypass:RestoreAllHitboxes()
    for p, b in pairs(PartB) do
        if p and p.Parent then pcall(function() p.Size = b.Size end) end
    end
    table.clear(PartB)
end
task.spawn(function()
    while task.wait(1) do
        if not CFG.HitboxEnabled then Bypass:RestoreAllHitboxes() end
    end
end)

--================================================--
-- RETURN MODULE
--================================================--
return {
    Library = Library,
    CFG = CFG,
    RGB = RGB,
    Themes = Themes,
    C = C,
    IS_BLOX_FRUITS = IS_BLOX_FRUITS,
    IS_DOORS = IS_DOORS,
    IS_MM2 = IS_MM2,
    GAME_NAME = GAME_NAME,
    getCommF = getCommF,
    GetChar = GetChar,
    FindPart = FindPart,
    GetAim = GetAim,
    DetectRig = DetectRig,
    GetBones = GetBones,
    click1 = click1,
    IsVis = IsVis,
    sendChat = sendChat,
    reduceLag = reduceLag,
    serverHop = serverHop,
    getMM2Role = getMM2Role,
    getMM2List = getMM2List,
    encode = encode,
    decode = decode,
    Bypass = Bypass,
    AntiPeek = AntiPeek,
    SilentAim = SilentAim,
    TPCam = TPCam,
    FlyState = FlyState,
    flyRef = function() return flying end,
    setFlying = function(v) flying = v end,
    setFlyActive = function(v) FlyState.Active = v end,
}
