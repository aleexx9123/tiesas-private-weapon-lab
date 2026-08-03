-- MMV Inventory.Equip security proof of concept.
-- Restricted to the authorized MMV universe/place.

local TARGET_GAME_ID = 10354852672
local TARGET_PLACE_ID = 116924926476457
local VERSION = "1.1.0"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
if not player then return end

local function notify(message)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "MMV Security Test v" .. VERSION,
			Text = message,
			Duration = 6,
		})
	end)
end

-- Both identifiers must match. Using `and` here would allow a different place
-- in the universe (or an unrelated universe reusing an expected place check).
if game.GameId ~= TARGET_GAME_ID or game.PlaceId ~= TARGET_PLACE_ID then
	notify("Este script solo funciona en la experiencia MMV autorizada.")
	return
end

local remotes = ReplicatedStorage:FindFirstChild("Remotes")
local inventory = remotes and remotes:FindFirstChild("Inventory")
local equipRemote = inventory and inventory:FindFirstChild("Equip")
local getProfileRemote = inventory and inventory:FindFirstChild("GetProfileData")
local database = ReplicatedStorage:FindFirstChild("Database")
local syncModule = database and database:FindFirstChild("Sync")
if not equipRemote or not equipRemote:IsA("RemoteEvent")
	or not getProfileRemote or not getProfileRemote:IsA("RemoteFunction")
	or not syncModule or not syncModule:IsA("ModuleScript") then
	notify("No se encontraron los remotos esperados de MMV.")
	return
end

local targets = {
	{label = "Corrupt azul", id = "Premium_K", itemType = "Knife"},
	{label = "Luger azul", id = "Premium_G", itemType = "Gun"},
	{label = "Voidscope", id = "Voidscope", itemType = "Gun"},
	{label = "Ban Hammer", id = "BanHammer", itemType = "Knife"},
}

-- Confirm the MMV catalogue schema as well as the IDs. This prevents the PoC
-- from running merely because another experience copied the remote names.
local syncOk, sync = pcall(require, syncModule)
if not syncOk or type(sync) ~= "table" or type(sync.Weapons) ~= "table" then
	notify("El catálogo de esta sesión no coincide con MMV.")
	return
end
for _, target in ipairs(targets) do
	if sync.Weapons[target.id] == nil then
		notify("Falta el ID MMV esperado: " .. target.id .. ".")
		return
	end
end

local environment = type(getgenv) == "function" and getgenv() or _G
local previous = environment.TIESAS_MMV_SECURITY_TEST
if type(previous) == "table" and type(previous.stop) == "function" then
	pcall(previous.stop)
end

local runtime = {alive = true, connections = {}}
environment.TIESAS_MMV_SECURITY_TEST = runtime
local function track(connection)
	table.insert(runtime.connections, connection)
	return connection
end

local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("TiesasMMVSecurityTest")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "TiesasMMVSecurityTest"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

function runtime.stop()
	if not runtime.alive then return end
	runtime.alive = false
	for _, connection in ipairs(runtime.connections) do
		pcall(function() connection:Disconnect() end)
	end
	table.clear(runtime.connections)
	if gui.Parent then gui:Destroy() end
	if environment.TIESAS_MMV_SECURITY_TEST == runtime then
		environment.TIESAS_MMV_SECURITY_TEST = nil
	end
end

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(440, 340)
panel.BackgroundColor3 = Color3.fromRGB(24, 20, 32)
panel.BorderSizePixel = 0
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 14)
title.Size = UDim2.new(1, -72, 0, 34)
title.Font = Enum.Font.GothamBold
title.Text = "MMV · PRUEBA DE REMOTO"
title.TextColor3 = Color3.fromRGB(245, 239, 255)
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local close = Instance.new("TextButton")
close.Position = UDim2.new(1, -50, 0, 14)
close.Size = UDim2.fromOffset(34, 34)
close.BackgroundColor3 = Color3.fromRGB(71, 48, 90)
close.Font = Enum.Font.GothamBold
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 22
close.Parent = panel
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

local explanation = Instance.new("TextLabel")
explanation.BackgroundTransparency = 1
explanation.Position = UDim2.fromOffset(20, 55)
explanation.Size = UDim2.new(1, -40, 0, 56)
explanation.Font = Enum.Font.Gotham
explanation.Text = "Envía un ID no poseído a Inventory.Equip y consulta de nuevo el perfil. No añade objetos a Owned ni guarda datos."
explanation.TextColor3 = Color3.fromRGB(188, 176, 207)
explanation.TextSize = 13
explanation.TextWrapped = true
explanation.TextXAlignment = Enum.TextXAlignment.Left
explanation.Parent = panel

local grid = Instance.new("Frame")
grid.BackgroundTransparency = 1
grid.Position = UDim2.fromOffset(20, 120)
grid.Size = UDim2.new(1, -40, 0, 126)
grid.Parent = panel
local layout = Instance.new("UIGridLayout")
layout.CellPadding = UDim2.fromOffset(10, 10)
layout.CellSize = UDim2.new(0.5, -5, 0, 58)
layout.FillDirectionMaxCells = 2
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

local status = Instance.new("TextLabel")
status.BackgroundColor3 = Color3.fromRGB(39, 32, 49)
status.Position = UDim2.fromOffset(20, 260)
status.Size = UDim2.new(1, -40, 0, 60)
status.Font = Enum.Font.Gotham
status.Text = "Selecciona un arma para iniciar la prueba."
status.TextColor3 = Color3.fromRGB(222, 214, 234)
status.TextSize = 13
status.TextWrapped = true
status.Parent = panel
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 9)
statusCorner.Parent = status

local function getProfile()
	local ok, profile = pcall(function()
		return getProfileRemote:InvokeServer()
	end)
	return ok and type(profile) == "table" and profile or nil
end

local requestInFlight = false
local function testRemote(target)
	if requestInFlight or not runtime.alive then return end
	requestInFlight = true
	status.TextColor3 = Color3.fromRGB(222, 214, 234)
	status.Text = "Enviando " .. target.id .. " a Inventory.Equip..."

	local before = getProfile()
	local beforeOwned = before and before.Weapons and before.Weapons.Owned
		and before.Weapons.Owned[target.id] ~= nil or false
	equipRemote:FireServer(target.id, "Weapons")
	task.wait(0.3)

	local after = getProfile()
	local equipped = after and after.Weapons and after.Weapons.Equipped
		and after.Weapons.Equipped[target.itemType] or nil
	local ownedAfter = after and after.Weapons and after.Weapons.Owned
		and after.Weapons.Owned[target.id] ~= nil or false

	if not beforeOwned and equipped == target.id then
		status.TextColor3 = Color3.fromRGB(255, 124, 124)
		status.Text = "VULNERABLE: " .. target.label
			.. " fue equipada sin poseerla. Owned después: "
			.. tostring(ownedAfter) .. "."
		notify("Equipación sin propiedad confirmada con " .. target.label .. ".")
	elseif beforeOwned then
		status.TextColor3 = Color3.fromRGB(255, 208, 112)
		status.Text = "Prueba no válida: " .. target.id .. " ya estaba poseída."
	else
		status.TextColor3 = Color3.fromRGB(128, 232, 160)
		status.Text = "RECHAZADO: el servidor no equipó " .. target.label .. "."
	end
	requestInFlight = false
end

for index, target in ipairs(targets) do
	local button = Instance.new("TextButton")
	button.LayoutOrder = index
	button.BackgroundColor3 = Color3.fromRGB(91, 58, 137)
	button.Font = Enum.Font.GothamBold
	button.Text = target.label
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 15
	button.Parent = grid
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button
	track(button.Activated:Connect(function() testRemote(target) end))
end

track(close.Activated:Connect(runtime.stop))
track(gui.AncestryChanged:Connect(function(_, parent)
	if not parent then runtime.stop() end
end))
notify("PoC cargada únicamente para MMV.")
