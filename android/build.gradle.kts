allprojects {
    repositories {
        google()
        mavenCentral()
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
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
}

subprojects {
    val injectNamespace = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                // AGP 8.x BaseExtension has setNamespace(String)
                // We use reflection to avoid compile-time dependency on AGP classes in the root script
                val setNamespaceMethod = android.javaClass.methods.find { 
                    it.name == "setNamespace" && it.parameterCount == 1 && it.parameterTypes[0] == String::class.java 
                }
                
                if (setNamespaceMethod != null) {
                    if (project.name == "flutter_app_badger") {
                        setNamespaceMethod.invoke(android, "fr.g123k.flutterappbadge.flutterappbadger")
                    } else if (project.name != "app") {
                        // Check if namespace is already set
                        val getNamespaceMethod = android.javaClass.methods.find { 
                            it.name == "getNamespace" && it.parameterCount == 0 
                        }
                        val currentNamespace = getNamespaceMethod?.invoke(android)
                        if (currentNamespace == null || (currentNamespace is String && currentNamespace.isEmpty())) {
                            setNamespaceMethod.invoke(android, "com.example.${project.name.replace("-", "_")}")
                        }
                    }
                }
            } catch (e: Exception) {
                // Silently ignore if reflection fails
            }
        }
    }

    if (project.state.executed) {
        injectNamespace()
    } else {
        project.afterEvaluate { injectNamespace() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
