--[[
Ryzen Hub Interface
by Jotoro
]]
if debugX then
warn('Initialising Ryzen Hub')
end
local function getService(name)
local service = game:GetService(name)
return if cloneref then cloneref(service) else service
end
-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function loadWithTimeout(url: string, timeout: number?): ...any
assert(type(url) == "string", "Expected string, got " .. type(url))
timeout = timeout or 5
local requestCompleted = false
local success, result = false, nil
local requestThread = task.spawn(function()
local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url) -- game:HttpGet(url)
-- If the request fails the content can be empty, even if fetchSuccess is true
if not fetchSuccess or #fetchResult == 0 then
if #fetchResult == 0 then
fetchResult = "Empty response" -- Set the error message
end
success, result = false, fetchResult
requestCompleted = true
return
end
local content = fetchResult -- Fetched content
local execSuccess, execResult = pcall(function()
return loadstring(content)()
end)
success, result = execSuccess, execResult
requestCompleted = true
end)
local timeoutThread = task.delay(timeout, function()
if not requestCompleted then
warn(Request for {url} timed out after {timeout} seconds)
task.cancel(requestThread)
result = "Request timed out"
requestCompleted = true
end
end)
-- Wait for completion or timeout
while not requestCompleted do
task.wait()
end
-- Cancel timeout thread if still running when request completes
if coroutine.status(timeoutThread) ~= "dead" then
task.cancel(timeoutThread)
end
if not success then
warn(Failed to process {url}: {result})
end
return if success then result else nil
end
local requestsDisabled = true --getgenv and getgenv().DISABLE_RAYFIELD_REQUESTS
local InterfaceBuild = '3K3W'
local Release = "Build 1.68"
local RayfieldFolder = "RyzenHub"
local ConfigurationFolder = RayfieldFolder.."/Configurations"
local ConfigurationExtension = ".rfld"
local settingsTable = {
General = {
-- if needs be in order just make getSetting(name)
rayfieldOpen = {Type = 'bind', Value = 'K', Name = 'Ryzen Hub Keybind'},
-- buildwarnings
-- rayfieldprompts
},
System = {
usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
}
}
-- Settings that have been overridden by the developer. These will not be saved to the user's configuration file
-- Overridden settings always take precedence over settings in the configuration file, and are cleared if the user changes the setting in the UI
local overriddenSettings: { [string]: any } = {} -- For example, overriddenSettings["System.rayfieldOpen"] = "J"
local function overrideSetting(category: string, name: string, value: any)
overriddenSettings[{category}.{name}] = value
end
local function getSetting(category: string, name: string): any
if overriddenSettings[{category}.{name}] ~= nil then
return overriddenSettings[{category}.{name}]
elseif settingsTable[category][name] ~= nil then
return settingsTable[category][name].Value
end
end
-- If requests/analytics have been disabled by developer, set the user-facing setting to false as well
if requestsDisabled then
overrideSetting("System", "usageAnalytics", false)
end
local HttpService = getService('HttpService')
local RunService = getService('RunService')
-- Environment Check
local useStudio = RunService:IsStudio() or false
local settingsCreated = false
local settingsInitialized = false -- Whether the UI elements in the settings page have been set to the proper values
local cachedSettings
local prompt = useStudio and require(script.Parent.prompt) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua')
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
-- Validate prompt loaded correctly
if not prompt and not useStudio then
warn("Failed to load prompt library, using fallback")
prompt = {
create = function() end -- No-op fallback
}
end
local function loadSettings()
local file = nil
local success, result =	pcall(function()
task.spawn(function()
if isfolder and isfolder(RayfieldFolder) then
if isfile and isfile(RayfieldFolder..'/settings'..ConfigurationExtension) then
file = readfile(RayfieldFolder..'/settings'..ConfigurationExtension)
end
end
-- for debug in studio
if useStudio then
file = [[
{"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Ryzen Hub Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Ryzen Hub Keybind","Set":null,"CallOnChange":true,"Callback":null,"CurrentKeybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}
]]
end
if file then
local success, decodedFile = pcall(function() return HttpService:JSONDecode(file) end)
if success then
file = decodedFile
else
file = {}
end
else
file = {}
end
if not settingsCreated then
cachedSettings = file
return
end
if file ~= {} then
for categoryName, settingCategory in pairs(settingsTable) do
if file[categoryName] then
for settingName, setting in pairs(settingCategory) do
if file[categoryName][settingName] then
setting.Value = file[categoryName][settingName].Value
setting.Element:Set(getSetting(categoryName, settingName))
end
end
end
end
end
settingsInitialized = true
end)
end)
if not success then
if writefile then
warn('Ryzen Hub had an issue accessing configuration saving capability.')
end
end
end
if debugX then
warn('Now Loading Settings Configuration')
end
loadSettings()
if debugX then
warn('Settings Loaded')
end
local analyticsLib
local sendReport = function(ev_n, sc_n) warn("Failed to load report function") end
if not requestsDisabled then
if debugX then
warn('Querying Settings for Reporter Information')
end
analyticsLib = loadWithTimeout("https://analytics.sirius.menu/script")
if not analyticsLib then
warn("Failed to load analytics reporter")
analyticsLib = nil
elseif analyticsLib and type(analyticsLib.load) == "function" then
analyticsLib:load()
else
warn("Analytics library loaded but missing load function")
analyticsLib = nil
end
sendReport = function(ev_n, sc_n)
if not (type(analyticsLib) == "table" and type(analyticsLib.isLoaded) == "function" and analyticsLib:isLoaded()) then
warn("Analytics library not loaded")
return
end
if useStudio then
print('Sending Analytics')
else
if debugX then warn('Reporting Analytics') end
analyticsLib:report(
{
["name"] = ev_n,
["script"] = {["name"] = sc_n, ["version"] = Release}
},
{
["version"] = InterfaceBuild
}
)
if debugX then warn('Finished Report') end
end
end
if cachedSettings and (#cachedSettings == 0 or (cachedSettings.System and cachedSettings.System.usageAnalytics and cachedSettings.System.usageAnalytics.Value)) then
sendReport("execution", "Ryzen Hub")
elseif not cachedSettings then
sendReport("execution", "Ryzen Hub")
end
end
local promptUser = 2
if promptUser == 1 and prompt and type(prompt.create) == "function" then
prompt.create(
'Be cautious when running scripts',
[[Please be careful when running scripts from unknown developers. This script has already been ran.
<font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],
'Okay',
'',
function()
end
)
end
if debugX then
warn('Moving on to continue initialisation')
end
local RyzenHubLibrary = {
Flags = {},
Theme = {
Default = {
TextColor = Color3.fromRGB(240, 240, 240),
Background = Color3.fromRGB(25, 25, 25),
Topbar = Color3.fromRGB(34, 34, 34),
Shadow = Color3.fromRGB(20, 20, 20),
NotificationBackground = Color3.fromRGB(20, 20, 20),
NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
TabBackground = Color3.fromRGB(80, 80, 80),
TabStroke = Color3.fromRGB(85, 85, 85),
TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
TabTextColor = Color3.fromRGB(240, 240, 240),
SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
ElementBackground = Color3.fromRGB(35, 35, 35),
ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
ElementStroke = Color3.fromRGB(50, 50, 50),
SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
SliderBackground = Color3.fromRGB(50, 138, 220),
SliderProgress = Color3.fromRGB(50, 138, 220),
SliderStroke = Color3.fromRGB(58, 163, 255),
ToggleBackground = Color3.fromRGB(30, 30, 30),
ToggleEnabled = Color3.fromRGB(0, 146, 214),
ToggleDisabled = Color3.fromRGB(100, 100, 100),
ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),
DropdownSelected = Color3.fromRGB(40, 40, 40),
DropdownUnselected = Color3.fromRGB(30, 30, 30),
InputBackground = Color3.fromRGB(30, 30, 30),
InputStroke = Color3.fromRGB(65, 65, 65),
PlaceholderColor = Color3.fromRGB(178, 178, 178)
},
Ocean = {
TextColor = Color3.fromRGB(230, 240, 240),
Background = Color3.fromRGB(20, 30, 30),
Topbar = Color3.fromRGB(25, 40, 40),
Shadow = Color3.fromRGB(15, 20, 20),
NotificationBackground = Color3.fromRGB(25, 35, 35),
NotificationActionsBackground = Color3.fromRGB(230, 240, 240),
TabBackground = Color3.fromRGB(40, 60, 60),
TabStroke = Color3.fromRGB(50, 70, 70),
TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
TabTextColor = Color3.fromRGB(210, 230, 230),
SelectedTabTextColor = Color3.fromRGB(20, 50, 50),
ElementBackground = Color3.fromRGB(30, 50, 50),
ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
SecondaryElementBackground = Color3.fromRGB(30, 45, 45),
ElementStroke = Color3.fromRGB(45, 70, 70),
SecondaryElementStroke = Color3.fromRGB(40, 65, 65),
SliderBackground = Color3.fromRGB(0, 110, 110),
SliderProgress = Color3.fromRGB(0, 140, 140),
SliderStroke = Color3.fromRGB(0, 160, 160),
ToggleBackground = Color3.fromRGB(30, 50, 50),
ToggleEnabled = Color3.fromRGB(0, 130, 130),
ToggleDisabled = Color3.fromRGB(70, 90, 90),
ToggleEnabledStroke = Color3.fromRGB(0, 160, 160),
ToggleDisabledStroke = Color3.fromRGB(85, 105, 105),
ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100),
ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65),
DropdownSelected = Color3.fromRGB(30, 60, 60),
DropdownUnselected = Color3.fromRGB(25, 40, 40),
InputBackground = Color3.fromRGB(30, 50, 50),
InputStroke = Color3.fromRGB(50, 70, 70),
PlaceholderColor = Color3.fromRGB(140, 160, 160)
},
AmberGlow = {
TextColor = Color3.fromRGB(255, 245, 230),
Background = Color3.fromRGB(45, 30, 20),
Topbar = Color3.fromRGB(55, 40, 25),
Shadow = Color3.fromRGB(35, 25, 15),
NotificationBackground = Color3.fromRGB(50, 35, 25),
NotificationActionsBackground = Color3.fromRGB(245, 230, 215),
TabBackground = Color3.fromRGB(75, 50, 35),
TabStroke = Color3.fromRGB(90, 60, 45),
TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
TabTextColor = Color3.fromRGB(250, 220, 200),
SelectedTabTextColor = Color3.fromRGB(50, 30, 10),
ElementBackground = Color3.fromRGB(60, 45, 35),
ElementBackgroundHover = Color3.fromRGB(70, 50, 40),
SecondaryElementBackground = Color3.fromRGB(55, 40, 30),
ElementStroke = Color3.fromRGB(85, 60, 45),
SecondaryElementStroke = Color3.fromRGB(75, 50, 35),
SliderBackground = Color3.fromRGB(220, 130, 60),
SliderProgress = Color3.fromRGB(250, 150, 75),
SliderStroke = Color3.fromRGB(255, 170, 85),
ToggleBackground = Color3.fromRGB(55, 40, 30),
ToggleEnabled = Color3.fromRGB(240, 130, 30),
ToggleDisabled = Color3.fromRGB(90, 70, 60),
ToggleEnabledStroke = Color3.fromRGB(255, 160, 50),
ToggleDisabledStroke = Color3.fromRGB(110, 85, 75),
ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50),
ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55),
DropdownSelected = Color3.fromRGB(70, 50, 40),
DropdownUnselected = Color3.fromRGB(55, 40, 30),
InputBackground = Color3.fromRGB(60, 45, 35),
InputStroke = Color3.fromRGB(90, 65, 50),
PlaceholderColor = Color3.fromRGB(190, 150, 130)
},
Light = {
TextColor = Color3.fromRGB(40, 40, 40),
Background = Color3.fromRGB(245, 245, 245),
Topbar = Color3.fromRGB(230, 230, 230),
Shadow = Color3.fromRGB(200, 200, 200),
NotificationBackground = Color3.fromRGB(250, 250, 250),
NotificationActionsBackground = Color3.fromRGB(240, 240, 240),
TabBackground = Color3.fromRGB(235, 235, 235),
TabStroke = Color3.fromRGB(215, 215, 215),
TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
TabTextColor = Color3.fromRGB(80, 80, 80),
SelectedTabTextColor = Color3.fromRGB(0, 0, 0),
ElementBackground = Color3.fromRGB(240, 240, 240),
ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
SecondaryElementBackground = Color3.fromRGB(235, 235, 235),
ElementStroke = Color3.fromRGB(210, 210, 210),
SecondaryElementStroke = Color3.fromRGB(210, 210, 210),
SliderBackground = Color3.fromRGB(150, 180, 220),
SliderProgress = Color3.fromRGB(100, 150, 200),
SliderStroke = Color3.fromRGB(120, 170, 220),
ToggleBackground = Color3.fromRGB(220, 220, 220),
ToggleEnabled = Color3.fromRGB(0, 146, 214),
ToggleDisabled = Color3.fromRGB(150, 150, 150),
ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
ToggleDisabledStroke = Color3.fromRGB(170, 170, 170),
ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180),
DropdownSelected = Color3.fromRGB(230, 230, 230),
DropdownUnselected = Color3.fromRGB(220, 220, 220),
InputBackground = Color3.fromRGB(240, 240, 240),
InputStroke = Color3.fromRGB(180, 180, 180),
PlaceholderColor = Color3.fromRGB(140, 140, 140)
},
Amethyst = {
TextColor = Color3.fromRGB(240, 240, 240),
Background = Color3.fromRGB(30, 20, 40),
Topbar = Color3.fromRGB(40, 25, 50),
Shadow = Color3.fromRGB(20, 15, 30),
NotificationBackground = Color3.fromRGB(35, 20, 40),
NotificationActionsBackground = Color3.fromRGB(240, 240, 250),
TabBackground = Color3.fromRGB(60, 40, 80),
TabStroke = Color3.fromRGB(70, 45, 90),
TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
TabTextColor = Color3.fromRGB(230, 230, 240),
SelectedTabTextColor = Color3.fromRGB(50, 20, 50),
ElementBackground = Color3.fromRGB(45, 30, 60),
ElementBackgroundHover = Color3.fromRGB(50, 35, 70),
SecondaryElementBackground = Color3.fromRGB(40, 30, 55),
ElementStroke = Color3.fromRGB(70, 50, 85),
SecondaryElementStroke = Color3.fromRGB(65, 45, 80),
SliderBackground = Color3.fromRGB(100, 60, 150),
SliderProgress = Color3.fromRGB(130, 80, 180),
SliderStroke = Color3.fromRGB(150, 100, 200),
ToggleBackground = Color3.fromRGB(45, 30, 55),
ToggleEnabled = Color3.fromRGB(120, 60, 150),
ToggleDisabled = Color3.fromRGB(94, 47, 117),
ToggleEnabledStroke = Color3.fromRGB(140, 80, 170),
ToggleDisabledStroke = Color3.fromRGB(124, 71, 150),
ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120),
ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110),
DropdownSelected = Color3.fromRGB(50, 35, 70),
DropdownUnselected = Color3.fromRGB(35, 25, 50),
InputBackground = Color3.fromRGB(45, 30, 60),
InputStroke = Color3.fromRGB(80, 50, 110),
PlaceholderColor = Color3.fromRGB(178, 150, 200)
},
Green = {
TextColor = Color3.fromRGB(30, 60, 30),
Background = Color3.fromRGB(235, 245, 235),
Topbar = Color3.fromRGB(210, 230, 210),
Shadow = Color3.fromRGB(200, 220, 200),
NotificationBackground = Color3.fromRGB(240, 250, 240),
NotificationActionsBackground = Color3.fromRGB(220, 235, 220),
TabBackground = Color3.fromRGB(215, 235, 215),
TabStroke = Color3.fromRGB(190, 210, 190),
TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
TabTextColor = Color3.fromRGB(50, 80, 50),
SelectedTabTextColor = Color3.fromRGB(20, 60, 20),
ElementBackground = Color3.fromRGB(225, 240, 225),
ElementBackgroundHover = Color3.fromRGB(210, 225, 210),
SecondaryElementBackground = Color3.fromRGB(235, 245, 235),
ElementStroke = Color3.fromRGB(180, 200, 180),
SecondaryElementStroke = Color3.fromRGB(180, 200, 180),
SliderBackground = Color3.fromRGB(90, 160, 90),
SliderProgress = Color3.fromRGB(70, 130, 70),
SliderStroke = Color3.fromRGB(100, 180, 100),
ToggleBackground = Color3.fromRGB(215, 235, 215),
ToggleEnabled = Color3.fromRGB(60, 130, 60),
ToggleDisabled = Color3.fromRGB(150, 175, 150),
ToggleEnabledStroke = Color3.fromRGB(80, 150, 80),
ToggleDisabledStroke = Color3.fromRGB(130, 150, 130),
ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100),
ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160),
DropdownSelected = Color3.fromRGB(225, 240, 225),
DropdownUnselected = Color3.fromRGB(210, 225, 210),
InputBackground = Color3.fromRGB(235, 245, 235),
InputStroke = Color3.fromRGB(180, 200, 180),
PlaceholderColor = Color3.fromRGB(120, 140, 120)
},
Bloom = {
TextColor = Color3.fromRGB(60, 40, 50),
Background = Color3.fromRGB(255, 240, 245),
Topbar = Color3.fromRGB(250, 220, 225),
Shadow = Color3.fromRGB(230, 190, 195),
NotificationBackground = Color3.fromRGB(255, 235, 240),
NotificationActionsBackground = Color3.fromRGB(245, 215, 225),
TabBackground = Color3.fromRGB(240, 210, 220),
TabStroke = Color3.fromRGB(230, 200, 210),
TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
TabTextColor = Color3.fromRGB(80, 40, 60),
SelectedTabTextColor = Color3.fromRGB(50, 30, 50),
ElementBackground = Color3.fromRGB(255, 235, 240),
ElementBackgroundHover = Color3.fromRGB(245, 220, 230),
SecondaryElementBackground = Color3.fromRGB(255, 235, 240),
ElementStroke = Color3.fromRGB(230, 200, 210),
SecondaryElementStroke = Color3.fromRGB(230, 200, 210),
SliderBackground = Color3.fromRGB(240, 130, 160),
SliderProgress = Color3.fromRGB(250, 160, 180),
SliderStroke = Color3.fromRGB(255, 180, 200),
ToggleBackground = Color3.fromRGB(240, 210, 220),
ToggleEnabled = Color3.fromRGB(255, 140, 170),
ToggleDisabled = Color3.fromRGB(200, 180, 185),
ToggleEnabledStroke = Color3.fromRGB(250, 160, 190),
ToggleDisabledStroke = Color3.fromRGB(210, 180, 190),
ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180),
ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180),
DropdownSelected = Color3.fromRGB(250, 220, 225),
DropdownUnselected = Color3.fromRGB(240, 210, 220),
InputBackground = Color3.fromRGB(255, 235, 240),
InputStroke = Color3.fromRGB(220, 190, 200),
PlaceholderColor = Color3.fromRGB(170, 130, 140)
},
DarkBlue = {
TextColor = Color3.fromRGB(230, 230, 230),
Background = Color3.fromRGB(20, 25, 30),
Topbar = Color3.fromRGB(30, 35, 40),
Shadow = Color3.fromRGB(15, 20, 25),
NotificationBackground = Color3.fromRGB(25, 30, 35),
NotificationActionsBackground = Color3.fromRGB(45, 50, 55),
TabBackground = Color3.fromRGB(35, 40, 45),
TabStroke = Color3.fromRGB(45, 50, 60),
TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
TabTextColor = Color3.fromRGB(200, 200, 200),
SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
ElementBackground = Color3.fromRGB(30, 35, 40),
ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
SecondaryElementBackground = Color3.fromRGB(35, 40, 45),
ElementStroke = Color3.fromRGB(45, 50, 60),
SecondaryElementStroke = Color3.fromRGB(40, 45, 55),
SliderBackground = Color3.fromRGB(0, 90, 180),
SliderProgress = Color3.fromRGB(0, 120, 210),
SliderStroke = Color3.fromRGB(0, 150, 240),
ToggleBackground = Color3.fromRGB(35, 40, 45),
ToggleEnabled = Color3.fromRGB(0, 120, 210),
ToggleDisabled = Color3.fromRGB(70, 70, 80),
ToggleEnabledStroke = Color3.fromRGB(0, 150, 240),
ToggleDisabledStroke = Color3.fromRGB(75, 75, 85),
ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180),
ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65),
DropdownSelected = Color3.fromRGB(30, 70, 90),
DropdownUnselected = Color3.fromRGB(25, 30, 35),
InputBackground = Color3.fromRGB(25, 30, 35),
InputStroke = Color3.fromRGB(45, 50, 60),
PlaceholderColor = Color3.fromRGB(150, 150, 160)
},
Serenity = {
TextColor = Color3.fromRGB(50, 55, 60),
Background = Color3.fromRGB(240, 245, 250),
Topbar = Color3.fromRGB(215, 225, 235),
Shadow = Color3.fromRGB(200, 210, 220),
NotificationBackground = Color3.fromRGB(210, 220, 230),
NotificationActionsBackground = Color3.fromRGB(225, 230, 240),
TabBackground = Color3.fromRGB(200, 210, 220),
TabStroke = Color3.fromRGB(180, 190, 200),
TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
TabTextColor = Color3.fromRGB(50, 55, 60),
SelectedTabTextColor = Color3.fromRGB(30, 35, 40),
ElementBackground = Color3.fromRGB(210, 220, 230),
ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
ElementStroke = Color3.fromRGB(190, 200, 210),
SecondaryElementStroke = Color3.fromRGB(180, 190, 200),
SliderBackground = Color3.fromRGB(200, 220, 235),
SliderProgress = Color3.fromRGB(70, 130, 180),
SliderStroke = Color3.fromRGB(150, 180, 220),
ToggleBackground = Color3.fromRGB(210, 220, 230),
ToggleEnabled = Color3.fromRGB(70, 160, 210),
ToggleDisabled = Color3.fromRGB(180, 180, 180),
ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),
DropdownSelected = Color3.fromRGB(220, 230, 240),
DropdownUnselected = Color3.fromRGB(200, 210, 220),
InputBackground = Color3.fromRGB(220, 230, 240),
InputStroke = Color3.fromRGB(180, 190, 200),
PlaceholderColor = Color3.fromRGB(150, 150, 150)
}
},
ThemeManager = {
BuiltThemes = {},
CurrentTheme = nil,
Save = function(self, themeName, themeTable)
self.BuiltThemes[themeName] = themeTable
end,
Apply = function(self, themeName)
local theme = self.BuiltThemes[themeName] or self.CurrentTheme or RyzenHubLibrary.Theme.Default
RyzenHubLibrary.ThemeManager.CurrentTheme = theme

end,
},
}
local function ChangeTheme(theme)
SelectedTheme = RyzenHubLibrary.Theme[theme] or theme 
end
local function setVisibility(visibility: boolean, notify: boolean?)
if Debounce then return end
if visibility then
Hidden = false
Unhide()
else
Hidden = true
Hide(notify)
end
end
function RyzenHubLibrary:SetVisibility(visibility: boolean)
setVisibility(visibility, false)
end
function RyzenHubLibrary:IsVisible(): boolean
return not Hidden
end
local hideHotkeyConnection -- Has to be initialized here since the connection is made later in the script
function RyzenHubLibrary:Destroy()
rayfieldDestroyed = true
hideHotkeyConnection:Disconnect()
RyzenHub:Destroy()
end
function RyzenHubLibrary:CreateWindow(Settings)
local WindowName = Settings.Name or "Ryzen Hub"
local LoadingTitle = Settings.LoadingTitle or "Ryzen Hub Interface"
local LoadingSubtitle = Settings.LoadingSubtitle or "by Ryzen"
local ConfigurationSaving = if type(Settings.ConfigurationSaving) == "table" then Settings.ConfigurationSaving else {Enabled = false, FolderName = nil, FileName = nil}
local Discord = if type(Settings.Discord) == "table" then Settings.Discord else {Enabled = false, Invite = nil, RememberJoins = true}
local KeySystem = Settings.KeySystem or false
local KeySettings = Settings.KeySettings or {Title = "Ryzen Hub", Subtitle = "Key System", Note = "No method of obtaining the key is provided", FileName = "Key", SaveKey = true, GrabKeyFromSite = false, Key = {"Hello"}}
local CEnabled = ConfigurationSaving.Enabled or false
local CFileName = ConfigurationSaving.FileName or "Config"
local CFolderName = ConfigurationSaving.FolderName or RayfieldFolder
local useMobileSizing = game:GetService("UserInputService").TouchEnabled
-- ... (其余代码保持不变，直到创建Main)
local RyzenHub = game:GetService("CoreGui"):FindFirstChild("RyzenHub") or Instance.new("ScreenGui")
RyzenHub.Name = "RyzenHub"
RyzenHub.IgnoreGuiInset = true
RyzenHub.Parent = game:GetService("CoreGui")
RyzenHub.ZIndexBehavior = Enum.ZIndexBehavior.Global
local MainShadow = RyzenHub:FindFirstChild("MainShadow") or Instance.new("ImageLabel")
MainShadow.Name = "MainShadow"
MainShadow.Parent = RyzenHub
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.BackgroundTransparency = 1.000
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainShadow.Size = UDim2.new(0, 550, 0, 525)
MainShadow.Image = "rbxassetid://4996891970"
MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.ImageTransparency = 1.000
MainShadow.ScaleType = Enum.ScaleType.Slice
MainShadow.SliceCenter = Rect.new(20, 20, 480, 480)
local MPrompt = RyzenHub:FindFirstChild("MPrompt") or Instance.new("Frame")
MPrompt.Name = "MPrompt"
MPrompt.Parent = RyzenHub
MPrompt.AnchorPoint = Vector2.new(0.5, 0)
MPrompt.BackgroundColor3 = SelectedTheme.ElementBackground
MPrompt.BackgroundTransparency = 1
MPrompt.Position = UDim2.new(0.5, 0, 0, 0)
MPrompt.Size = UDim2.new(0, 0, 0, 0)
MPrompt.Visible = false
local MPromptCorner = MPrompt:FindFirstChild("Corner") or Instance.new("UICorner")
MPromptCorner.Name = "Corner"
MPromptCorner.Parent = MPrompt
local MPromptTitle = MPrompt:FindFirstChild("Title") or Instance.new("TextLabel")
MPromptTitle.Name = "Title"
MPromptTitle.Parent = MPrompt
MPromptTitle.BackgroundTransparency = 1.000
MPromptTitle.Position = UDim2.new(0, 10, 0, 5)
MPromptTitle.Size = UDim2.new(1, -20, 0, 20)
MPromptTitle.Font = Enum.Font.Gotham
MPromptTitle.Text = "Ryzen Hub"
MPromptTitle.TextColor3 = SelectedTheme.TextColor
MPromptTitle.TextSize = 14.000
MPromptTitle.TextTransparency = 1
MPromptTitle.TextXAlignment = Enum.TextXAlignment.Left
local MPromptInteract = MPrompt:FindFirstChild("Interact") or Instance.new("TextButton")
MPromptInteract.Name = "Interact"
MPromptInteract.Parent = MPrompt
MPromptInteract.BackgroundTransparency = 1.000
MPromptInteract.Position = UDim2.new(0, 0, 0, 0)
MPromptInteract.Size = UDim2.new(1, 0, 1, 0)
MPromptInteract.Font = Enum.Font.SourceSans
MPromptInteract.Text = ""
MPromptInteract.TextColor3 = Color3.fromRGB(0, 0, 0)
MPromptInteract.TextSize = 14.000
local MPromptStroke = MPrompt:FindFirstChild("Stroke") or Instance.new("UIStroke")
MPromptStroke.Name = "Stroke"
MPromptStroke.Parent = MPrompt
MPromptStroke.Color = SelectedTheme.ElementStroke
MPromptStroke.Transparency = 1

for _, child in ipairs(Main:GetDescendants()) do
if child:IsA("Frame") and child ~= Main then
child.BackgroundTransparency = 0
end
if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ImageLabel") then
child.Transparency = 0 -- 或ImageTransparency
end
end

Topbar.Title.Text = "Ryzen Hub"
Topbar.Title.MouseButton1Click:Connect(function()
RyzenHubLibrary:SetVisibility(not RyzenHubLibrary:IsVisible())
end)

if Topbar:FindFirstChild("Hide") then
Topbar.Hide:Destroy()
end

local Tab = Window:CreateTab("Info", nil)
local Tab = Window:CreateTab("Main", nil)
local Tab = Window:CreateTab("Meis", nil)
local Tab = Window:CreateTab("Cues", nil)
local Tab = Window:CreateTab("Tier", nil)
local Tab = Window:CreateTab("'Poloyerl.", nil)
local Tab = Window:CreateTab("Miao", nil)
local Tab = Window:CreateTab("OnlyYou", nil)
-- 对于Auto Farm Tab，假设Main Tab
local MainTab = Window.Tabs["Main"]
local Section = MainTab:CreateSection("Auto Farm")
MainTab:CreateToggle({
Name = "Aure Cheap Smart Tree",
CurrentValue = false,
Callback = function(Value)
end,
})
MainTab:CreateToggle({
Name = "Eoula Weapon to hestle",
CurrentValue = false,
Callback = function(Value)
end,
})
MainTab:CreateSlider({
Name = "Kill Aura Radius",
Range = {100, 5000},
Increment = 100,
CurrentValue = 1900,
Callback = function(Value)
end,
})
MainTab:CreateToggle({
Name = "Kill Aura",
CurrentValue = false,
Callback = function(Value)
end,
})
MainTab:CreateToggle({
Name = "Fario Weapon to Rinoble",
CurrentValue = false,
Callback = function(Value)
end,
})
MainTab:CreateToggle({
Name = "Auto Carm Puol",
CurrentValue = false,
Callback = function(Value)
end,
})
MainTab:CreateToggle({
Name = "Auto Recycling",
CurrentValue = false,
Callback = function(Value)
end,
})
