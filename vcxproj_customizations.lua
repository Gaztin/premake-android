require "vstudio"

local android = premake.modules.android
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
		base(prj)
	end
end)

--
-- Configuration
--

premake.override(vc2010, "configurationType", function(base, cfg)
	if cfg.system == android._ANDROID and android.isApp(cfg.kind) then
		vc2010.element("ConfigurationType", nil, "DynamicLibrary")
	else
		base(cfg)
	end
end)

premake.override(vc2010, "platformToolset", function(base, cfg)
	if cfg.system == android._ANDROID then
		vc2010.element("PlatformToolset", nil, "Clang_3_8")
	else
		base(cfg)
	end
end)

premake.override(vc2010, "windowsSDKDesktopARMSupport", function(base, cfg)
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

premake.override(vc2010, "targetExt", function(base, cfg)
	if cfg.system ~= android._ANDROID then
		base(cfg)
	else
		if android.isApp(cfg.kind) or cfg.kind == "SharedLib" then
			vc2010.element("TargetExt", nil, ".so")
		elseif cfg.kind == "StaticLib" then
			vc2010.element("TargetExt", nil, ".a")
		end
	end
end)

premake.override(vc2010, "debugInformationFormat", function(base, cfg)
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

premake.override(vc2010, "subSystem", function(base, cfg)
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

premake.override(vc2010, "importLibrary", function(base, cfg)
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

premake.override(vc2010, "generateDebugInformation", function(base, cfg)
	if cfg.system ~= android._ANDROID then
		base(cfg)
	end
end)

premake.override(vc2010, "warningLevel", function(base, cfg)
	if cfg.system == android._ANDROID then
		local map = { Off = "TurnOffAllWarnings", Extra = "EnableAllWarnings" }
		vc2010.element("WarningLevel", nil, map[cfg.warnings] or "TurnOffAllWarnings")
	else
		base(cfg)
	end
end)

premake.override(vc2010, "exceptionHandling", function(base, cfg)
	if cfg.system == android._ANDROID then
		if cfg.exceptionhandling == premake.OFF then
			vc2010.element("ExceptionHandling", nil, "Disabled")
		elseif cfg.exceptionhandling == "On" then
			vc2010.element("ExceptionHandling", nil, "Enabled")
		end
	else
		base(cfg)
	end
end)

--
-- Element functions
--

function android.keyword(prj)
	if prj.system == android._ANDROID then
		vc2010.element("Keyword", nil, "Android")
	end
end

function android.rootNamespace(prj)
	if prj.system == android._ANDROID then
		vc2010.element("RootNamespace", nil, prj.name)
	end
end

function android.defaultLanguage(prj)
	if prj.system == android._ANDROID then
		vc2010.element("DefaultLanguage", nil, "en-US")
	end
end

function android.applicationType(prj)
	if prj.system == android._ANDROID then
		vc2010.element("ApplicationType", nil, "Android")
	end
end

function android.applicationTypeRevision(prj)
	if prj.system == android._ANDROID then
		vc2010.element("ApplicationTypeRevision", nil, "3.0")
	end
end