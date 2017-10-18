local p = premake

--
-- Allow keywords
--

p.api.addAllowed("system", "android")
p.api.addAllowed("architecture", "ARM64")

--
-- When to load module
--

return function(cfg)
	return (cfg.system == "android")
end
