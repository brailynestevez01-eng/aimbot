local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Configuración inicial
local aimlockEnabled = false
local FOV = 1000
local smoothness = 0.3
local lineThickness = 2
local lineColor = Color3.fromRGB(255,0,0)

-- Crear Drawing Line
local line = Drawing.new("Line")
line.Visible = false
line.Color = lineColor
line.Thickness = lineThickness

-- Función para encontrar enemigo más cercano
local function getClosestEnemy()
	local closestPlayer = nil
	local shortestDistance = FOV

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
			if onScreen then
				local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
				local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end

-- Actualizar Aimlock
RunService.RenderStepped:Connect(function()
	if aimlockEnabled then
		local target = getClosestEnemy()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local root = target.Character.HumanoidRootPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local mouse = LocalPlayer:GetMouse()
				local targetPos = Vector2.new(screenPos.X, screenPos.Y)
				local mousePos = Vector2.new(mouse.X, mouse.Y)
				local newPos = mousePos:Lerp(targetPos, smoothness)
				mouse.X = newPos.X
				mouse.Y = newPos.Y

				line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
				line.To = targetPos
				line.Visible = true
			else
				line.Visible = false
			end
		else
			line.Visible = false
		end
	else
		line.Visible = false
	end
end)

-- Crear GUI
if game.CoreGui:FindFirstChild("AimlockMenu") then
	game.CoreGui.AimlockMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AimlockMenu"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0.05,0,0.6,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundColor3 = Color3.fromRGB(45,45,45)
Title.Text = "🎯 Aimlock"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- Botón activar/desactivar
local toggleBtn = Instance.new("TextButton", Frame)
toggleBtn.Size = UDim2.new(1,-10,0,30)
toggleBtn.Position = UDim2.new(0,5,0,40)
toggleBtn.Text = "Activar Aimlock"
toggleBtn.BackgroundColor3 = Color3.fromRGB(70,130,180)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.MouseButton1Click:Connect(function()
	aimlockEnabled = not aimlockEnabled
	toggleBtn.Text = aimlockEnabled and "Desactivar Aimlock" or "Activar Aimlock"
end)

-- Barra para ajustar FOV
local fovLabel = Instance.new("TextLabel", Frame)
fovLabel.Size = UDim2.new(1,-10,0,20)
fovLabel.Position = UDim2.new(0,5,0,80)
fovLabel.Text = "FOV: "..FOV
fovLabel.TextColor3 = Color3.fromRGB(255,255,255)
fovLabel.BackgroundTransparency = 1
fovLabel.Font = Enum.Font.SourceSans
fovLabel.TextSize = 14

-- Ajuste con teclas Up/Down
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Up then
		FOV = FOV + 50
		fovLabel.Text = "FOV: "..FOV
	elseif input.KeyCode == Enum.KeyCode.Down then
		FOV = math.max(50, FOV - 50)
		fovLabel.Text = "FOV: "..FOV
	end
end)

print("✅ Menú Aimlock cargado. Usa el botón para activar/desactivar y flechas Up/Down para FOV.")
