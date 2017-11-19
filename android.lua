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
include "androidproj_build_xml.lua"
include "androidproj_manifest_xml.lua"
include "androidproj_project_properties.lua"

-- Customizations
include "vstudio_customizations.lua"
include "sln_customizations.lua"
include "vcxproj_customizations.lua"

return android