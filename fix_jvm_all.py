import os, re

# 1. إجبار كافة المكونات في android/build.gradle
build_gradle = 'android/build.gradle'
with open(build_gradle, 'r', encoding='utf-8') as f:
    content = f.read()

force_jvm_code = """

allprojects {
    tasks.withType(JavaCompile) {
        sourceCompatibility = "1.8"
        targetCompatibility = "1.8"
    }
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
        kotlinOptions {
            jvmTarget = "1.8"
        }
    }
}
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android {
                compileOptions {
                    sourceCompatibility JavaVersion.VERSION_1_8
                    targetCompatibility JavaVersion.VERSION_1_8
                }
            }
        }
    }
}
"""

if 'allprojects' in content:
    # تنظيف أي إضافة سابقة وإلحاق الكود الجديد
    content = re.sub(r'allprojects\s*\{[\s\S]*', '', content)

content += force_jvm_code

with open(build_gradle, 'w', encoding='utf-8') as f:
    f.write(content)

# 2. تعديل android/app/build.gradle ليتوافق تماماً مع 1.8
app_gradle = 'android/app/build.gradle'
with open(app_gradle, 'r', encoding='utf-8') as f:
    app_content = f.read()

app_content = re.sub(r'JavaVersion\.VERSION_\d+_\d+', 'JavaVersion.VERSION_1_8', app_content)
app_content = re.sub(r"jvmTarget\s*=\s*['\"].*?['\"]", "jvmTarget = '1.8'", app_content)

with open(app_gradle, 'w', encoding='utf-8') as f:
    f.write(app_content)

print("✅ تم إجبار جميع الملفات والمكتبات الفرعية على Java 1.8 بنجاح!")
