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
		if prj.system == m._ANDROID then
			local prjname = prj.name .. m._PACKAGING
			local prjpath = prj.location .. "/" .. prjname .. ".androidproj"
			local prjuuid = os.uuid(prjname)
			prjpath = p.vstudio.path(wks, prjpath)

			p.push("Project(\"{39E2626F-3545-4960-A6E8-258AD8476CE5}\") = \"%s\", \"%s\", \"{%s}\"", prjname, prjpath, prjuuid)
			p.pop("EndProject")
		end
	end
end)
