-- =================================================================
-- --- MÓDULO DE PRUEBAS V2: DETECCIÓN AGRESIVA ---
-- --- Solución al error "No hay carro cerca" ---
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Paint Lab | V2 (Blind Mode)",
   LoadingTitle = "Modo Escaneo",
   LoadingSubtitle = "Buscando cualquier pieza...",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local TabDebug = Window:CreateTab("Scanner", 4483362458)

-- SERVICIOS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

-- REFERENCIA AL REMOTE (Ya confirmamos que este existe)
local setPaintRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Vehicles"):WaitForChild("SetPaint")
local VEHICLES_FOLDER = Workspace:WaitForChild("Vehicles")

-- >>> FUNCIÓN DE BÚSQUEDA MEJORADA (EL FIX) <<<
local function getRealCarPosition(model)
    -- 1. Intenta la forma oficial
    if model.PrimaryPart then
        return model.PrimaryPart.Position
    end
    
    -- 2. Si falla, busca el asiento del conductor
    local seat = model:FindFirstChild("DriveSeat") or model:FindFirstChild("VehicleSeat")
    if seat then return seat.Position end

    -- 3. Si falla, busca cualquier pieza física (Body, Engine, etc)
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            return part.Position -- Retorna la posición de la primera pieza que encuentre
        end
    end
    
    return nil -- Es un modelo fantasma sin piezas físicas
end

local function getClosestCar_V2()
    local minDst = 25 -- Aumentamos rango a 25 studs
    local target = nil
    
    print("--- INICIANDO ESCANEO DE PROXIMIDAD ---")
    
    -- Revisamos la carpeta Vehicles
    for _, car in pairs(VEHICLES_FOLDER:GetChildren()) do
        if car:IsA("Model") then
            local pos = getRealCarPosition(car)
            
            if pos then
                local dist = (root.Position - pos).Magnitude
                print("🔍 Revisando: " .. car.Name .. " | Distancia: " .. math.floor(dist))
                
                if dist < minDst then
                    minDst = dist
                    target = car
                end
            else
                print("⚠️ Auto ignorado (Sin partes físicas): " .. car.Name)
            end
        end
    end
    
    print("---------------------------------------")
    return target
end

-- =================================================================
-- BOTONES
-- =================================================================

TabDebug:CreateSection("Pruebas de Detección")

TabDebug:CreateButton({
   Name = "1. ESCANEAR ENTORNO (Mira F9)",
   Callback = function()
       local car = getClosestCar_V2()
       if car then
           Rayfield:Notify({Title = "ENCONTRADO", Content = car.Name, Duration = 4})
           print("✅ AUTO SELECCIONADO: ", car.Name)
       else
           Rayfield:Notify({Title = "FALLO", Content = "Mira la consola F9 para ver por qué", Duration = 4})
           warn("❌ No se encontró nada cerca.")
       end
   end,
})

TabDebug:CreateSection("Pruebas de Pintura")

TabDebug:CreateButton({
   Name = "2. INTENTAR PINTAR (Detectado)",
   Callback = function()
       local car = getClosestCar_V2()
       if not car then 
           Rayfield:Notify({Title = "Error", Content = "Acércate más al auto", Duration = 2})
           return 
       end
       
       print("🧪 Enviando señal de pintura a: " .. car.Name)
       setPaintRemote:FireServer(car, Color3.new(0, 1, 0)) -- Verde Hacker
       Rayfield:Notify({Title = "Enviado", Content = "Checkea si se pintó verde", Duration = 3})
   end,
})

Rayfield:Notify({Title = "Debug V2", Content = "Abre F9 y presiona Escanear", Duration = 5})
