# تعليمات إعداد تطبيق الموبايل للاتصال بـ Web API

## الخطوات المطلوبة

### 1. تحديث عنوان API
افتح ملف `lib/services/api_service.dart` وحدّث `baseUrl`:

```dart
static const String baseUrl = 'http://YOUR_IP_ADDRESS:5000/api';
```

**كيفية معرفة عنوان IP الخاص بك:**
- **Windows**: افتح Command Prompt واكتب `ipconfig` - ابحث عن `IPv4 Address`
- **Mac/Linux**: افتح Terminal واكتب `ifconfig` - ابحث عن `inet`

**مثال:**
```dart
static const String baseUrl = 'http://192.168.1.100:5000/api';
```

### 2. التأكد من تشغيل Web API
قبل تشغيل تطبيق الموبايل، تأكد من:
1. تشغيل قاعدة البيانات SQL Server
2. تشغيل Web API من Visual Studio
3. أن الكمبيوتر والموبايل على نفس الشبكة (WiFi)

### 3. اختبار الاتصال
1. شغّل التطبيق على الموبايل
2. جرب تسجيل الدخول
3. إذا فشل الاتصال، تحقق من:
   - عنوان IP صحيح
   - Web API يعمل
   - Firewall لا يمنع الاتصال
   - الكمبيوتر والموبايل على نفس الشبكة

### 4. إعدادات Firewall (إذا لزم الأمر)
إذا كان الاتصال لا يعمل، قد تحتاج إلى:
- فتح Port 5000 في Windows Firewall
- أو تعطيل Firewall مؤقتاً للاختبار

## ملاحظات مهمة

- **للاختبار المحلي**: استخدم IP address للكمبيوتر
- **للإنتاج**: استخدم domain name أو IP address للخادم
- **HTTPS**: في الإنتاج، يجب استخدام HTTPS بدلاً من HTTP

## استكشاف الأخطاء

### خطأ: "Connection refused" أو "Failed to connect"
- تحقق من أن Web API يعمل
- تحقق من عنوان IP
- تحقق من أن Port 5000 مفتوح

### خطأ: "Timeout"
- تحقق من الاتصال بالشبكة
- تأكد من أن الكمبيوتر والموبايل على نفس الشبكة

### خطأ: "404 Not Found"
- تحقق من أن URL صحيح
- تأكد من أن Web API يعمل على Port 5000
