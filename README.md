# Usage
premake5.lua
```lua
require "android"

workspace "Workspace"
	configurations {
		"Debug",
		"Release",
	}
	platforms {
		"ARM",
		"ARM64",
	}

project "Application"
	kind "SharedLib"
	system "android"
	files {
		"src/**.h",
		"src/**.cpp",
	}
	linkoptions {
		"-lEGL",
	}
```

## Notes
* Specify `system "android"` in your project to activate the module.
* Applications must be dynamic libraries ("SharedLib").
* Make sure you run the "Application.Packaging" project to deploy and debug your application.
