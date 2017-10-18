require "vstudio"

local p = premake
local m = p.modules.android
local v = p.vstudio.vc2010
local e = v.elements

--
-- Generate project
--

p.override(p.vstudio.vs2010, "generateProject", function(base, prj)
	base(prj)

	if prj.system == m._ANDROID then
		p.generate(prj, m._PACKAGING .. ".androidproj", m.androidproj.generate)
	end
end)

--
-- Globals
--

p.override(e, "globals", function(base, prj)
	if prj.system == m._ANDROID then
		return table.join(base(prj), {
			m.keyword,
			m.rootNamespace,
			m.defaultLanguage,
			m.applicationType,
			m.applicationTypeRevision,
		})
	else
		base(prj)
	end
end)

--
-- Configuration
--

p.override(v, "platformToolset", function(base, cfg)
	if cfg.system == m._ANDROID then
		v.element("PlatformToolset", nil, "Clang_3_8")
	else
		base(cfg)
	end
end)

p.override(v, "windowsSDKDesktopARMSupport", function(base, cfg)
	if cfg.system ~= m._ANDROID then
		base(cfg)
	end
end)

p.override(v, "outputPropertiesGroup", function(base, cfg)
	if cfg.system ~= m._ANDROID then
		base(cfg)
	end
end)

p.override(v, "debugInformationFormat", function(base, cfg)
	if cfg.system ~= m._ANDROID then
		base(cfg)
	end
end)

p.override(v, "subSystem", function(base, cfg)
	if cfg.system ~= m._ANDROID then
		base(cfg)
	end
end)

p.override(v, "importLibrary", function(base, cfg)
	if cfg.system ~= m._ANDROID then
		base(cfg)
	end
end)

p.override(v, "generateDebugInformation", function(base, cfg)
	if cfg.system ~= m._ANDROID then
		base(cfg)
	end
end)

--
-- Element functions
--

function m.keyword(prj)
	if prj.system == m._ANDROID then
		v.element("Keyword", nil, "Android")
	end
end

function m.rootNamespace(prj)
	if prj.system == m._ANDROID then
		v.element("RootNamespace", nil, prj.name)
	end
end

function m.defaultLanguage(prj)
	if prj.system == m._ANDROID then
		v.element("DefaultLanguage", nil, "en-US")
	end
end

function m.applicationType(prj)
	if prj.system == m._ANDROID then
		v.element("ApplicationType", nil, "Android")
	end
end

function m.applicationTypeRevision(prj)
	if prj.system == m._ANDROID then
		v.element("ApplicationTypeRevision", nil, "3.0")
	end
end
