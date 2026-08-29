import os, re

def patch_build_gradle():
    build_gradle = 'android/build.gradle'
    
    # التأكد من وجود android/build.gradle أو إنشائه إن لم يكن موجوداً
    if not os.path.exists(build_gradle):
        print("⚠️ ملف android/build.gradle غير موجود، سيتم إنشاؤه...")
        with open(build_gradle, 'w', encoding='utf-8') as f:
            f.write("// Root build.gradle created automatically\n")
    
    with open(build_gradle, 'r', encoding='utf-8') as f:
        content = f.read()

    # كود فرض Java 17 و Kotlin 17 على كل المكتبات الفرعية (Subprojects)
    override_block = """

allprojects {
    tasks.withType(JavaCompile) {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
}

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
    }
}
"""

    # إلغاء أي إعدادات سابقة وتحديثها بـ Java 17
    content = re.sub(r'allprojects\s*\{[\s\S]*', '', content)
    content += override_block

    with open(build_gradle, 'w', encoding='utf-8') as f:
        f.write(content)
    print("✅ تم تحديث android/build.gradle لفرض Java 17 / JVM 17.")

def patch_app_gradle():
    app_gradle = 'android/app/build.gradle'
    if os.path.exists(app_gradle):
        with open(app_gradle, 'r', encoding='utf-8') as f:
            content = f.read()

        # استبدال أي تعيين قديم بـ Java 17
        content = re.sub(r'JavaVersion\.VERSION_\w+', 'JavaVersion.VERSION_17', content)
        content = re.sub(r"jvmTarget\s*=\s*['\"].*?['\"]", "jvmTarget = '17'", content)

        with open(app_gradle, 'w', encoding='utf-8') as f:
            f.write(content)
        print("✅ تم تحديث android/app/build.gradle إلى Java 17.")

patch_build_gradle()
patch_app_gradle()
