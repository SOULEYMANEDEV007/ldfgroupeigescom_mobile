allprojects {
    repositories {
        google()
        mavenCentral()
        // Miroir JetBrains Space — artifacts Kotlin toujours disponibles
        maven { url = uri("https://packages.jetbrains.team/maven/p/kotlin/kotlin-dependencies") }
        // Miroir Aliyun (Alibaba Cloud) — accessible depuis l'Afrique de l'Ouest
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
