---@type NilName
local nn = ...

---@type br
local br = nn:Require("/scripts/BRLite/br.lua",nn)

br.unlocker="NN"
nn:Require("/scripts/BRLite/Bootstrap_NN.lua",br,nn)
nn:Require("/scripts/BRLite/brLogging.lua",br,nn)
br.Intialization:Startup() --Unlocker and core functionality loaded here.  This is specific to unlocker.
br.Framework:Startup()     --The BR Framework.  This will scaffold up the main BR Class with all of the members






