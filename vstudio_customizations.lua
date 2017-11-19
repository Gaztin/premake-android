require "vstudio"

local android = premake.modules.android
local vstudio = premake.vstudio

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