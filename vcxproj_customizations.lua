require "vstudio"

local android = premake.extensions.android
local vc2010 = premake.vstudio.vc2010

--
-- Globals
--

premake.override(vc2010.elements, "globals", function(base, prj)
	if prj.system == android._ANDROID then
		return table.join(base(prj), {
			android.keyword,
			android.rootNamespace,
			android.defaultLanguage,
			android.applicationType,
			android.applicationTypeRevision,
		})
	else
		return base(prj)
	end
end)

function android.keyword(prj)
	vc2010.element("Keyword", nil, "Android")
end

function android.rootNamespace(prj)
	vc2010.element("RootNamespace", nil, prj.name)
end

function android.defaultLanguage(prj)
	vc2010.element("DefaultLanguage", nil, "en-US")
end

function android.applicationType(prj)
	vc2010.element("ApplicationType", nil, "Android")
end

function android.applicationTypeRevision(prj)
	vc2010.element("ApplicationTypeRevision", nil, "3.0")
end

--
-- Configuration properties
--

premake.override(vc2010.elements, "configurationProperties", function(base, cfg)
	if cfg.system == android._ANDROID then
		return table.join(base(cfg), {
			android.androidApiLevel,
		})
	else
		return base(cfg)
	end
end)

premake.override(vc2010, "configurationType", function(base, cfg)
	if cfg.system == android._ANDROID and android.isApp(cfg.kind) then
		vc2010.element("ConfigurationType", nil, "DynamicLibrary")
	else
		base(cfg)
	end
end)

premake.override(vc2010, "platformToolset", function(base, cfg)
	-- Select toolset for android projects. Default to clang
	if cfg.system == android._ANDROID then
		local toolset = cfg.toolset:explode("-", true, 1)
		if toolset[1] == "gcc" then
			vc2010.element("PlatformToolset", nil, "Gcc_4_9")
		else
			vc2010.element("PlatformToolset", nil, "Clang_3_8")
		end
	else
		base(cfg)
	end
end)

premake.override(vc2010, "windowsSDKDesktopARMSupport", function(base, cfg)
	-- ARM platforms shouldn't trigger insertion of 'WindowsSDKDesktopARMSupport' in android projects
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

function android.androidApiLevel(cfg)
	-- Custom android API level. Default to Android-19
	local apilevel = cfg.androidapilevel or "android-19"
	vc2010.element("AndroidAPILevel", nil, apilevel)
end

--
-- Output properties
--

premake.override(vc2010.elements, "outputProperties", function(base, cfg)
	if cfg.system == android._ANDROID then
		return table.join(base(cfg), {
			android.useMultiToolTask,
		})
	else
		return base(cfg)
	end
end)

premake.override(vc2010, "outDir", function(base, cfg)
	-- Target directory for android projects has to be an absolute path
	if cfg.system == android._ANDROID then
		vc2010.element("OutDir", nil, cfg.targetdir .. "/")
	else
		base(cfg)
	end
end)

premake.override(vc2010, "intDir", function(base, cfg)
	-- Intermediate directory for android projects has to be an absolute path
	if cfg.system == android._ANDROID then
		vc2010.element("IntDir", nil, cfg.objdir .. "/")
	else
		base(cfg)
	end
end)

premake.override(vc2010, "targetName", function(base, cfg)
	-- Target names in android application projects have to start with 'lib'
	if cfg.system == android._ANDROID and android.isApp(cfg.kind) then
		vc2010.element("TargetName", nil, "lib" .. cfg.targetname)
	else
		base(cfg)
	end
end)

function android.useMultiToolTask(cfg)
	-- Android equivalent of 'MultiProcessorCompilation'
	if cfg.flags.MultiProcessorCompile then
		vc2010.element("UseMultiToolTask", nil, "true")
	end
end

--
-- ClCompile
--

premake.override(vc2010, "warningLevel", function(base, cfg)
	-- In android projects you either enable all warnings or turn them all off
	if cfg.system == android._ANDROID then
		local map = {
			Off = "TurnOffAllWarnings",
			Extra = "EnableAllWarnings"
		}
		vc2010.element("WarningLevel", nil, map[cfg.warnings] or map.Off)
	else
		base(cfg)
	end
end)

premake.override(vc2010, "debugInformationFormat", function(base, cfg)
	-- Android projects have a different value scheme for debug information format
	if cfg.system == android._ANDROID then
		local map = {
			Default = "LineNumber",
			Off = "None",
			Full = "FullDebug",
		}
		vc2010.element("DebugInformationFormat", nil, map[cfg.symbols] or map.Default)
	else
		base(cfg)
	end
end)

premake.override(vc2010, "multiProcessorCompilation", function(base, cfg)
	-- Ignore android projects since they use an alternate keyword and in a different properties group.
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

--
-- Link
--

premake.override(vc2010, "subSystem", function(base, cfg)
	-- Ignore android projects since they don't use subsystems
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

premake.override(vc2010, "importLibrary", function(base, cfg)
	-- Ignore android projects since they don't use import libraries
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

premake.override(vc2010, "generateDebugInformation", function(base, cfg)
	-- Ignore android projects since they don't use generate debug information
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

premake.override(vc2010, "exceptionHandling", function(base, cfg)
	-- Android projects use a different value scheme for exception handling
	if cfg.system == android._ANDROID then
		local map = {
			Default = "Disabled",
			On = "Enabled",
			Off = "Disabled",
			SEH = "Enabled",
		}
		vc2010.element("ExceptionHandling", nil, map[cfg.exceptionhandling] or map.Default)
	else
		base(cfg)
	end
end)
