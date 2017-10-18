require "vstudio"

local p = premake
local a = p.modules.android
local v = p.vstudio.vc2010
local e = v.elements

a.androidproj = {}
local m = a.androidproj
m.elements = {}

--
-- Generate an Android project
--

m.elements.project = function(prj)
	return {
		v.xmlDeclaration,
		v.project,
		v.projectConfigurations,
		m.globals,
		m.importDefaultProps,
		m.configurationPropertiesGroup,
		m.importLanguageSettings,
		v.importExtensionSettings,
		v.userMacros,
		m.itemDefinitionGroups,
		v.assemblyReferences,
		m.files,
		m.projectReferences,
		m.importLanguageTargets,
		v.importExtensionTargets,
	}
end

--
-- Generate android project
--

function m.generate(prj)
	p.utf8()
	p.callArray(m.elements.project, prj)
	p.out('</Project>')

	-- Create strings.xml
	local strings = m.strings(prj)
	os.mkdir("res/values")
	local ok, err = os.writefile_ifnotequal(strings, "res/values/strings.xml")

	-- Create AndroidManifest.xml
	local androidManifest = m.androidManifest(prj)
	local ok, err = os.writefile_ifnotequal(androidManifest, "AndroidManifest.xml")

	-- Create build.xml
	local build = m.build(prj)
	local ok, err = os.writefile_ifnotequal(build, "build.xml")

	-- Create project.properties
	local projectProperties = m.projectProperties(prj)
	local ok, err = os.writefile_ifnotequal(projectProperties, "project.properties")
end

--
-- Globals
--

m.elements.globals = function(prj)
	return {
		m.minimalVisualStudioVersion,
		m.projectVersion,
		m.projectGuid,
	}
end

function m.globals(prj)
	v.propertyGroup(nil, "Globals")
	p.callArray(m.elements.globals, prj)
	p.pop('</PropertyGroup>')
end

function m.minimalVisualStudioVersion(prj)
	v.element("MinimumVisualStudioVersion", nil, "14.0")
end

function m.projectVersion(prj)
	v.element("ProjectVersion", nil, "1.0")
end

function m.projectGuid(prj)
	local prjname = prj.name .. a._PACKAGING
	local guid = os.uuid(prjname)

	v.element("ProjectGuid", nil, "{%s}", guid)
end

--
-- Default props
--

function m.importDefaultProps(prj)
	p.w("<Import Project=\"$(AndroidTargetsPath)\\Android.Default.props\" />")
end

--
-- Configuration properties group
--

m.elements.configurationProperties = function(cfg)
	return {
		m.configurationType,
		v.useDebugLibraries,
	}
end

function m.configurationProperties(cfg)
	v.propertyGroup(cfg, "Configuration")
	p.callArray(m.elements.configurationProperties, cfg)
	p.pop('</PropertyGroup>')
end

function m.configurationPropertiesGroup(prj)
	for cfg in p.project.eachconfig(prj) do
		m.configurationProperties(cfg)
	end
end

function m.configurationType(cfg)
	p.w("<ConfigurationType>Application</ConfigurationType>")
end

--
-- Import language settings
--

function m.importLanguageSettings(prj)
	p.w("<Import Project=\"$(AndroidTargetsPath)\\Android.props\" />")
end

--
-- Item definition groups
--

m.elements.itemDefinitionGroup = function(cfg)
	return {
		m.antPackage,
	}
end

function m.itemDefinitionGroup(cfg)
	p.push("<ItemDefinitionGroup %s>", v.condition(cfg))
	p.callArray(m.elements.itemDefinitionGroup, cfg)
	p.pop("</ItemDefinitionGroup>")
end

function m.itemDefinitionGroups(prj)
	for cfg in p.project.eachconfig(prj) do
		m.itemDefinitionGroup(cfg)
	end
end

function m.antPackage(cfg)
	p.push("<AntPackage>")
	p.w("<AndroidAppLibName>$(RootNamespace)</AndroidAppLibName>")
	p.pop("</AntPackage>")
end

--
-- Files
--

function m.files(prj)
	p.push("<ItemGroup>")
	p.w("<Content Include=\"res\\values\\strings.xml\" />")
	p.w("<AntBuildXml Include=\"build.xml\" />")
    p.w("<AndroidManifest Include=\"AndroidManifest.xml\" />")
    p.w("<AntProjectPropertiesFile Include=\"project.properties\" />")
	p.pop("</ItemGroup>")
end

--
-- Project references
--

function m.projectReferences(prj)
	local refs = p.project.getdependencies(prj, 'linkOnly')
	p.push('<ItemGroup>')
	for _, ref in ipairs(refs) do
		local relpath = p.vstudio.path(prj, p.vstudio.projectfile(ref))
		p.push('<ProjectReference Include=\"%s\">', relpath)
		p.callArray(v.elements.projectReferences, prj, ref)
		p.pop('</ProjectReference>')
	end
	p.push("<ProjectReference Include=\"" .. prj.name .. ".vcxproj\">")
	p.w("<Project>{" .. prj.uuid .. "}</Project>")
	p.pop("</ProjectReference>")
	p.pop('</ItemGroup>')
end

--
-- Import language targets
--

function m.importLanguageTargets(prj)
	p.w("<Import Project=\"$(AndroidTargetsPath)\\Android.targets\" />")
end

--
-- Generated files
--

m.stringsRaw = [[
<?xml version="1.0" encoding="utf-8"?>
<resources>
  <string name="app_name">%s%s</string>
</resources>
]]

function m.strings(prj)
	return string.format(m.stringsRaw, prj.name, a._PACKAGING)
end

m.androidManifestRaw = [[
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.$(ApplicationName)" android:versionCode="1" android:versionName="1.0">
  <uses-sdk android:minSdkVersion="9" android:targetSdkVersion="21"/>
  <application android:label="@string/app_name" android:hasCode="false">
    <activity android:name="android.app.NativeActivity" android:label="@string/app_name" android:configChanges="orientation|keyboardHidden">
      <meta-data android:name="android.app.lib_name" android:value="$(AndroidAppLibName)" />
      <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
      </intent-filter>
    </activity>
  </application>
</manifest>
]]

function m.androidManifest(prj)
	return string.format(m.androidManifestRaw)
end

m.buildRaw = [[
<?xml version="1.0" encoding="UTF-8"?>
<project name="$(projectname)" default="help">
  <property file="ant.properties" />
  <property environment="env" />
  <condition property="sdk.dir" value="${env.ANDROID_HOME}">
    <isset property="env.ANDROID_HOME" />
  </condition>
  <loadproperties srcFile="project.properties" />
  <fail message="sdk.dir is missing. Make sure ANDROID_HOME environment variable is correctly set." unless="sdk.dir" />
  <import file="custom_rules.xml" optional="true" />
  <import file="${sdk.dir}/tools/ant/build.xml" />
  <target name="-pre-compile">
    <path id="project.all.jars.path">
      <path path="${toString:project.all.jars.path}"/>
      <fileset dir="${jar.libs.dir}">
        <include name="*.jar"/>
      </fileset>
    </path>
  </target>
</project>
]]

function m.build(prj)
	return string.format(m.buildRaw)
end

m.projectPropertiesRaw = [[
target=$(androidapilevel)
]]

function m.projectProperties(prj)
	return string.format(m.projectPropertiesRaw)
end
