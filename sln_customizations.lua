require "vstudio"

local p = premake
local m = p.modules.android
local v = p.vstudio.sln2005

--
-- Projects
--

p.override(v, "projects", function(base, wks)
	base(wks)

	for prj in p.workspace.eachproject(wks) do
		if prj.system == m._ANDROID and m.isApp(prj.kind) then
			local prjname = prj.name .. m._PACKAGING
			local prjpath = prj.location .. "/" .. prjname .. ".androidproj"
			local prjuuid = os.uuid(prjname)
			prjpath = p.vstudio.path(wks, prjpath)

			p.push("Project(\"{39E2626F-3545-4960-A6E8-258AD8476CE5}\") = \"%s\", \"%s\", \"{%s}\"", prjname, prjpath, prjuuid)
			p.pop("EndProject")
		end
	end
end)

--
-- Project configuration platforms
--

p.override(v.elements, "projectConfigurationPlatforms", function(base, cfg, context)
	if context.prj.system == m._ANDROID and m.isApp(context.prj.kind) then
		return {
			m.activeCfg,
			m.build0,
			m.deploy0,
		}
	else
		return base(cfg, context)
	end
end)

function m.activeCfg(cfg, context)
	local androidprojuuid = os.uuid(context.prj.name .. m._PACKAGING)
	p.w("{%s}.%s.ActiveCfg = %s|%s", context.prj.uuid, context.descriptor, context.platform, context.architecture)
	p.w("{%s}.%s.ActiveCfg = %s|%s", androidprojuuid, context.descriptor, context.platform, context.architecture)
end

function m.build0(cfg, context)
	local androidprojuuid = os.uuid(context.prj.name .. m._PACKAGING)
	p.w("{%s}.%s.Build.0 = %s|%s", context.prj.uuid, context.descriptor, context.platform, context.architecture)
	p.w("{%s}.%s.Build.0 = %s|%s", androidprojuuid, context.descriptor, context.platform, context.architecture)
end

function m.deploy0(cfg, context)
	local androidprojuuid = os.uuid(context.prj.name .. m._PACKAGING)
	p.w("{%s}.%s.Deploy.0 = %s|%s", androidprojuuid, context.descriptor, context.platform, context.architecture)
end
