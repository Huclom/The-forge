local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 1. BUSCAR TU AUTO ACTUAL
-- (No podemos usar el ID del RemoteSpy porque cambia siempre, esto busca el tuyo actual)
local function findClosestCar()
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then return nil end

    local closestCar = nil
    local minDistance = 50 

    for _, carModel in ipairs(vehiclesFolder:GetChildren()) do
        -- Busca autos que sean tuyos por atributo Owner o nombre
        if carModel:IsA("Model") and (carModel:GetAttribute("Owner") == player.Name or carModel.Name == player.Name.."'s Car") then
            local referencePart = carModel:FindFirstChild("DriveSeat") or carModel:FindFirstChildOfClass("BasePart", true)
            if referencePart then
                local distance = (rootPart.Position - referencePart.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestCar = carModel
                end
            end
        end
    end
    return closestCar
end

-- 2. FUNCIÓN DE PINTURA CORREGIDA
local function paintCarCorrectly()
    local carModel = findClosestCar()
    if not carModel then 
        warn("❌ No se encontró tu auto cerca para pintar.") 
        return 
    end

    print("✅ Auto detectado: " .. carModel.Name)

    -- Referencia al evento exacto que mostraste
    local setPaintEvent = ReplicatedStorage.Events.Vehicles.SetPaint

    -- Accedemos al Prompt para 'activar' la máquina (por si acaso el servidor lo verifica)
    local paintPrompt = Workspace.Map.pintamento.CarPaint.Prompt.ProximityPrompt
    if paintPrompt then
        fireproximityprompt(paintPrompt)
        task.wait(0.5) -- Esperamos medio segundo a que 'abra' la GUI
    end

    -- Generar color aleatorio
    local randomColor = Color3.fromHSV(math.random(), 0.8, 1) -- Colores vivos

    print("🎨 Enviando señal de pintura basada en RemoteSpy...")

    -- --- AQUÍ ESTÁ LA CORRECCIÓN ---
    -- Argumento 1: "Car" (Texto)
    -- Argumento 2: El Modelo del auto (Objeto)
    -- Argumento 3: El Color (Color3)
    setPaintEvent:FireServer("Car", carModel, randomColor)
    
    print("✅ ¡Pintura enviada!")
end

-- Ejecutar
paintCarCorrectly()
