premake.modules.android = {}

local m = premake.modules.android

m._ANDROID = "android"

--
-- Include components
--

include "_preload.lua"
include "vcxproj_customizations.lua"

return m
