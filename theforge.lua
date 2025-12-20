-- --- SERVICIOS ---
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- --- FUNCIÓN PARA ENCONTRAR TU AUTO (Necesaria para que funcione el pintado) ---
local function findClosestCar()
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local vehiclesFolder = Workspace:FindFirstChild("Vehicles")
    if not vehiclesFolder then return nil end

    local closestCar = nil
    local minDistance = 50 -- Rango máximo de búsqueda (studs)

    for _, carModel in ipairs(vehiclesFolder:GetChildren()) do
        if carModel:IsA("Model") and carModel:GetAttribute("Owner") == player.Name then
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

-- --- MÓDULO DE PINTURA (EXTRAÍDO) ---
local function autoPaint()
    local carModel = findClosestCar()
    if not carModel then 
        warn("No se encontró tu auto cerca para pintar.") 
        return 
    end

    print("Iniciando AUTO-PAINT en: " .. carModel.Name)

    -- 1. Buscar referencias (Prompt y Evento Remoto)
    local map = Workspace:WaitForChild("Map")
    local paintPath = map:FindFirstChild("pintamento") and map.pintamento:FindFirstChild("CarPaint")
    
    local paintPrompt = nil
    if paintPath then
        local promptPart = paintPath:FindFirstChild("Prompt", true)
        if promptPart then
            paintPrompt = promptPart:FindFirstChild("ProximityPrompt")
        end
    end

    local setPaintEvent = ReplicatedStorage:FindFirstChild("Events", true):FindFirstChild("Vehicles", true):FindFirstChild("SetPaint")

    -- 2. Ejecutar Lógica
    if paintPrompt and setPaintEvent then
        -- Generar color aleatorio (Hue, Saturation, Value)
        local newColor = Color3.fromHSV(math.random(), 1, 1)
        print("   Color aleatorio seleccionado: "..tostring(newColor))
        
        -- Paso A: Disparar el prompt físico (interacción simulada)
        print("   Interactuando con el puesto de pintura...")
        pcall(fireproximityprompt, paintPrompt, 0)
        task.wait(0.5)
        
        -- Paso B: Forzar el cambio de color vía servidor
        print("   Aplicando pintura...")
        pcall(function() 
            setPaintEvent:FireServer(carModel, newColor)
        end)
        
        print("¡Pintura completada!")
    else 
        warn("ERROR: No se encontró el 'ProximityPrompt' de pintura o el evento 'SetPaint'.") 
    end
end

-- Ejecutar
autoPaint()
