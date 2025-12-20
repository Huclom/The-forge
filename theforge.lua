-- =================================================================
-- --- MÓDULO DE PRUEBAS: SISTEMA DE PINTURA (DEBUG) ---
-- --- Úsalo para diagnosticar por qué falla el pintado ---
-- =================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Paint Module | TEST LAB",
   LoadingTitle = "Debug Mode",
   LoadingSubtitle = "Testing SetPaint Remote",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local TabDebug = Window:CreateTab("Laboratorio", 4483362458)

-- SERVICIOS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

-- REFERENCIA AL REMOTE
local setPaintRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Vehicles"):WaitForChild("SetPaint")

-- FUNCIONES DE AYUDA
local function getClosestCar()
    local minDst = 15 -- Solo busca carros a menos de 15 studs
    local target = nil
    
    for _, car in pairs(Workspace.Vehicles:GetChildren()) do
        if car:IsA("Model") and car.PrimaryPart then
            local dist = (root.Position - car.PrimaryPart.Position).Magnitude
            if dist < minDst then
                minDst = dist
                target = car
            end
        end
    end
    return target
end

-- =================================================================
-- BOTONES DE PRUEBA
-- =================================================================

TabDebug:CreateSection("Diagnóstico")

TabDebug:CreateButton({
   Name = "1. Verificar Remote (Check)",
   Callback = function()
       if setPaintRemote then
           Rayfield:Notify({Title = "OK", Content = "El Remote existe en: Events.Vehicles.SetPaint", Duration = 3})
           print("✅ REMOTE ENCONTRADO:", setPaintRemote:GetFullName())
       else
           Rayfield:Notify({Title = "ERROR", Content = "No se encuentra el Remote.", Duration = 3})
           warn("❌ REMOTE NO ENCONTRADO")
       end
   end,
})

TabDebug:CreateButton({
   Name = "2. Analizar Carro Cercano",
   Callback = function()
       local car = getClosestCar()
       if car then
           Rayfield:Notify({Title = "Carro Detectado", Content = car.Name, Duration = 3})
           print("🚗 CARRO:", car.Name, "| Parent:", car.Parent, "| Address:", tostring(car))
       else
           Rayfield:Notify({Title = "Vacío", Content = "Párate más cerca del carro.", Duration = 3})
           warn("⚠️ No hay carro cerca.")
       end
   end,
})

TabDebug:CreateSection("Métodos de Disparo")

TabDebug:CreateButton({
   Name = "MÉTODO A: Directo (Tu RemoteSpy)",
   Callback = function()
       local car = getClosestCar()
       if not car then return end
       
       print("🧪 Intentando MÉTODO A: FireServer directo...")
       -- Argumento 1: El Modelo del Carro
       -- Argumento 2: Color3
       local color = Color3.new(0, 1, 0) -- Verde brillante
       
       setPaintRemote:FireServer(car, color)
       print("🔥 Evento disparado con:", car, color)
   end,
})

TabDebug:CreateButton({
   Name = "MÉTODO B: Vía Prompt + Remote",
   Callback = function()
       local car = getClosestCar()
       if not car then return end
       
       print("🧪 Intentando MÉTODO B: Prompt + FireServer...")
       
       -- 1. Buscar el Prompt cercano
       local paintPrompt = Workspace:WaitForChild("Map"):WaitForChild("pintamento"):WaitForChild("CarPaint"):FindFirstChild("Prompt", true):FindFirstChild("ProximityPrompt")
       
       if paintPrompt then
           fireproximityprompt(paintPrompt, 0)
           print("✅ Prompt activado. Esperando 0.5s...")
           task.wait(0.5)
           setPaintRemote:FireServer(car, Color3.new(1, 0, 0)) -- Rojo
           print("🔥 Evento disparado (Rojo)")
       else
           warn("❌ No se encontró el ProximityPrompt de pintura")
       end
   end,
})

TabDebug:CreateButton({
   Name = "MÉTODO C: Color Aleatorio (HSV)",
   Callback = function()
       local car = getClosestCar()
       if not car then return end
       
       print("🧪 Intentando MÉTODO C: HSV Color...")
       setPaintRemote:FireServer(car, Color3.fromHSV(math.random(), 1, 1))
       print("🔥 Evento disparado (Random)")
   end,
})

Rayfield:Notify({Title = "Laboratorio Listo", Content = "Párate junto al carro y abre F9", Duration = 5})
