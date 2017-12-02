require "vstudio"

local android = premake.extensions.android
local vc2010 = premake.vstudio.vc2010
local sln2005 = premake.vstudio.sln2005
android.androidproj = {}

local androidproj = android.androidproj
androidproj.elements = {}

--
-- Utility functions
--

function androidproj.getDependentProject(prj)
	local dependent_prj = nil;
	local deps = premake.project.getdependencies(prj, "dependOnly")

	-- Go through all the dependent projects and find an application project
	for i, dp in ipairs(deps) do
		if android.isApp(dp.kind) then
			dependent_prj = dp
			break
		end
	end

	-- Make sure the package project depends on an application project
	if dependent_prj == nil then
		premake.error("Package project '%s' doesn't depend on any application projects", cfg.project.name)
	end

	return dependent_prj
end

--
-- Generate an Android project
--

androidproj.elements.project = function(prj)
	return {
		vc2010.xmlDeclaration,
		vc2010.project,
		vc2010.projectConfigurations,
		androidproj.globals,
		androidproj.importDefaultProps,
		androidproj.configurationPropertiesGroup,
		androidproj.importLanguageSettings,
		vc2010.importExtensionSettings,
		vc2010.userMacros,
		androidproj.outputPropertiesGroup,
		androidproj.itemDefinitionGroups,
		vc2010.assemblyReferences,
		androidproj.files,
		vc2010.projectReferences,
		androidproj.importLanguageTargets,
		vc2010.importExtensionTargets,
	}
end

--
-- Generate android project
--

function androidproj.generate(prj)
	premake.utf8()
	premake.callArray(androidproj.elements.project, prj)
	premake.out('</Project>')

	premake.generate(prj, prj.name .. "/AndroidManifest.xml", android.manifest.generate)
	premake.generate(prj, prj.name .. "/build.xml", android.build.generate)
	premake.generate(prj, prj.name .. "/project.properties", android.properties.generate)

	-- Create the assets folder
	os.mkdir(prj.location .. "\\Assets")
end

--
-- Solution extensions
--

premake.override(sln2005.elements, "projectConfigurationPlatforms", function(base, cfg, context)
	if context.prj.system == android._ANDROID and android.isPackaging(context.prj.kind) then
		return table.join(base(cfg, context), {
			androidproj.deploy0,
		})
	else
		return base(cfg, context)
	end
end)

function androidproj.deploy0(cfg, context)
	premake.w("{%s}.%s.Deploy.0 = %s|%s", context.prj.uuid, context.descriptor, context.platform, context.architecture)
end

--
-- Globals
--

androidproj.elements.globals = function(prj)
	return {
		androidproj.rootNamespace,
		androidproj.minimalVisualStudioVersion,
		androidproj.projectVersion,
		vc2010.projectGuid,
	}
end

function androidproj.globals(prj)
	vc2010.propertyGroup(nil, "Globals")
	premake.callArray(androidproj.elements.globals, prj)
	premake.pop('</PropertyGroup>')
end

function androidproj.rootNamespace(prj)
	vc2010.element("RootNamespace", nil, prj.name)
end

function androidproj.minimalVisualStudioVersion(prj)
	vc2010.element("MinimumVisualStudioVersion", nil, "14.0")
end

function androidproj.projectVersion(prj)
	vc2010.element("ProjectVersion", nil, "1.0")
end

--
-- Default props
--

function androidproj.importDefaultProps(prj)
	premake.w('<Import Project="$(AndroidTargetsPath)\\Android.Default.props" />')
end

--
-- Configuration properties group
--

androidproj.elements.configurationProperties = function(cfg)
	return {
		androidproj.useDebugLibraries,
		androidproj.configurationType,
	}
end

function androidproj.configurationProperties(cfg)
	vc2010.propertyGroup(cfg, "Configuration")
	premake.callArray(androidproj.elements.configurationProperties, cfg)
	premake.pop('</PropertyGroup>')
end

function androidproj.configurationPropertiesGroup(prj)
	for cfg in premake.project.eachconfig(prj) do
		androidproj.configurationProperties(cfg)
	end
end

function androidproj.useDebugLibraries(cfg)
	local runtime = premake.config.getruntime(cfg)
	premake.w("<UseDebugLibraries>%s</UseDebugLibraries>", tostring(runtime:endswith("Debug")))
end

function androidproj.configurationType(cfg)
	premake.w("<ConfigurationType>Application</ConfigurationType>")
end

--
-- Import language settings
--

function androidproj.importLanguageSettings(prj)
	premake.w('<Import Project="$(AndroidTargetsPath)\\Android.props" />')
end

--
-- Output properties group
--

androidproj.elements.outputProperties = function(cfg)
	return {
		androidproj.outDir,
		vc2010.intDir,
		androidproj.targetName,
		androidproj.targetExt,
	}
end

function androidproj.outputProperties(cfg)
	vc2010.propertyGroup(cfg)
	premake.callArray(androidproj.elements.outputProperties, cfg)
	premake.pop('</PropertyGroup>')
end

function androidproj.outputPropertiesGroup(prj)
	for cfg in premake.project.eachconfig(prj) do
		androidproj.outputProperties(cfg)
	end
end

function androidproj.outDir(cfg)
	local outdir = premake.vstudio.path(cfg, cfg.buildtarget.directory)
	if outdir:sub(1, 1) == "$" then
		vc2010.element("OutDir", nil, '%s', outdir)
	else
		vc2010.element("OutDir", nil, "$(ProjectDir)%s\\", outdir)
	end
end

function androidproj.targetName(cfg)
	vc2010.element("TargetName", nil, "$(RootNamespace)")
end

function androidproj.targetExt(cfg)
	vc2010.element("TargetExt", nil, ".apk")
end

--
-- Item definition groups
--

androidproj.elements.itemDefinitionGroup = function(cfg)
	return {
		androidproj.antPackage,
	}
end

function androidproj.itemDefinitionGroup(cfg)
	premake.push("<ItemDefinitionGroup %s>", vc2010.condition(cfg))
	premake.callArray(androidproj.elements.itemDefinitionGroup, cfg)
	premake.pop("</ItemDefinitionGroup>")
end

function androidproj.itemDefinitionGroups(prj)
	for cfg in premake.project.eachconfig(prj) do
		androidproj.itemDefinitionGroup(cfg)
	end
end

function androidproj.antPackage(cfg)
	local dependent_prj = androidproj.getDependentProject(cfg.project)

	premake.push("<AntPackage>")
	premake.w("<AndroidAppLibName>%s</AndroidAppLibName>", dependent_prj.name)
	premake.pop("</AntPackage>")
end

--
-- Files
--

function androidproj.files(prj)
	premake.push("<ItemGroup>")
	premake.push("<AntBuildXml Include=\"" .. prj.name .. "/build.xml\">")
	premake.w("<SubType>Designer</SubType>");
	premake.pop("</AntBuildXml>")
    premake.push("<AndroidManifest Include=\"" .. prj.name .. "/AndroidManifest.xml\">")
	premake.w("<SubType>Designer</SubType>");
    premake.pop("</AndroidManifest>")
    premake.w("<AntProjectPropertiesFile Include=\"" .. prj.name .. "/project.properties\" />")
	premake.pop("</ItemGroup>")

	-- Add asset files
	premake.push("<ItemGroup>")
	local tr = premake.project.getsourcetree(prj)
	premake.tree.traverse(tr, {
		onleaf = function(file)
			premake.w("<Content Include=\"Assets/%s\" />", file.path)
		end
		})
	premake.pop("</ItemGroup>")
end

--
-- Import language targets
--

function androidproj.importLanguageTargets(prj)
	premake.w("<Import Project=\"$(AndroidTargetsPath)\\Android.targets\" />")
end