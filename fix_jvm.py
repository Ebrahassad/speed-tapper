import os

# تعديل android/build.gradle لفرض Java 17 على كافة الحزم الفرعية
build_path = 'android/build.gradle'
with open(build_path, 'r', encoding='utf-8') as f:
    content = f.read()

fix_code = """
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android {
                compileOptions {
                    sourceCompatibility JavaVersion.VERSION_17
                    targetCompatibility JavaVersion.VERSION_17
                }
            }
        }
        tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
            kotlinOptions {
                jvmTarget = '17'
            }
        }
    }
}
"""

if 'subprojects' not in content:
    content += "\n" + fix_code

with open(build_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ تم توحيد إصدار JVM Target لجميع المكتبات بنجاح!")
