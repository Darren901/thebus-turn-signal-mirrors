-- TurnSignalMirrors
-- 打方向燈時才顯示該側的 HUD 後視鏡（Tab 編輯模式加的那幾個視窗）。
-- 需求：HUD 後視鏡要先在 Tab 編輯模式裡打開，這支 mod 只負責「藏/顯示」。
--
-- 熱鍵：Ctrl+F11 = 開/關這個 mod（關閉時後視鏡恢復常駐）
--       Ctrl+F12 = 在 UE4SS.log 印出目前狀態（除錯用）

----------------------------------------------------------------------
-- 設定
----------------------------------------------------------------------
local Config = {
    HoldSeconds        = 1.5,   -- 方向燈關掉後，後視鏡多留幾秒才收
    ShowBothOnHazard   = false, -- 雙閃時兩邊都顯示
    IncludeRightWheel  = true,  -- 右側的「輪邊鏡」(Mirror_Right_Wheel) 也跟著右燈
    PollMs             = 100,
}

----------------------------------------------------------------------
local Enabled    = true
local EditMode   = false
local HookDone   = false
local Applied    = {}   -- [widgetAddr] = last opacity
local LastLeft   = -1e9 -- 上次左燈亮著的時間
local LastRight  = -1e9
local Clock      = 0

local IndicatorState = { Off = 0, Left = 1, Right = 2 }

local function Log(msg) print("[TSM] " .. msg .. "\n") end

local function Valid(o) return o ~= nil and o:IsValid() end

local function GetPawn()
    local pc = FindFirstOf("PlayerController")
    if not Valid(pc) then return nil end
    local pawn = pc.Pawn
    if Valid(pawn) then return pawn end
    return nil
end

-- 找屬於玩家目前這台車的方向燈模組（街上 AI 車也各有一個）
local function GetIndicator(pawn)
    local pawnAddr = pawn:GetAddress()
    for _, cls in ipairs({ "BP_IndicatorModule_C", "IndicatorModule" }) do
        local mods = FindAllOf(cls)
        if mods then
            for _, m in ipairs(mods) do
                if Valid(m) then
                    local outer = m:GetOuter()
                    if Valid(outer) and outer:GetAddress() == pawnAddr then
                        return m
                    end
                end
            end
        end
    end
    return nil
end

-- 回傳 "L" / "R" / nil
local function WidgetSide(w, pawnAddr)
    local comp = w["Mirror Component"]
    if not Valid(comp) then return nil end
    local owner = comp:GetOuter()
    if pawnAddr and (not Valid(owner) or owner:GetAddress() ~= pawnAddr) then return nil end
    local name = comp:GetFName():ToString()
    if string.find(name, "Mirror_Left", 1, true) then return "L" end
    if string.find(name, "Mirror_Right", 1, true) then
        if not Config.IncludeRightWheel and string.find(name, "Wheel", 1, true) then return nil end
        return "R"
    end
    return nil
end

local function SetOpacity(w, value)
    local addr = w:GetAddress()
    if Applied[addr] == value then return end
    w:SetRenderOpacity(value)
    Applied[addr] = value
end

local function RestoreAll()
    local widgets = FindAllOf("UMG_MirrorHUD_C")
    if widgets then
        for _, w in ipairs(widgets) do
            if Valid(w) then w:SetRenderOpacity(1.0) end
        end
    end
    Applied = {}
end

local function TryHookEditMode()
    if HookDone then return end
    local ok = pcall(function()
        RegisterHook("/Game/UI/HUD/UMG_MirrorHUD.UMG_MirrorHUD_C:SetIsInEditMode", function(self, mode)
            EditMode = mode:get()
        end)
    end)
    HookDone = true
    if not ok then Log("edit-mode hook unavailable; mirrors stay hidden in Tab mode unless a signal is on") end
end

local function Tick()
    if not Enabled then return end

    local pawn = GetPawn()
    if not pawn then return end
    local ind = GetIndicator(pawn)
    if not ind then return end  -- 不在車上（走路中）就不動任何東西

    local widgets = FindAllOf("UMG_MirrorHUD_C")
    if not widgets then return end
    TryHookEditMode()

    local state  = ind.IndicatorState
    local hazard = ind.WarningLights
    if state == IndicatorState.Left  then LastLeft  = Clock end
    if state == IndicatorState.Right then LastRight = Clock end
    if Config.ShowBothOnHazard and hazard then LastLeft = Clock; LastRight = Clock end

    local showL = EditMode or (Clock - LastLeft)  <= Config.HoldSeconds
    local showR = EditMode or (Clock - LastRight) <= Config.HoldSeconds

    local pawnAddr = pawn:GetAddress()
    for _, w in ipairs(widgets) do
        if Valid(w) then
            local side = WidgetSide(w, pawnAddr)
            if side == "L" then SetOpacity(w, showL and 1.0 or 0.0)
            elseif side == "R" then SetOpacity(w, showR and 1.0 or 0.0) end
        end
    end
end

LoopAsync(Config.PollMs, function()
    Clock = Clock + Config.PollMs / 1000
    ExecuteInGameThread(function()
        local ok, err = pcall(Tick)
        if not ok then Log("tick error: " .. tostring(err)) end
    end)
    return false
end)

RegisterKeyBind(Key.F11, { ModifierKey.CONTROL }, function()
    Enabled = not Enabled
    ExecuteInGameThread(function()
        if not Enabled then RestoreAll() else Applied = {} end
    end)
    Log("enabled = " .. tostring(Enabled))
end)

RegisterKeyBind(Key.F12, { ModifierKey.CONTROL }, function()
    ExecuteInGameThread(function()
        local pawn = GetPawn()
        Log("---- status ----")
        Log("enabled=" .. tostring(Enabled) .. " editMode=" .. tostring(EditMode))
        if not pawn then Log("no pawn"); return end
        Log("pawn=" .. pawn:GetFullName())
        local ind = GetIndicator(pawn)
        if ind then
            Log("indicator=" .. ind:GetFullName() .. " state=" .. tostring(ind.IndicatorState) .. " hazard=" .. tostring(ind.WarningLights))
        else
            Log("indicator not found on pawn")
        end
        local widgets = FindAllOf("UMG_MirrorHUD_C") or {}
        local pawnAddr = pawn:GetAddress()
        for _, w in ipairs(widgets) do
            if Valid(w) then
                local comp = w["Mirror Component"]
                local cname = Valid(comp) and comp:GetFName():ToString() or "nil"
                Log(string.format("widget %s comp=%s side=%s opacity=%s",
                    w:GetFName():ToString(), cname, tostring(WidgetSide(w, pawnAddr)), tostring(w:GetRenderOpacity())))
            end
        end
    end)
end)

Log("TurnSignalMirrors loaded (Ctrl+F11 toggle, Ctrl+F12 status)")
