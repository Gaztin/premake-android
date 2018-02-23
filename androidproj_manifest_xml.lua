local android = premake.extensions.android
android.manifest = {}

local manifest = android.manifest

--
-- Generate AndroidManifest.xml
--

function manifest.generate(prj)
	_p(0, '<?xml version="1.0" encoding="utf-8"?>')
	_p(0, '<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.%s" android:versionCode="1" android:versionName="1.0">', prj.name)
	_p(1, '<uses-sdk android:minSdkVersion="9" android:targetSdkVersion="21"/>')
	_p(1, '<application android:label="" android:hasCode="false">', prj.name)
	_p(2, '<activity android:name="android.app.NativeActivity" android:label="" android:configChanges="orientation|keyboardHidden">', prj.name)
	_p(3, '<meta-data android:name="android.app.lib_name" android:value="$(AndroidAppLibName)" />')
	_p(3, '<intent-filter>')
	_p(4, '<action android:name="android.intent.action.MAIN" />')
	_p(4, '<category android:name="android.intent.category.LAUNCHER" />')
	_p(3, '</intent-filter>')
	_p(2, '</activity>')
	_p(1, '</application>')
	_p(0, '</manifest>')
end