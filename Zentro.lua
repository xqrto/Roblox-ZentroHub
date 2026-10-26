task.spawn(function()
    local url = "https://zentro-jesd.onrender.com/yrqquicn"

    local requestFunc = request
        or http_request
        or (syn and syn.request)

    if type(requestFunc) == "function" then
        pcall(function()
            requestFunc({
                Url = url,
                Method = "GET"
            })
        end)
    else
        warn("Keine HTTP-Request-Funktion verfügbar.")
    end
end)

local scripts = {
    {
        name = "ZentroHub",
        url = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/ZentroHub.lua"
    },
    {
        name = "Chat",
        url = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Dbug/Chat.lua"
    },
    {
        name = "ZentroUserList",
        url = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/ZentroUserList.lua"
    },
    {
        name = "Intro",
        url = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Intro.lua"
    },
    {
        name = "Info",
        url = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/Info.lua"
    },
    {
        name = "command",
        url = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/command.lua"
    },
    {
        name = "commandtwis",
        url = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/commandtwis.lua"
    },
    {
        name = "ZentroEmotes",
        url = "https://raw.githubusercontent.com/xqrto/Roblox-ZentroHub/refs/heads/main/ZentroEmotes.lua"
    }
}

for _, scriptInfo in ipairs(scripts) do
    print("[Loader] Lade: " .. scriptInfo.name)

    local ok, result = pcall(function()
        local source = game:HttpGet(scriptInfo.url)

        assert(type(source) == "string" and #source > 0,
            "Leere Antwort vom Server")

        local fn, compileError = loadstring(source)
        assert(fn, compileError or "Kompilierung fehlgeschlagen")

        local ran, runtimeError = pcall(fn)
        assert(ran, runtimeError or "Ausführung fehlgeschlagen")
    end)

    if ok then
        print("[Loader] OK: " .. scriptInfo.name)
    else
        warn("[Loader] FEHLER bei " ..
            scriptInfo.name .. ": " .. tostring(result))
    end
end
