local function UniversalRun(url, force)
    local code = game:HttpGet(url)
    code = code:gsub("\u{feff}", ""):gsub("\u{200b}", ""):gsub("\r\n", "\n")
    code = code:gsub("ä", "ae"):gsub("ö", "oe"):gsub("ü", "ue"):gsub("Ä", "Ae"):gsub("Ö", "Oe"):gsub("Ü", "Ue"):gsub("ß", "ss")
    code = code:gsub("Ordner", "Folder"):gsub("nicht gefunden", "not found")
    code = code:gsub("task%.delay", "delay"):gsub("task%.wait", "wait"):gsub("task%.spawn", "spawn")
    
    local func, err = loadstring(code)
    if not func then
        warn("Load failed: " .. (err or "Syntax?"))
        return
    end
    
    if force or not getgenv().__MATERIALS_LOADED then
        getgenv().__MATERIALS_LOADED = true
        local ok, runErr = pcall(func)
        if ok then
            print("Script started!")
        else
            warn("Run error: " .. tostring(runErr))
        end
    else
        print("Already loaded - skipping (use force=true to rerun)")
    end
end

UniversalRun("https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Dbug/nnf/materials.lua", true)