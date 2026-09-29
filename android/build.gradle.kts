allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://download.flutter.io") }
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }
        maven { url = uri("https://packages.jetbrains.team/maven/p/kotlin/kotlin-dependencies") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
    }
}


val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ✅ Ce bloc DOIT venir AVANT evaluationDependsOn(":app")
subprojects {
    afterEvaluate {
        val android = project.extensions.findByName("android") ?: return@afterEvaluate
        for (method in android.javaClass.methods) {
            if (method.name == "setCompileSdk" && method.parameterTypes.size == 1) {
                method.invoke(android, 35)
                break
            } else if ((method.name == "compileSdkVersion" || method.name == "setCompileSdkVersion") && 
                       method.parameterTypes.size == 1 && 
                       (method.parameterTypes[0] == Int::class.javaPrimitiveType || method.parameterTypes[0] == java.lang.Integer::class.java)) {
                method.invoke(android, 35)
                break
            }
        }
    }
}

// ✅ Ce bloc vient APRÈS le afterEvaluate
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}