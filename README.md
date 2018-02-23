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
	kind "ConsoleApp"
	system "android"
	files {
		"src/**.h",
		"src/**.cpp",
	}
	links {
		"EGL",
	}

project "Application.Packaging"
	dependson "Application"
	kind "Packaging"
	system "android"
	files {
		"data/**",
	}
```
