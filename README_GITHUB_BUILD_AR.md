# ليلة المغتالين — بناء APK عبر GitHub

هذا مشروع Flutter، وتم إرفاق إعداد GitHub Actions لبناء نسخة Android بصيغة APK تلقائياً. لا تحتاج إلى تثبيت Flutter على جهازك؛ GitHub ينفّذ البناء على خوادمه.

## رفع المشروع إلى GitHub

1. فك ضغط ملف المشروع على جهازك.
2. أنشئ مستودعاً جديداً على GitHub، وليكن اسمه `night-of-assassins`.
3. افتح مجلد المشروع المفكوك في **GitHub Desktop**، ثم اختر **Add an Existing Repository** إن كان المجلد يحتوي مستودع Git، أو **Create a New Repository** داخل المجلد.
4. تأكد من رفع محتويات المجلد نفسها إلى جذر المستودع، بحيث يظهر `pubspec.yaml` في الصفحة الرئيسية، ويظهر المسار `.github/workflows/build-apk.yml`.
5. نفّذ Commit ثم **Publish repository** إلى GitHub على فرع `main`.

> مهم: لا ترفع ملف ZIP كما هو داخل المستودع. يجب فك الضغط ورفع الملفات والمجلدات الموجودة داخله، بما فيها مجلد `.github` المخفي.

## تنزيل APK

- بعد رفع المشروع إلى فرع `main`، افتح المستودع على GitHub ثم تبويب **Actions**.
- افتح عملية **Build Android APK** وانتظر حتى تصبح خضراء (نجاح).
- من قسم **Artifacts** أسفل تفاصيل العملية نزّل `night-of-assassins-android-apk`، ثم فك ضغطه لتحصل على `Night-of-Assassins.apk` وملف التحقق `.sha256`.

## إنشاء إصدار دائم في Releases (اختياري)

لإنشاء صفحة إصدار تحمل ملف APK:

1. افتح **Releases** ثم **Draft a new release**.
2. أنشئ tag جديداً مثل `v1.3.0`.
3. انشر الإصدار. سيعمل GitHub Actions تلقائياً على بناء APK وإرفاقه بالإصدار.

يمكن أيضاً تشغيل البناء يدوياً من **Actions → Build Android APK → Run workflow**.

## ملاحظات

- اسم التطبيق على Android: **ليلة المغتالين**.
- معرّف التطبيق الناتج: `com.assassins.night.night_of_assassins`.
- الناتج APK إصدار Release واحد، وليس ملف AAB.
- لم أتمكن من تنفيذ بناء Flutter فعلي داخل هذه البيئة لعدم توفر Flutter SDK هنا؛ نجاح البناء النهائي سيظهر في GitHub Actions. إذا ظهر خطأ في سجل البناء، أرسل سجل الخطأ وسأعدّل الإعداد.
