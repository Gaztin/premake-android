local android = premake.extensions.android
android.manifest = {}

local manifest = android.manifest

--
-- Generate AndroidManifest.xml
--

function manifest.generate(prj)
	premake.w(0, '<?xml version="1.0" encoding="utf-8"?>')
	premake.w(0, '<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.$(ApplicationName)" android:versionCode="1" android:versionName="1.0">')
	premake.w(1, '<uses-sdk android:minSdkVersion="9" android:targetSdkVersion="21"/>')
	premake.w(1, '<application android:label="' .. prj.name .. '" android:hasCode="false">')
	premake.w(2, '<activity android:name="android.app.NativeActivity" android:label="' .. prj.name .. '" android:configChanges="orientation|keyboardHidden">')
	premake.w(3, '<meta-data android:name="android.app.lib_name" android:value="$(AndroidAppLibName)" />')
	premake.w(3, '<intent-filter>')
	premake.w(4, '<action android:name="android.intent.action.MAIN" />')
	premake.w(4, '<category android:name="android.intent.category.LAUNCHER" />')
	premake.w(3, '</intent-filter>')
	premake.w(2, '</activity>')
	premake.w(1, '</application>')
	premake.w(0, '</manifest>')
end