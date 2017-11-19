require "vstudio"

local android = premake.extensions.android
local sln2005 = premake.vstudio.sln2005

--
-- Projects
--

premake.override(sln2005, "projects", function(base, wks)
	base(wks)

	for prj in premake.workspace.eachproject(wks) do
		if prj.system == m._ANDROID and android.isApp(prj.kind) then
			local prjname = prj.name .. android._PACKAGING
			local prjpath = prj.location .. "/" .. prjname .. ".androidproj"
			local prjuuid = os.uuid(prjname)
			prjpath = premake.vstudio.path(wks, prjpath)

			premake.push("Project(\"{39E2626F-3545-4960-A6E8-258AD8476CE5}\") = \"%s\", \"%s\", \"{%s}\"", prjname, prjpath, prjuuid)
			premake.pop("EndProject")
		end
	end
end)

--
-- Project configuration platforms
--

premake.override(sln2005.elements, "projectConfigurationPlatforms", function(base, cfg, context)
	if context.prj.system == android._ANDROID and android.isApp(context.prj.kind) then
		return {
			android.activeCfg,
			android.build0,
			android.deploy0,
		}
	else
		return base(cfg, context)
	end
end)

function android.activeCfg(cfg, context)
	local androidprojuuid = os.uuid(context.prj.name .. android._PACKAGING)
	premake.w("{%s}.%s.ActiveCfg = %s|%s", context.prj.uuid, context.descriptor, context.platform, context.architecture)
	premake.w("{%s}.%s.ActiveCfg = %s|%s", androidprojuuid, context.descriptor, context.platform, context.architecture)
end

function android.build0(cfg, context)
	local androidprojuuid = os.uuid(context.prj.name .. android._PACKAGING)
	premake.w("{%s}.%s.Build.0 = %s|%s", context.prj.uuid, context.descriptor, context.platform, context.architecture)
	premake.w("{%s}.%s.Build.0 = %s|%s", androidprojuuid, context.descriptor, context.platform, context.architecture)
end

function android.deploy0(cfg, context)
	local androidprojuuid = os.uuid(context.prj.name .. android._PACKAGING)
	premake.w("{%s}.%s.Deploy.0 = %s|%s", androidprojuuid, context.descriptor, context.platform, context.architecture)
end