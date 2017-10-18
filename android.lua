premake.modules.android = {}

local m = premake.modules.android

m._ANDROID = "android"
m._PACKAGING = ".Packaging"

--
-- Include components
--

include "_preload.lua"

-- Packaging
include "androidproj.lua"

-- Customizations
include "vstudio_customizations.lua"
include "sln_customizations.lua"
include "vcxproj_customizations.lua"

return m
