-- DEBUG LOADER para tu script en GitHub
local url = "https://raw.githubusercontent.com/brailynestevez01-eng/aimbot/main/aimbot.lua"

-- helper de logs (usa rconsole si existe)
local function log(s)
    if rconsoleprint then rconsoleprint("[DEBUG] "..tostring(s).."\n") else print("[DEBUG] "..tostring(s)) end
end

log("Intentando HttpGet: "..url)
local ok, res = pcall(function() return game:HttpGet(url, true) end)
if not ok then
    log("HttpGet fallo: "..tostring(res))
    log("→ Revisa tu conexión, permiso HTTP del ejecutor, o que la URL sea accesible.")
    return
end
if not res or res == "" then
    log("HttpGet devolvió vacío. Verifica que la URL apunte al RAW correcto.")
    return
end

log("HttpGet OK, longitud recibido: "..tostring(#res).." bytes")

-- Intentar compilar
local fn, loadErr = loadstring(res)
if not fn then
    log("loadstring fallo: "..tostring(loadErr))
    log("→ Puede ser error de sintaxis u ofuscación incompatible. Intenta pegar el contenido manualmente.")
    return
end

log("loadstring OK, intentando ejecutar el script (pcall)...")
local ok2, runErr = pcall(fn)
if not ok2 then
    log("Ejecución fallo: "..tostring(runErr))
    log("→ Si es error runtime, pégame el mensaje exacto y lo revisamos.")
    return
end

log("Script ejecutado correctamente.")
