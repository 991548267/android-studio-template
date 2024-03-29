// Top-level build file where you can add configuration options common to all sub-projects/modules.
<#macro loadProperties>
<#if useOfflineRepo!false>
    Properties properties = new Properties()
    properties.load(project.rootProject.file("local.properties").newDataInputStream())
</#if>
</#macro>
<#macro useProperties>
<#if useOfflineRepo!false>
        properties.getProperty("offline.repo").split(",").each { repo ->
            maven { url repo }
        }
</#if>
</#macro>

buildscript {
    apply from: 'version.gradle'
    <#if includeKotlinSupport!false>
    ext.kotlin_version = '${kotlinVersion}'
    </#if>
    <@loadProperties/>
    repositories {
        <@useProperties/>
        google()
        jcenter()
        <#if includeKotlinEapRepo!false>maven { url '${kotlinEapRepoUrl}' }</#if>
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:${gradlePluginVersion}'
        <#if includeKotlinSupport!false>classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"</#if>
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    <@loadProperties/>
    repositories {
        <@useProperties/>
        maven {
            url "https://maven.aliyun.com/repository/google"
        }
        maven {
            url "https://maven.aliyun.com/repository/jcenter"
        }
        maven {
            url "https://jitpack.io"
        }
        <#if includeKotlinEapRepo!false>maven { url '${kotlinEapRepoUrl}' }</#if>
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
