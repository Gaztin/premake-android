local android = premake.extensions.android
android.properties = {}

local properties = android.properties

--
-- Generate project.properties
--

function properties.generate(prj)
	premake.w(0, 'target=$(androidapilevel)')
end