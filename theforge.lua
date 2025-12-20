-- =================================================================
-- --- MÓDULO DE PRUEBAS V3: INTERACCIÓN TOTAL ---
-- --- Estrategia: Prompt + UI Click + Variación de Argumentos ---
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Window = Rayfield:CreateWindow({
   Name = "Paint Lab | V3 (Interaction)",
   LoadingTitle = "Modo Fuerza Bruta",
   LoadingSubtitle = "Prompt + UI + Remotes",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local TabDebug = Window:CreateTab("Control", 4483362458)

-- VARIABLES
local player = Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")
local setPaintRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Vehicles"):WaitForChild("SetPaint")
local VEHICLES_FOLDER = Workspace:WaitForChild("Vehicles")

-- >>> FUNCIÓN DE DETECCIÓN (LA QUE SÍ FUNCIONA) <<<
local function getClosestCar_V2()
    local minDst = 20
    local target = nil
    for _, car in pairs(VEHICLES_FOLDER:GetChildren()) do
        if car:IsA("Model") then
            -- Buscamos cualquier parte física para medir distancia
            local refPart = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true)
            if refPart then
                local dist = (root.Position - refPart.Position).Magnitude
                if dist < minDst then
                    minDst = dist
                    target = car
                end
            end
        end
    end
    return target
end

-- >>> FUNCIÓN CLICKER DE UI <<<
local function clickFirstColorButton()
    print("🖥️ Buscando ventanas de pintura en pantalla...")
    local guiFound = false
    
    -- Escanea todo el PlayerGui buscando botones con nombres de colores o 'Paint'
    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("GuiButton") and gui.Visible then
            local name = gui.Name:lower()
            -- Palabras clave comunes en botones de pintura
            if name:find("color") or name:find("paint") or name:find("confirm") or name:find("yes") or gui:FindFirstChildWhichIsA("UIGradient") then
                
                print("🖱️ Click UI forzado en: " .. gui:GetFullName())
                local pos = gui.AbsolutePosition
                local size = gui.AbsoluteSize
                local center = Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2)
                
                VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
                guiFound = true
                -- No hacemos break para clickear todo lo posible
            end
        end
    end
    if not guiFound then print("⚠️ No se encontraron botones de UI.") end
end

-- =================================================================
-- BOTONES DE ATAQUE
-- =================================================================

TabDebug:CreateSection("1. Preparación")

TabDebug:CreateButton({
   Name = "Ir al Puesto de Pintura",
   Callback = function()
       local prompt = Workspace:WaitForChild("Map"):WaitForChild("pintamento"):WaitForChild("CarPaint"):FindFirstChild("Prompt", true):FindFirstChild("ProximityPrompt")
       if prompt then
           root.CFrame = prompt.Parent.CFrame * CFrame.new(0, 0, 3)
           Rayfield:Notify({Title = "Teleport", Content = "Llegaste.", Duration = 2})
       else
           warn("No se encontró el prompt de pintura en el mapa")
       end
   end,
})

TabDebug:CreateSection("2. Intentos de Pintura")

TabDebug:CreateButton({
   Name = "INTENTO A: Interacción Prompt + UI",
   Callback = function()
       local car = getClosestCar_V2()
       if not car then Rayfield:Notify({Title = "Error", Content = "Acerca el auto primero", Duration = 2}) return end

       print("--- INICIANDO INTENTO A ---")
       
       -- 1. Disparar Prompt
       local prompt = Workspace:WaitForChild("Map"):WaitForChild("pintamento"):WaitForChild("CarPaint"):FindFirstChild("Prompt", true):FindFirstChild("ProximityPrompt")
       if prompt then
           print("👉 Disparando Prompt...")
           fireproximityprompt(prompt, 0)
       end
       
       task.wait(1) -- Esperar a que salga la UI
       
       -- 2. Buscar y Clickear UI
       clickFirstColorButton()
       
       Rayfield:Notify({Title = "Intento A", Content = "Revisa si se pintó (Prompt+UI)", Duration = 3})
   end,
})

TabDebug:CreateButton({
   Name = "INTENTO B: Remote con 'Body'",
   Callback = function()
       local car = getClosestCar_V2()
       if not car then return end
       
       print("--- INICIANDO INTENTO B ---")
       
       -- A veces el remote no quiere el MODELO, quiere la CARROCERÍA (Body)
       local bodyPart = car:FindFirstChild("Body") or car:FindFirstChild("Chassis") or car:FindFirstChild("Main")
       
       if bodyPart then
           print("🧪 Enviando PARTE ESPECÍFICA: " .. bodyPart.Name)
           setPaintRemote:FireServer(bodyPart, Color3.new(0, 0, 1)) -- Azul
           Rayfield:Notify({Title = "Enviado", Content = "Probando con Part en vez de Model", Duration = 3})
       else
           warn("No se encontró parte 'Body' en el auto.")
       end
   end,
})

TabDebug:CreateButton({
   Name = "INTENTO C: Remote con String",
   Callback = function()
       local car = getClosestCar_V2()
       if not car then return end
       print("--- INICIANDO INTENTO C ---")
       -- A veces piden el NOMBRE del auto, no el objeto
       print("🧪 Enviando NOMBRE: " .. car.Name)
       setPaintRemote:FireServer(car.Name, Color3.new(1, 0, 1)) -- Magenta
   end,
})

Rayfield:Notify({Title = "V3 Cargado", Content = "Prueba el Intento A y B", Duration = 5})
