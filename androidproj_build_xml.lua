local android = premake.extensions.android
android.build = {}

local build = android.build

--
-- Generate build.xml
--

function build.generate(prj)
	premake.w(0, '<?xml version="1.0" encoding="UTF-8"?>')
	premake.w(0, '<project name="$(projectname)" default="help">')
	premake.w(1, '<property file="ant.properties" />')
	premake.w(1, '<property environment="env" />')
	premake.w(1, '<condition property="sdk.dir" value="${env.ANDROID_HOME}">')
	premake.w(2, '<isset property="env.ANDROID_HOME" />')
	premake.w(1, '</condition>')
	premake.w(1, '<loadproperties srcFile="project.properties" />')
	premake.w(1, '<fail message="sdk.dir is missing. Make sure ANDROID_HOME environment variable is correctly set." unless="sdk.dir" />')
	premake.w(1, '<import file="custom_rules.xml" optional="true" />')
	premake.w(1, '<import file="${sdk.dir}/tools/ant/build.xml" />')
	premake.w(1, '<target name="-pre-compile">')
	premake.w(2, '<path id="project.all.jars.path">')
	premake.w(3, '<path path="${toString:project.all.jars.path}"/>')
	premake.w(3, '<fileset dir="${jar.libs.dir}">')
	premake.w(4, '<include name="*.jar"/>')
	premake.w(3, '</fileset>')
	premake.w(2, '</path>')
	premake.w(1, '</target>')
	premake.w(0, '</project>')
end