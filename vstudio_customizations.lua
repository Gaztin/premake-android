require "vstudio"

local p = premake
local m = p.modules.android
local v = p.vstudio

--
-- Project platform
--

p.override(v, "projectPlatform", function(base, cfg)
	if cfg.system == m._ANDROID then
		return cfg.buildcfg
	else
		return base(cfg, win32)
	end
end)

--
-- Arch from config
--

p.override(v, "archFromConfig", function(base, cfg, win32)
	if cfg.system == m._ANDROID then
		return cfg.architecture
	else
		return base(cfg, win32)
	end
end)
