local url = "https://raw.githubusercontent.com/aleexx9123/tiesas-private-weapon-lab/main/main.lua"
local source = game:HttpGet(url .. "?cache=" .. tostring(os.time()), false)
loadstring(source)()
