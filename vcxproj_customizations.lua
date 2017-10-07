require "vstudio"

local p = premake
local m = p.modules.android
local v = p.vstudio.vc2010
local e = v.elements

--
-- Globals
--

p.override(e, "globals", function(base, prj)
	return table.join(base(prj), {
		m.keyword,
		m.defaultLanguage,
		m.applicationType,
		m.applicationTypeRevision,
	})
end)

--
-- Platform toolset
--

p.override(v, "platformToolset", function(base, cfg)
	v.element("PlatformToolset", nil, "Clang_3_8")
end)

--
-- Element functions
--

function m.keyword(prj)
	if prj.system == m._ANDROID then
		v.element("Keyword", nil, "Android")
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
