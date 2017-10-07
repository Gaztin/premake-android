local p = premake

--
-- Allow keywords
--

p.api.addAllowed("system", "android")

--
-- When to load module
--

return function(cfg)
	return (cfg.system == "android")
end
