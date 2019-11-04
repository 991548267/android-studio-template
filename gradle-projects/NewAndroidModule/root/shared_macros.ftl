<#import "root://gradle-projects/common/proguard_macros.ftl" as proguard>

<#-- Some common elements used in multiple files -->
<#macro watchProjectDependencies>
<#if WearprojectName?has_content && NumberOfEnabledFormFactors?has_content && NumberOfEnabledFormFactors gt 1 && Wearincluded>
    wearApp project(':${WearprojectName}')
    ${getConfigurationName("compile")} 'com.google.android.gms:play-services-wearable:+'
</#if>
</#macro>

<#macro generateManifest packageName hasApplicationBlock=false>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        <#if isDynamicInstantApp>
            xmlns:dist="http://schemas.android.com/apk/distribution"
        </#if>
        package="${packageName}"<#if !hasApplicationBlock>/</#if>><#if hasApplicationBlock>

        <#if isDynamicInstantApp>
        <dist:module
            dist:instant="true" />
        </#if>
    <application <#if minApiLevel gte 4 && buildApi gte 4>android:allowBackup="true"</#if>
        android:label="@string/app_name"<#if buildApi gte 24 && targetApi gte 24>
        android:networkSecurityConfig="@xml/network_security_config"</#if><#if copyIcons>
        android:icon="@mipmap/ic_launcher"<#if buildApi gte 25 && targetApi gte 25>
        android:roundIcon="@mipmap/ic_launcher_round"</#if><#elseif assetName??>
        android:icon="@drawable/${assetName}"</#if><#if buildApi gte 17>
        android:supportsRtl="true"</#if>
        android:theme="@style/AppTheme"/>
</manifest></#if>
</#macro>

<#macro androidConfig hasApplicationId=false applicationId='' hasTests=false canHaveCpp=false isBaseFeature=false canUseProguard=false>
android {
    compileSdkVersion build_versions.target_sdk
    buildToolsVersion build_versions.build_tools

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    lintOptions {
        abortOnError false
    }

    <#if isBaseFeature>
    baseFeature true
    </#if>

    defaultConfig {
    <#if hasApplicationId>
        applicationId "${applicationId}"
    </#if>
        minSdkVersion build_versions.min_sdk
        targetSdkVersion build_versions.target_sdk
        versionCode 1
        versionName "1.0"

    <#if hasTests>
        testInstrumentationRunner "${getMaterialComponentName('android.support.test.runner.AndroidJUnitRunner', useAndroidX)}"
    </#if>
    <#if canUseProguard && (isLibraryProject!false)>
        consumerProguardFiles 'consumer-rules.pro'
    </#if>
    <#if canHaveCpp && (includeCppSupport!false)>

        externalNativeBuild {
            cmake {
                cppFlags "${cppFlags}"
            }
        }
    </#if>

        flavorDimensions "template"
    }

<#if canHaveCpp && (includeCppSupport!false)>
    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.10.2"
        }
    }
</#if>

    signingConfigs {
        debug {
            storeFile file('default.jks')
            storePassword 'default123'
            keyPassword 'default1234'
            keyAlias 'default'
        }
        release {
            storeFile file('default.jks')
            storePassword 'default123'
            keyPassword 'default1234'
            keyAlias 'default'
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix ".debug"

            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }

        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            shrinkResources false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    flavorDimensions "template"

    productFlavors {
        develop {
            dimension "template"
            applicationIdSuffix ".develop"
            versionNameSuffix "-develop"
            // manifestPlaceholders = [app_name: "@string/app_name", app_icon: "@mipmap/ic_launcher"]
        }
        product {
            dimension "template"
            versionNameSuffix "-product"
            // manifestPlaceholders = [app_name: "@string/app_name", app_icon: "@mipmap/ic_launcher"]
        }
    }

    applicationVariants.all { variant ->
        variant.outputs.all { output ->
            def time = releaseTime()
            // output.outputFileName = "Template-$variant.buildType.name-v$variant.versionName-$time" + ".apk"
        }
    }
}
</#macro>
