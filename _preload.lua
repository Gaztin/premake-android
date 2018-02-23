--
-- Allow keywords
--

premake.api.addAllowed("system", "android")
premake.api.addAllowed("architecture", "ARM64")
premake.api.addAllowed("kind", "Packaging")

-- Insert 'Packaging' kind in valid kinds for the current action

local current_action = premake.action.current()
table.insert(current_action.valid_kinds, "Packaging")

--
-- Register properties
--

premake.api.register {
	name = "androidapilevel",
	scope = "config",
	kind = "string",
}

--
-- When to load module
--

return function(cfg)
	return (cfg.system == "android")
end