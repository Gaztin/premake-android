require "vstudio"

local android = premake.modules.android
local vstudio = premake.vstudio
local vs2010 = vstudio.vs2010

--
-- Fix file extensions for packaging projects when generating project files
--

premake.override(vs2010, "generateProject", function(base, prj)
	if prj.system == android._ANDROID  then
		if android.isPackaging(prj.kind) then
			premake.eol("\r\n")
			premake.indent("  ")
			premake.escaper(vs2010.esc)

			local prjModified = premake.generate(prj, android._ANDROIDPROJ, android.androidproj.generate)

			-- Skip generation of empty user files
			local user = premake.capture(function()
				vstudio.vc2010.generateUser(prj)
			end)
			if #user > 0 then
				premake.generate(prj, android._ANDROIDPROJ .. ".user", function()
					premake.outln(user)
				end)
			end

			-- Only generate a filters file if the source tree actually has subfolders
			if premake.tree.hasbranches(premake.project.getsourcetree(prj)) then
				if premake.generate(prj, android._ANDROIDPROJ .. ".filters", vstudio.vc2010.generateFilters) == true and prjModified == false then
					-- vs workaround for issue where if only the .filters file is modified, VS doesn't automatically trigger a reload
					premake.touch(prj, android._ANDROIDPROJ)
				end
			end
		elseif android.isApp(prj.kind) then
			-- Go through all the packaging projects in the workspace to find one that depends on this application project
			for p in premake.workspace.eachproject(prj.workspace) do
				if p.system == android._ANDROID and android.isPackaging(p.kind) then
					local dependent_prj = android.androidproj.getDependentProject(p)
					if dependent_prj == prj then
						-- If it found one, insert the asset copying post-build event
						for cfg in premake.project.eachconfig(prj) do
							table.insert(cfg["postbuildcommands"], "xcopy /sy \"$(LocalDebuggerWorkingDirectory)\\data\" \"" .. p.location .. "/Assets\"")
						end
					end
				end
			end
		end
	else
		base(prj)
	end
end)

--
-- Fix VS tool for packaging projects
--

premake.override(vstudio, "tool", function(base, prj)
	if prj.system == android._ANDROID and android.isPackaging(prj.kind) then
		return "39E2626F-3545-4960-A6E8-258AD8476CE5"
	else
		return base(prj)
	end
end)

--
-- Fix file extensions for packaging projects when generating file paths
--

premake.override(vstudio, "projectfile", function(base, prj)
	if prj.system == android._ANDROID and android.isPackaging(prj.kind) then
		return premake.filename(prj, android._ANDROIDPROJ)
	else
		return base(prj)
	end
end)

--
-- Project platform
--

premake.override(vstudio, "projectPlatform", function(base, cfg)
	if cfg.system == android._ANDROID then
		return cfg.buildcfg
	else
		return base(cfg, win32)
	end
end)

--
-- Arch from config
--

premake.override(vstudio, "archFromConfig", function(base, cfg, win32)
	if cfg.system == android._ANDROID then
		return cfg.architecture
	else
		return base(cfg, win32)
	end
end)