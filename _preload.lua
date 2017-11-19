--
-- Allow keywords
--

premake.api.addAllowed("system", "android")
premake.api.addAllowed("architecture", "ARM64")

--
-- When to load module
--

return function(cfg)
	return (cfg.system == "android")
end