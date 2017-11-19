local android = premake.extensions.android
android.build = {}

local build = android.build

--
-- Generate build.xml
--

function build.generate(prj)
	_p(0, '<?xml version="1.0" encoding="UTF-8"?>')
	_p(0, '<project name="$(projectname)" default="help">')
	_p(1, '<property file="ant.properties" />')
	_p(1, '<property environment="env" />')
	_p(1, '<condition property="sdk.dir" value="${env.ANDROID_HOME}">')
	_p(2, '<isset property="env.ANDROID_HOME" />')
	_p(1, '</condition>')
	_p(1, '<loadproperties srcFile="project.properties" />')
	_p(1, '<fail message="sdk.dir is missing. Make sure ANDROID_HOME environment variable is correctly set." unless="sdk.dir" />')
	_p(1, '<import file="custom_rules.xml" optional="true" />')
	_p(1, '<import file="${sdk.dir}/tools/ant/build.xml" />')
	_p(1, '<target name="-pre-compile">')
	_p(2, '<path id="project.all.jars.path">')
	_p(3, '<path path="${toString:project.all.jars.path}"/>')
	_p(3, '<fileset dir="${jar.libs.dir}">')
	_p(4, '<include name="*.jar"/>')
	_p(3, '</fileset>')
	_p(2, '</path>')
	_p(1, '</target>')
	_p(0, '</project>')
end