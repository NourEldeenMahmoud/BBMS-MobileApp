# 🔧 حل مشكلة Connection Timeout

## المشكلة
```
Connection timed out (OS Error: Connection timed out, errno = 110)
address = 192.168.1.2, port = 5000
```

## الأسباب المحتملة والحلول

### ✅ 1. Web API غير مشغل
**الحل:**
- تأكد من أن Web API يعمل في Visual Studio
- اضغط **F5** لتشغيل المشروع
- يجب أن ترى في Output: `Now listening on: http://0.0.0.0:5000`

### ✅ 2. Web API يعمل على localhost فقط
**الحل:**
- في Visual Studio: اختر Profile **"BBMS-WebAPI (HTTP Only)"**
- أو استخدم `http://0.0.0.0:5000` في `launchSettings.json`
- تم تحديث الإعدادات تلقائياً ✅

### ✅ 3. Firewall يمنع الاتصال
**الحل:**

#### Windows Firewall:
1. افتح **Windows Defender Firewall**
2. **Advanced settings**
3. **Inbound Rules** → **New Rule**
4. اختر **Port** → **Next**
5. **TCP** → **Specific local ports**: `5000`
6. **Allow the connection** → **Next**
7. اختر جميع Profiles → **Next**
8. اسم: "BBMS Web API" → **Finish**

#### أو من Command Prompt (كـ Administrator):
```cmd
netsh advfirewall firewall add rule name="BBMS Web API" dir=in action=allow protocol=TCP localport=5000
```

### ✅ 4. IP Address خاطئ
**الحل:**
1. افتح Command Prompt
2. اكتب: `ipconfig`
3. ابحث عن **IPv4 Address** تحت **Wi-Fi adapter**
4. حدّث `api_service.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:5000/api';
   ```

### ✅ 5. الكمبيوتر والموبايل على شبكات مختلفة
**الحل:**
- تأكد من أن الكمبيوتر والموبايل على نفس WiFi
- لا تستخدم Mobile Data على الموبايل

### ✅ 6. Port 5000 مستخدم
**الحل:**
1. افتح Command Prompt
2. اكتب: `netstat -ano | findstr :5000`
3. إذا وجدت عملية، أوقفها
4. أو غيّر Port في `launchSettings.json` إلى `5001` أو `5002`

---

## خطوات التحقق السريعة

### 1. تحقق من أن Web API يعمل:
افتح المتصفح واذهب إلى:
```
http://localhost:5000/swagger
```
إذا فتح Swagger، يعني API يعمل ✅

### 2. تحقق من IP Address:
في Command Prompt:
```cmd
ipconfig
```
تأكد من أن IP في `api_service.dart` مطابق

### 3. اختبر الاتصال من الموبايل:
افتح متصفح الموبايل واذهب إلى:
```
http://192.168.1.2:5000/swagger
```
إذا فتح، يعني الاتصال يعمل ✅

---

## حل سريع (خطوة بخطوة)

### في Visual Studio:
1. ✅ افتح المشروع
2. ✅ اختر Profile: **"BBMS-WebAPI (HTTP Only)"**
3. ✅ اضغط **F5**
4. ✅ تأكد من الرسالة: `Now listening on: http://0.0.0.0:5000`

### في الموبايل:
1. ✅ تأكد من WiFi (ليس Mobile Data)
2. ✅ تأكد من IP في `api_service.dart` = `192.168.1.2`
3. ✅ جرب تسجيل الدخول مرة أخرى

---

## اختبار الاتصال

### من Command Prompt على الكمبيوتر:
```cmd
curl http://192.168.1.2:5000/api/auth/login -Method POST -ContentType "application/json" -Body '{"phoneNumber":"test","password":"test"}'
```

### من متصفح الموبايل:
افتح: `http://192.168.1.2:5000/swagger`

---

## ملاحظات مهمة

- ⚠️ تأكد من أن Web API يعمل قبل محاولة الاتصال من الموبايل
- ⚠️ استخدم `0.0.0.0` وليس `localhost` للوصول من الموبايل
- ⚠️ تأكد من Firewall يسمح بـ Port 5000
- ⚠️ الكمبيوتر والموبايل يجب أن يكونا على نفس WiFi

---

**بعد تطبيق الحلول، يجب أن يعمل الاتصال! ✅**
