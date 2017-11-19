require "../android"

premake.override(premake.project, "getdependencies", function(base, prj, mode)
	return base(prj, "all")
end)

premake.override(premake.vstudio, "needsExplicitLink", function(base, cfg)
	return false
end)

workspace "Workspace"
	configurations {
		"Debug",
		"Release",
	}
	platforms {
		"ARM",
		"ARM64",
	}

project "StaticLibrary"
	kind "StaticLib"
	system "android"
	files {
		"include/StaticLibrary.h",
		"include/StaticLibrary.cpp",
	}

project "DynamicLibrary"
	kind "SharedLib"
	system "android"
	defines {
		"__DLL__",
	}
	files {
		"include/DynamicLibrary.h",
		"include/DynamicLibrary.cpp",
	}

project "Application4"
	kind "ConsoleApp"
	system "android"
	dependson {
		"StaticLibrary",
--		"DynamicLibrary",
	}
	files {
		"src/**.h",
		"src/**.c",
		"src/**.cpp",
	}
	includedirs {
		"$(SolutionDir)include",
		"$(OutDir)",
	}
	linkoptions {
		"-lGLESv1_CM",
		"-lEGL",
	}
	filter {"configurations:Debug"}
		symbols "On"
		optimize "Off"
	filter {"configurations:Release"}
		symbols "Off"
		optimize "Full"