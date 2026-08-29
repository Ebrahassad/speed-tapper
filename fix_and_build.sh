#!/bin/bash

echo "=============================================="
echo "🔧 NeonBreaker - Fix & Build"
echo "=============================================="

# 1. تحديث Unity Ads
echo
echo "📦 تحديث unity_ads_plugin إلى 0.4.0..."

sed -i 's/^[[:space:]]*unity_ads_plugin:.*/  unity_ads_plugin: ^0.4.0/' pubspec.yaml

grep -n "unity_ads_plugin" pubspec.yaml

# 2. التأكد من وجود Gradle
if [ ! -f android/build.gradle ]; then
    echo "❌ android/build.gradle غير موجود"
    exit 1
fi

# 3. نسخة احتياطية
cp android/build.gradle android/build.gradle.backup

if [ -f android/app/build.gradle ]; then
    cp android/app/build.gradle android/app/build.gradle.backup
fi

# 4. إزالة كتلة الإصلاح السابقة إن وجدت
sed -i '/\/\/ NeonBreaker JVM compatibility fix/,$d' android/build.gradle

# 5. إضافة Java 17 + Kotlin 17
cat >> android/build.gradle <<'GRADLE'

// NeonBreaker JVM compatibility fix
subprojects {
    tasks.withType(JavaCompile).configureEach {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
        kotlinOptions {
            jvmTarget = "17"
        }
    }

    afterEvaluate { project ->
        if (project.hasProperty("android")) {
            project.android {
                compileOptions {
                    sourceCompatibility JavaVersion.VERSION_17
                    targetCompatibility JavaVersion.VERSION_17
                }
            }
        }
    }
}
GRADLE

echo
echo "✅ تم ضبط Java 17 و Kotlin JVM 17."

# 6. ضبط app/build.gradle
if [ -f android/app/build.gradle ]; then

    sed -i 's/JavaVersion\.VERSION_[A-Za-z0-9_]*/JavaVersion.VERSION_17/g' \
        android/app/build.gradle

    sed -i -E "s/jvmTarget[[:space:]]*=[[:space:]]*['\"][^'\"]*['\"]/jvmTarget = '17'/g" \
        android/app/build.gradle

    echo "✅ تم تحديث app/build.gradle."
fi

# 7. تنظيف
echo
echo "🧹 تنظيف المشروع..."
flutter clean

# حذف Unity Ads القديم
rm -rf ~/.pub-cache/hosted/pub.dev/unity_ads_plugin-0.3.30

# 8. تحميل الحزم
echo
echo "🔄 تحميل الحزم..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ فشل flutter pub get"
    exit 1
fi

echo
echo "🔎 نسخة Unity Ads الحالية:"
flutter pub deps 2>/dev/null | grep unity_ads_plugin

# 9. البناء
echo
echo "=============================================="
echo "🚀 بدء بناء APK..."
echo "=============================================="

flutter build apk --debug
STATUS=$?

# 10. التحقق الحقيقي من APK
APK="build/app/outputs/flutter-apk/app-debug.apk"

if [ $STATUS -eq 0 ] && [ -f "$APK" ]; then

    echo
    echo "=============================================="
    echo "🎉 BUILD SUCCESSFUL!"
    echo "=============================================="

    mkdir -p /sdcard/Download

    cp "$APK" /sdcard/Download/NeonBreaker.apk

    if [ -f /sdcard/Download/NeonBreaker.apk ]; then
        echo
        echo "📦 تم إنشاء APK بنجاح:"
        ls -lh /sdcard/Download/NeonBreaker.apk
        echo
        echo "✅ NeonBreaker.apk موجود الآن في Downloads."
    else
        echo "⚠️ البناء نجح لكن تعذر نسخ الملف إلى Downloads."
    fi

else

    echo
    echo "=============================================="
    echo "❌ BUILD FAILED"
    echo "=============================================="
    echo
    echo "لم يتم إنشاء APK، لذلك لن يتم نسخ أي ملف."
    echo "أرسل آخر 40-50 سطر من الخطأ."
    echo "=============================================="

    exit 1
fi
