premake.extensions.android = {}
local android = premake.extensions.android

android._ANDROID = "android"
android._PACKAGING = ".Packaging"

--
-- Utility functions
--

function android.isApp(kind)
	return kind == "ConsoleApp" or kind == "WindowedApp"
end

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

return android