# TravelDeals LIVE — אפליקציית Flutter (אנדרואיד + iOS)

קוד מקור מלא לאפליקציית הדילים הקלילה: טיקר דילים רץ, פיד טקסטואלי, אלגוריתם "כדאיות" חי, סינון, מועדפים, ומשיכת דילים מ-API. קוד אחד → אנדרואיד, iOS וגם web.

## מבנה
- `pubspec.yaml` — הגדרות וחבילות (http, shared_preferences).
- `lib/main.dart` — כל האפליקציה (מודל, אלגוריתם, מסכים).

## להריץ / לבנות — צריך Flutter SDK
זה פרויקט מקור. כדי להפעיל אותו צריך להתקין Flutter (פעם אחת):

```bash
# אחרי התקנת Flutter (flutter.dev/docs/get-started/install):
cd flutter-app
flutter create .          # יוצר את תיקיות android/ ו-ios/ סביב הקוד
flutter pub get           # מוריד חבילות
flutter run               # מריץ על אמולטור/מכשיר מחובר
flutter analyze           # בדיקת תקינות הקוד
```

## לבנות חבילה ל-Google Play (קובץ .aab)
```bash
flutter build appbundle --release
# הקובץ ייווצר ב: build/app/outputs/bundle/release/app-release.aab
```
את הקובץ הזה מעלים ל-Google Play Console (יצירת אפליקציה → Production → העלאת .aab).
לבנייה ל-iOS צריך Mac עם Xcode: `flutter build ipa`.

## אם אין לך סביבת פיתוח — בנייה בענן (חינם)
אפשר לבנות בלי להתקין כלום מקומית, דרך שירות בנייה כמו **Codemagic** (מסלול חינמי):
1. העלה את הפרויקט ל-GitHub.
2. חבר את Codemagic ל-repo, בחר Flutter, ובנה `appbundle`.
3. הורד את ה-.aab והעלה ל-Play.

## מה להחליף לפני פרסום
- `apiBase` (בראש `main.dart`) — כתובת ה-Worker שלך כדי למשוך דילים מהשרת (ריק = רשימה מוטמעת).
- כדי שכפתור "להזמנה" יפתח את הלינק בדפדפן — הוסף את החבילה `url_launcher` והשתמש בה ב-`learn(d)`.
- מזהה אפליקציה (applicationId) ושם — ייקבעו אחרי `flutter create .` בקובץ `android/app/build.gradle`.

## הערה
זהו scaffold מלא ותקין כנקודת פתיחה. הקמפול הסופי, החתימה וההעלאה לחנות מתבצעים בסביבת בנייה (מקומית או בענן) — לא ניתן להפיק מהם קובץ חתום מתוך הצ'אט.
