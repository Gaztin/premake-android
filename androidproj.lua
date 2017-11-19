require "vstudio"

local android = premake.extensions.android
local vc2010 = premake.vstudio.vc2010
android.androidproj = {}

local androidproj = android.androidproj
androidproj.elements = {}

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
		androidproj.projectReferences,
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
end

--
-- Globals
--

androidproj.elements.globals = function(prj)
	return {
		androidproj.rootNamespace,
		androidproj.minimalVisualStudioVersion,
		androidproj.projectVersion,
		androidproj.projectGuid,
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

function androidproj.projectGuid(prj)
	local prjname = prj.name .. android._PACKAGING
	local guid = os.uuid(prjname)

	vc2010.element("ProjectGuid", nil, "{%s}", guid)
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
	premake.push("<AntPackage>")
	premake.w("<AndroidAppLibName>$(RootNamespace)</AndroidAppLibName>")
	premake.pop("</AntPackage>")
end

--
-- Files
--

function androidproj.files(prj)
	premake.push("<ItemGroup>")
	premake.w("<Content Include=\"res\\values\\strings.xml\" />")
	premake.push("<AntBuildXml Include=\"build.xml\">")
	premake.w("<SubType>Designer</SubType>");
	premake.pop("</AntBuildXml>")
    premake.push("<AndroidManifest Include=\"AndroidManifest.xml\">")
	premake.w("<SubType>Designer</SubType>");
    premake.pop("</AndroidManifest>")
    premake.w("<AntProjectPropertiesFile Include=\"project.properties\" />")
	premake.pop("</ItemGroup>")
end

--
-- Project references
--

function androidproj.projectReferences(prj)
	local refs = premake.project.getdependencies(prj, 'linkOnly')
	premake.push('<ItemGroup>')
	for _, ref in ipairs(refs) do
		local relpath = premake.vstudio.path(prj, premake.vstudio.projectfile(ref))
		premake.push('<ProjectReference Include=\"%s\">', relpath)
		premake.callArray(vc2010.elements.projectReferences, prj, ref)
		premake.pop('</ProjectReference>')
	end
	premake.push("<ProjectReference Include=\"" .. prj.name .. ".vcxproj\">")
	premake.w("<Project>{" .. prj.uuid .. "}</Project>")
	premake.pop("</ProjectReference>")
	premake.pop('</ItemGroup>')
end

--
-- Import language targets
--

function androidproj.importLanguageTargets(prj)
	premake.w("<Import Project=\"$(AndroidTargetsPath)\\Android.targets\" />")
end