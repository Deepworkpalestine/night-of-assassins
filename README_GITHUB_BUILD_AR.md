# ليلة المغتالين — دليل البناء عبر GitHub

المستودع الرئيسي للمشروع هو:
https://github.com/Deepworkpalestine/night-of-assassins

هذا مشروع Flutter للعبة جماعية محلية باللغة العربية. يتم إنشاء ملفات منصة Android داخل GitHub Actions ثم بناء APK تلقائيًا.

## تنزيل نسخة APK

1. افتح تبويب [Actions](https://github.com/Deepworkpalestine/night-of-assassins/actions/workflows/build-apk.yml).
2. اختر أحدث عملية بناء تحمل حالة Success.
3. افتح العملية ونزّل الملف night-of-assassins-android-apk من قسم Artifacts.
4. فك ضغط الملف للحصول على Night-of-Assassins.apk وملف التحقق SHA-256.

تُحفظ ملفات Artifacts لمدة 30 يومًا. للحصول على إصدار دائم في صفحة Releases، أنشئ وادفع وسم إصدار مثل v1.3.0:

```bash
git tag v1.3.0
git push origin v1.3.0
```

سيبني GitHub Actions ملف APK ويرفقه بالإصدار تلقائيًا.

## البناء محليًا

بعد تثبيت Flutter وAndroid SDK، نفّذ من مجلد المشروع:

```bash
flutter create --platforms=android --org com.assassins.night --project-name night_of_assassins .
flutter pub get
flutter run
```

ولإنشاء نسخة Release:

```bash
flutter build apk --release
```

## فحوصات الجودة

```bash
flutter analyze
flutter test
```

يعمل سير CI تلقائيًا عند الدفع إلى فرع main أو فتح Pull Request يستهدفه.

## معلومات التطبيق

- الاسم: ليلة المغتالين (Night of Assassins).
- التقنية: Flutter / Dart.
- معرّف Android المستخدم في البناء: com.assassins.night.night_of_assassins.
- ناتج البناء: APK إصدار Release.

## الترخيص

يرجى مراجعة [README الرئيسي](README.md) و[ملف تراخيص الأصول](ASSET-LICENSES.md). ترخيص MIT يغطي كود المشروع الأصلي والوثائق فقط، ولا يمنح تلقائيًا حق إعادة توزيع الخطوط أو الصور أو المؤثرات الصوتية.
