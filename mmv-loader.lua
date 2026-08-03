local sourceUrl = "https://raw.githubusercontent.com/aleexx9123/tiesas-private-weapon-lab/main/mmv-security-test.lua"
local source = game:HttpGet(sourceUrl .. "?cache=" .. tostring(os.time()), false)
loadstring(source)()
