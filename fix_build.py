import re

file_path = 'android/app/build.gradle'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'applicationId\s+["\'].*?["\']', 'applicationId "com.neonbreaker.pro"', content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ تم تحديث اسم البكج نيم بنجاح!")
