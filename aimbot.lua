-- AIMBOT PEGADO PARA Blox Fruits (Hard Lock)
-- Recomendado solo para pruebas privadas.

-- Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configuración
local enabled = false
local FOV = 1000 -- Radio en píxeles
local targetPartName = "Head" -- "Head" o "HumanoidRootPart"
local showLine = true

-- Función para mostrar logs
local function log(msg)
    if rconsoleprint then
        rconsoleprint("[AimLock] "..tostring(msg).."\n")
    else
        print("[AimLock] "..tostring(msg))
    end
end

-- Esperar a que la cámara y el jugador estén listos
repeat task.wait() until Camera and LocalPlayer

log("Player y cámara listos.")

-- Dibujar la línea (si Drawing está disponible)
local drawLine
if pcall(function() return Drawing end) then
    local success, err = pcall(function()
        drawLine = Drawing.new("Line")
        drawLine.Visible = false
        drawLine.Color = Color3.fromRGB(255,0,0)
        drawLine.Thickness = 2
    end)
    if not success then
        drawLine = nil
        log("Warning: No se pudo crear la línea. Error: "..tostring(err))
    end
end

-- Función para encontrar el objetivo más cercano
local function getClosestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best = nil
    local bestDist = FOV
    
    -- Buscar los jugadores cercanos
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(targetPartName) then
            local part = player.Character:FindFirstChild(targetPartName)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = {player = player, part = part, screen = Vector2.new(screenPos.X, screenPos.Y)}
                    end
                end
            end
        end
    end
    return best
end

-- Apuntar y bloquear en el objetivo (hard-lock)
local aimConn
aimConn = RunService.RenderStepped:Connect(function()
    if not enabled then
        if drawLine then drawLine.Visible = false end
        return
    end

    local target = getClosestTarget()
    if target and target.player and target.part then
        -- Ajustamos la cámara para mirar al objetivo
        local camPos = Camera.CFrame.Position
        local aimCFrame = CFrame.new(camPos, target.part.Position)
        Camera.CFrame = aimCFrame

        -- Dibujar línea al objetivo (opcional)
        if drawLine and showLine then
            drawLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            drawLine.To = target.screen
            drawLine.Visible = true
        end
    else
        if drawLine then drawLine.Visible = false end
    end
end)

-- GUI simple para activar/desactivar y configurar
if game.CoreGui:FindFirstChild("AimLockGUI") then game.CoreGui.AimLockGUI:Destroy() end
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "AimLockGUI"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0.7, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "🎯 AimLock"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 34)
toggleBtn.Text = "Activar AimLock"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 14
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local partLabel = Instance.new("TextLabel", frame)
partLabel.Size = UDim2.new(1, -10, 0, 20)
partLabel.Position = UDim2.new(0, 5, 0, 70)
partLabel.BackgroundTransparency = 1
partLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
partLabel.Text = "Parte: " .. targetPartName

local switchPartBtn = Instance.new("TextButton", frame)
switchPartBtn.Size = UDim2.new(1, -10, 0, 22)
switchPartBtn.Position = UDim2.new(0, 5, 0, 92)
switchPartBtn.Text = "Cambiar Parte (Head / HRP)"
switchPartBtn.Font = Enum.Font.SourceSans
switchPartBtn.TextSize = 14
switchPartBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
switchPartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local fovLabel = Instance.new("TextLabel", frame)
fovLabel.Size = UDim2.new(1, -10, 0, 18)
fovLabel.Position = UDim2.new(0, 5, 0, 118)
fovLabel.BackgroundTransparency = 1
fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovLabel.Text = "FOV: " .. FOV .. " (↑/↓ para ajustar)"

-- Activar / Desactivar Aimlock
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleBtn.Text = enabled and "Desactivar AimLock" or "Activar AimLock"
    log("AimLock: " .. (enabled and "ACTIVADO" or "DESACTIVADO"))
end)

-- Cambiar parte (Head / HumanoidRootPart)
switchPartBtn.MouseButton1Click:Connect(function()
    if targetPartName == "Head" then targetPartName = "HumanoidRootPart"
    else targetPartName = "Head" end
    partLabel.Text = "Parte: " .. targetPartName
    log("Parte objetivo ahora: " .. targetPartName)
end)

-- Ajuste FOV con las teclas ↑ y ↓
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Up then
        FOV = FOV + 100
        fovLabel.Text = "FOV: " .. FOV .. " (↑/↓ para ajustar)"
        log("FOV ajustado a: " .. FOV)
    elseif input.KeyCode == Enum.KeyCode.Down then
        FOV = math.max(50, FOV - 100)
        fovLabel.Text =

