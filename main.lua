-- Tiesas Private Weapon Lab
-- Vista previa universal, local y temporal para el propietario de un servidor
-- privado. No restringe el juego por nombre, creador ni GameId.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
if not localPlayer then return end

local isPrivateOwner = game.PrivateServerId ~= ""
	and game.PrivateServerOwnerId ~= 0
	and game.PrivateServerOwnerId == localPlayer.UserId

local function notify(title, message)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = message,
			Duration = 5,
		})
	end)
end

if not isPrivateOwner then
	notify(
		"Arsenal privado",
		"Solo funciona para el propietario de un servidor privado."
	)
	return
end

local environment = type(getgenv) == "function" and getgenv() or _G
local previousRuntime = environment.TIESAS_PRIVATE_WEAPON_LAB
if type(previousRuntime) == "table" and type(previousRuntime.stop) == "function" then
	pcall(previousRuntime.stop)
end

local runtime = {
	alive = true,
	connections = {},
	previews = {},
}
environment.TIESAS_PRIVATE_WEAPON_LAB = runtime

local function track(connection)
	table.insert(runtime.connections, connection)
	return connection
end

local function normalizeName(value)
	return string.lower(tostring(value)):gsub("[^%w]", "")
end

local weapons = {
	{
		label = "Corrupt azul",
		aliases = {"Blue Corrupt", "Corrupt Blue", "Corrupt Azul"},
	},
	{
		label = "Luger azul",
		aliases = {"Blue Luger", "Luger Blue", "Luger Azul"},
	},
	{
		label = "Voidscope",
		aliases = {"Voidscope", "Void Scope"},
	},
	{
		label = "Ban Hammer",
		aliases = {"Ban Hammer", "BanHammer"},
	},
}

local function findTemplate(aliases)
	local normalizedAliases = {}
	for _, alias in ipairs(aliases) do
		table.insert(normalizedAliases, normalizeName(alias))
	end

	for _, className in ipairs({"Tool", "Model", "BasePart"}) do
		for _, container in ipairs({ReplicatedStorage, workspace}) do
			for _, object in ipairs(container:GetDescendants()) do
				if object:IsA(className) then
					local objectName = normalizeName(object.Name)
					for _, alias in ipairs(normalizedAliases) do
						if objectName == alias
							or string.find(objectName, alias, 1, true) then
							return object
						end
					end
				end
			end
		end
	end
	return nil
end

local function removePreview(label)
	local preview = runtime.previews[label]
	runtime.previews[label] = nil
	if preview and preview.Parent then preview:Destroy() end
end

local function clearPreviews()
	local labels = {}
	for label in pairs(runtime.previews) do
		table.insert(labels, label)
	end
	for _, label in ipairs(labels) do
		removePreview(label)
	end
end

local screenGui
function runtime.stop()
	if not runtime.alive then return end
	runtime.alive = false
	clearPreviews()
	for _, connection in ipairs(runtime.connections) do
		pcall(function() connection:Disconnect() end)
	end
	table.clear(runtime.connections)
	if screenGui and screenGui.Parent then screenGui:Destroy() end
	if environment.TIESAS_PRIVATE_WEAPON_LAB == runtime then
		environment.TIESAS_PRIVATE_WEAPON_LAB = nil
	end
end

local function createPreview(weapon)
	if not runtime.alive then return end
	local current = runtime.previews[weapon.label]
	if current and current.Parent then
		notify("Arsenal privado", weapon.label .. " ya está en la mochila.")
		return
	end

	local template = findTemplate(weapon.aliases)
	if not template then
		notify(
			"Modelo no encontrado",
			"No se encontró " .. weapon.label .. " en ReplicatedStorage ni Workspace."
		)
		return
	end

	local clonedTemplate
	local cloned = pcall(function()
		clonedTemplate = template:Clone()
	end)
	if not cloned or not clonedTemplate then
		notify("Arsenal privado", "No se pudo clonar " .. weapon.label .. ".")
		return
	end

	local tool
	if clonedTemplate:IsA("Tool") then
		tool = clonedTemplate
	else
		tool = Instance.new("Tool")
		clonedTemplate.Parent = tool
	end
	tool.Name = "[Privado] " .. weapon.label
	tool.ToolTip = "Vista previa local; no se guarda"
	tool.CanBeDropped = false
	tool.ManualActivationOnly = true
	tool.Enabled = false

	-- Una vista previa nunca conserva código ni comunicación con el servidor.
	for _, object in ipairs(tool:GetDescendants()) do
		if object:IsA("LuaSourceContainer")
			or object:IsA("RemoteEvent")
			or object:IsA("RemoteFunction") then
			object:Destroy()
		end
	end

	local handle = tool:FindFirstChild("Handle", true)
	if not handle or not handle:IsA("BasePart") then
		handle = tool:FindFirstChildWhichIsA("BasePart", true)
	end
	if not handle then
		tool:Destroy()
		notify("Arsenal privado", weapon.label .. " no contiene piezas visibles.")
		return
	end

	handle.Name = "Handle"
	handle.Parent = tool
	for _, part in ipairs(tool:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			if part ~= handle then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = handle
				weld.Part1 = part
				weld.Parent = part
			end
		end
	end

	local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	if not backpack then
		tool:Destroy()
		notify("Arsenal privado", "No se encontró la mochila local.")
		return
	end

	tool.Parent = backpack
	runtime.previews[weapon.label] = tool
	notify("Desbloqueo temporal", weapon.label .. " añadida solo a este cliente.")
end

screenGui = Instance.new("ScreenGui")
screenGui.Name = "TiesasPrivateWeaponLab"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiParent = CoreGui
if type(gethui) == "function" then
	local ok, hiddenUi = pcall(gethui)
	if ok and hiddenUi then guiParent = hiddenUi end
end
screenGui.Parent = guiParent

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(370, 290)
panel.BackgroundColor3 = Color3.fromRGB(24, 19, 32)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(156, 102, 255)
panelStroke.Transparency = 0.25
panelStroke.Thickness = 2
panelStroke.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 14)
title.Size = UDim2.new(1, -70, 0, 34)
title.Font = Enum.Font.GothamBold
title.Text = "ARSENAL PRIVADO"
title.TextColor3 = Color3.fromRGB(240, 233, 255)
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(20, 48)
subtitle.Size = UDim2.new(1, -40, 0, 36)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Vista previa local · propietario del servidor privado"
subtitle.TextColor3 = Color3.fromRGB(178, 165, 200)
subtitle.TextSize = 13
subtitle.TextWrapped = true
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.BackgroundColor3 = Color3.fromRGB(68, 48, 88)
closeButton.Position = UDim2.new(1, -48, 0, 14)
closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 22
closeButton.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local grid = Instance.new("Frame")
grid.BackgroundTransparency = 1
grid.Position = UDim2.fromOffset(20, 92)
grid.Size = UDim2.new(1, -40, 0, 116)
grid.Parent = panel

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.fromOffset(10, 10)
gridLayout.CellSize = UDim2.new(0.5, -5, 0, 53)
gridLayout.FillDirectionMaxCells = 2
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = grid

for index, weapon in ipairs(weapons) do
	local button = Instance.new("TextButton")
	button.LayoutOrder = index
	button.BackgroundColor3 = Color3.fromRGB(91, 57, 137)
	button.Font = Enum.Font.GothamBold
	button.Text = weapon.label
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 15
	button.Parent = grid

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	track(button.Activated:Connect(function()
		createPreview(weapon)
	end))
end

local clearButton = Instance.new("TextButton")
clearButton.BackgroundColor3 = Color3.fromRGB(48, 40, 61)
clearButton.Position = UDim2.fromOffset(20, 226)
clearButton.Size = UDim2.new(1, -40, 0, 44)
clearButton.Font = Enum.Font.GothamBold
clearButton.Text = "ELIMINAR ARMAS DE PRUEBA"
clearButton.TextColor3 = Color3.fromRGB(222, 212, 236)
clearButton.TextSize = 14
clearButton.Parent = panel

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 10)
clearCorner.Parent = clearButton

track(clearButton.Activated:Connect(function()
	clearPreviews()
	notify("Arsenal privado", "Las armas de prueba se han eliminado.")
end))

track(closeButton.Activated:Connect(runtime.stop))
track(screenGui.AncestryChanged:Connect(function(_, parent)
	if not parent then runtime.stop() end
end))

notify("Arsenal privado", "Laboratorio local cargado.")
