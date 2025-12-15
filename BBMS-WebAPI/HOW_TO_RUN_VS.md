# كيفية تشغيل Web API من Visual Studio Community

## الخطوات التفصيلية

### 1. فتح المشروع في Visual Studio

1. افتح **Visual Studio Community**
2. من القائمة: **File** → **Open** → **Project/Solution**
3. اذهب إلى المسار:
   ```
   E:\Nour Eldeen\Study\Self Study\Projects\BBMS-Mobile\BBMS-DesktopApp\BBMS-WebAPI\BBMS-WebAPI.csproj
   ```
4. اضغط **Open**

### 2. إعداد المشروع كمشروع Startup

1. في **Solution Explorer** (على اليمين)
2. اضغط **كليك يمين** على مشروع `BBMS-WebAPI`
3. اختر **Set as Startup Project**

أو:
- اضغط **كليك يمين** على المشروع
- اختر **Properties**
- في تبويب **Application**، تأكد من أن المشروع محدد

### 3. تحديث إعدادات التشغيل (Launch Settings)

1. افتح ملف `Properties/launchSettings.json` (إن وجد)
2. أو أنشئ ملف جديد في مجلد `Properties`:

**إنشاء ملف `launchSettings.json`:**
```
BBMS-WebAPI/Properties/launchSettings.json
```

**المحتوى:**
```json
{
  "profiles": {
    "BBMS-WebAPI": {
      "commandName": "Project",
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "http://localhost:5000;https://localhost:5001",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

### 4. تشغيل المشروع

#### الطريقة الأولى: من Visual Studio
1. اضغط **F5** (Debug) أو **Ctrl+F5** (Run without debugging)
2. أو اضغط على زر **▶️ Run** الأخضر في الأعلى

#### الطريقة الثانية: من Terminal في VS
1. افتح **Terminal** في Visual Studio: **View** → **Terminal**
2. اكتب:
   ```bash
   dotnet run --urls "http://0.0.0.0:5000"
   ```

### 5. التحقق من أن المشروع يعمل

بعد التشغيل، يجب أن ترى:
- نافذة المتصفح تفتح تلقائياً على `https://localhost:5001/swagger`
- أو يمكنك فتح: `http://localhost:5000/swagger`

### 6. إعدادات مهمة

#### لتشغيل على IP محدد (للوصول من الموبايل):

1. في `Program.cs` أو `launchSettings.json`، استخدم:
   ```csharp
   app.Run("http://0.0.0.0:5000");
   ```

2. أو في Terminal:
   ```bash
   dotnet run --urls "http://0.0.0.0:5000"
   ```

#### لتشغيل على HTTP فقط (بدون HTTPS):

في `Program.cs`، علّق أو احذف السطر:
```csharp
// app.UseHttpsRedirection(); // علّق هذا السطر
```

### 7. استكشاف الأخطاء

#### مشكلة: Port 5000 مستخدم
**الحل:**
- غير Port في `launchSettings.json` إلى `5001` أو `5002`
- أو أغلق البرامج الأخرى التي تستخدم Port 5000

#### مشكلة: لا يمكن الوصول من الموبايل
**الحل:**
1. تأكد من استخدام `0.0.0.0` بدلاً من `localhost`
2. تأكد من أن Firewall يسمح بـ Port 5000
3. تأكد من أن الكمبيوتر والموبايل على نفس WiFi

#### مشكلة: مشروع لا يبني
**الحل:**
1. **Build** → **Clean Solution**
2. **Build** → **Rebuild Solution**
3. تأكد من أن جميع المشاريع (Data, Business, WebAPI) مبنية

### 8. نصائح سريعة

- **F5**: تشغيل مع Debugging
- **Ctrl+F5**: تشغيل بدون Debugging (أسرع)
- **Shift+F5**: إيقاف التشغيل
- **Ctrl+Shift+B**: Build المشروع

### 9. التحقق من النجاح

بعد التشغيل، يجب أن ترى في **Output** window:
```
Now listening on: http://localhost:5000
Application started. Press Ctrl+C to shut down.
```

---

## ملخص سريع

1. ✅ افتح `BBMS-WebAPI.csproj` في Visual Studio
2. ✅ اضبطه كمشروع Startup
3. ✅ اضغط **F5**
4. ✅ افتح `http://localhost:5000/swagger` في المتصفح

**جاهز! 🎉**
