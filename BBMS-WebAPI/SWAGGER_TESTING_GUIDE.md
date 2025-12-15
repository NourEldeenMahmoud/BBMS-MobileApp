# دليل اختبار API باستخدام Swagger
# Swagger API Testing Guide

## الوصول إلى Swagger

1. شغّل Web API من Visual Studio
2. افتح المتصفح واذهب إلى: `http://localhost:5000/swagger`
3. ستجد جميع الـ endpoints منظمة حسب Controllers

---

## 1. Authentication Endpoints (Auth)

### 1.1 تسجيل الدخول - Login

**Endpoint:** `POST /api/Auth/login`

**Request Body:**
```json
{
  "phoneNumber": "01012345678",
  "password": "password123"
}
```

**Response Success:**
```json
{
  "success": true,
  "token": "base64-encoded-token",
  "user": {
    "mobileUserID": 1,
    "personID": 1,
    "phoneNumber": "01012345678",
    "fullName": "Ahmed Mohamed Ali Hassan",
    "email": "ahmed@example.com",
    "bloodType": "O+",
    "dateOfBirth": "1990-05-15",
    "address": "Cairo, Egypt",
    "imagePath": ""
  }
}
```

**ملاحظة:** احفظ `mobileUserID` و `token` لاستخدامهما في باقي الـ endpoints.

---

### 1.2 التسجيل - Register

**Endpoint:** `POST /api/Auth/register`

**Request Body (الحد الأدنى):**
```json
{
  "phoneNumber": "01111111111",
  "password": "password123",
  "firstName": "Ahmed",
  "lastName": "Mohamed"
}
```

**Request Body (كامل):**
```json
{
  "phoneNumber": "01234567890",
  "password": "password123",
  "firstName": "Sara",
  "lastName": "Ahmed",
  "secondName": "Mohamed",
  "thirdName": "Ali",
  "email": "sara@example.com",
  "bloodType": "A+",
  "dateOfBirth": "1995-08-20",
  "address": "Alexandria, Egypt",
  "imagePath": ""
}
```

**Response Success:**
```json
{
  "success": true,
  "message": "Registration successful",
  "token": "base64-encoded-token",
  "user": {
    "mobileUserID": 2,
    "personID": 2,
    "phoneNumber": "01234567890",
    "fullName": "Sara Ahmed",
    "email": "sara@example.com",
    "bloodType": "A+",
    "dateOfBirth": "1995-08-20",
    "address": "Alexandria, Egypt",
    "imagePath": ""
  }
}
```

---

## 2. Profile Endpoints

### 2.1 الحصول على الملف الشخصي - Get Profile

**Endpoint:** `GET /api/Profile/{mobileUserID}`

**مثال:** `GET /api/Profile/1`

**Response:**
```json
{
  "mobileUserID": 1,
  "personID": 1,
  "phoneNumber": "01012345678",
  "fullName": "Ahmed Mohamed Ali Hassan",
  "email": "ahmed@example.com",
  "bloodType": "O+",
  "dateOfBirth": "1990-05-15",
  "address": "Cairo, Egypt",
  "imagePath": ""
}
```

---

### 2.2 تحديث الملف الشخصي - Update Profile

**Endpoint:** `POST /api/Profile/update/{mobileUserID}`

**مثال:** `POST /api/Profile/update/1`

**Request Body:**
```json
{
  "email": "newemail@example.com",
  "address": "New Address, Cairo",
  "imagePath": "/images/profile.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

---

## 3. Appointments Endpoints

### 3.1 الحصول على جميع المواعيد - Get Appointments

**Endpoint:** `GET /api/Appointments/user/{mobileUserID}`

**مثال:** `GET /api/Appointments/user/1`

**Response:**
```json
{
  "appointments": [
    {
      "transfusionID": 1,
      "appointmentDate": "2025-12-20",
      "appointmentTime": "10:00:00",
      "location": "City Blood Center",
      "statusText": "Pending",
      "quantityRequested": 450,
      "patientName": "Ahmed Mohamed",
      "transfusionRequestDate": "2025-12-14"
    }
  ]
}
```

---

### 3.2 حجز موعد - Book Appointment

**Endpoint:** `POST /api/Appointments/book`

**Request Body:**
```json
{
  "mobileUserID": 1,
  "quantityRequested": 450,
  "appointmentDate": "2025-12-20",
  "appointmentTime": "10:00:00",
  "location": "City Blood Center",
  "source": "Mobile App"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Appointment booked successfully",
  "transfusionID": 1
}
```

---

### 3.3 إلغاء موعد - Cancel Appointment

**Endpoint:** `POST /api/Appointments/cancel/{transfusionID}`

**مثال:** `POST /api/Appointments/cancel/1`

**Response:**
```json
{
  "success": true,
  "message": "Appointment cancelled successfully"
}
```

---

### 3.4 إعادة جدولة موعد - Reschedule Appointment

**Endpoint:** `POST /api/Appointments/reschedule/{transfusionID}`

**مثال:** `POST /api/Appointments/reschedule/1`

**Request Body:**
```json
{
  "appointmentDate": "2025-12-25",
  "appointmentTime": "14:00:00"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Appointment rescheduled successfully"
}
```

---

## 4. Donations Endpoints

### 4.1 الحصول على تاريخ التبرعات - Get Donation History

**Endpoint:** `GET /api/Donations/history/{mobileUserID}`

**مثال:** `GET /api/Donations/history/1`

**Response:**
```json
{
  "donations": [
    {
      "donationID": 1,
      "donationDate": "2025-11-15",
      "bloodVolume": 450.0,
      "location": ""
    },
    {
      "donationID": 2,
      "donationDate": "2025-10-10",
      "bloodVolume": 450.0,
      "location": ""
    }
  ]
}
```

---

### 4.2 الحصول على إحصائيات التبرعات - Get Donation Stats

**Endpoint:** `GET /api/Donations/stats/{mobileUserID}`

**مثال:** `GET /api/Donations/stats/1`

**Response:**
```json
{
  "totalDonations": 5,
  "totalVolume": 2250.0,
  "lastDonationDate": "2025-11-15"
}
```

---

## 5. Notifications Endpoints

### 5.1 الحصول على الإشعارات - Get Notifications

**Endpoint:** `GET /api/Notifications/{mobileUserID}`

**مثال:** `GET /api/Notifications/1`

**Response:**
```json
{
  "notifications": [
    {
      "notificationID": 1,
      "title": "Welcome to BBMS!",
      "message": "Thank you for registering with Blood Bank Management System.",
      "notificationType": "Info",
      "isRead": false,
      "createdDate": "2025-12-14T13:00:00",
      "transfusionID": null,
      "donationID": null
    },
    {
      "notificationID": 2,
      "title": "You can donate now!",
      "message": "You are eligible to donate blood. Schedule your appointment today.",
      "notificationType": "Eligibility",
      "isRead": false,
      "createdDate": "2025-12-13T10:00:00",
      "transfusionID": null,
      "donationID": null
    }
  ]
}
```

---

### 5.2 تحديد إشعار كمقروء - Mark Notification as Read

**Endpoint:** `POST /api/Notifications/read/{notificationID}`

**مثال:** `POST /api/Notifications/read/1`

**Response:**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

---

### 5.3 حذف جميع الإشعارات - Clear All Notifications

**Endpoint:** `POST /api/Notifications/clear/{mobileUserID}`

**مثال:** `POST /api/Notifications/clear/1`

**Response:**
```json
{
  "success": true,
  "message": "All notifications cleared"
}
```

---

## خطوات الاختبار في Swagger

### الخطوة 1: تسجيل الدخول
1. افتح `POST /api/Auth/login`
2. اضغط "Try it out"
3. أدخل بيانات تسجيل الدخول:
   ```json
   {
     "phoneNumber": "01012345678",
     "password": "password123"
   }
   ```
4. اضغط "Execute"
5. **احفظ `mobileUserID` من الـ response** (مثلاً: `1`)

### الخطوة 2: اختبار Profile
1. افتح `GET /api/Profile/{mobileUserID}`
2. أدخل `mobileUserID` (مثلاً: `1`)
3. اضغط "Execute"
4. ستظهر بيانات المستخدم

### الخطوة 3: اختبار Appointments
1. **احجز موعد:**
   - افتح `POST /api/Appointments/book`
   - أدخل:
     ```json
     {
       "mobileUserID": 1,
       "quantityRequested": 450,
       "appointmentDate": "2025-12-20",
       "appointmentTime": "10:00:00",
       "location": "City Blood Center",
       "source": "Mobile App"
     }
     ```
   - اضغط "Execute"
   - **احفظ `transfusionID` من الـ response**

2. **احصل على المواعيد:**
   - افتح `GET /api/Appointments/user/1`
   - اضغط "Execute"

3. **أعد جدولة موعد:**
   - افتح `POST /api/Appointments/reschedule/{transfusionID}`
   - أدخل `transfusionID` (مثلاً: `1`)
   - أدخل:
     ```json
     {
       "appointmentDate": "2025-12-25",
       "appointmentTime": "14:00:00"
     }
     ```
   - اضغط "Execute"

### الخطوة 4: اختبار Donations
1. افتح `GET /api/Donations/history/1`
2. اضغط "Execute"
3. افتح `GET /api/Donations/stats/1`
4. اضغط "Execute"

### الخطوة 5: اختبار Notifications
1. افتح `GET /api/Notifications/1`
2. اضغط "Execute"
3. **احفظ `notificationID` من الـ response** (مثلاً: `1`)
4. افتح `POST /api/Notifications/read/1`
5. اضغط "Execute"

---

## نصائح مهمة

### 1. استخدام Authorization (اختياري)
- بعض الـ endpoints قد تحتاج token
- في Swagger، اضغط "Authorize" (🔒) في الأعلى
- أدخل: `Bearer {your-token}`
- أو اتركه فارغاً إذا كان الكود لا يتحقق من الـ token حالياً

### 2. Format التواريخ
- استخدم: `YYYY-MM-DD` (مثلاً: `2025-12-20`)
- للوقت: `HH:mm:ss` (مثلاً: `10:00:00`)

### 3. Format الأرقام
- `mobileUserID`: رقم صحيح (مثلاً: `1`)
- `transfusionID`: رقم صحيح (مثلاً: `1`)
- `quantityRequested`: رقم صحيح (مثلاً: `450`)

### 4. الحقول الاختيارية
- يمكنك ترك الحقول الاختيارية فارغة أو حذفها من الـ request
- مثال: `email`, `address`, `imagePath` اختيارية في Register

---

## ترتيب الاختبار الموصى به

1. ✅ **Register** - إنشاء حساب جديد
2. ✅ **Login** - تسجيل الدخول (احفظ mobileUserID)
3. ✅ **Get Profile** - عرض الملف الشخصي
4. ✅ **Book Appointment** - حجز موعد (احفظ transfusionID)
5. ✅ **Get Appointments** - عرض المواعيد
6. ✅ **Reschedule Appointment** - إعادة جدولة موعد
7. ✅ **Get Donation History** - عرض تاريخ التبرعات
8. ✅ **Get Donation Stats** - عرض إحصائيات التبرعات
9. ✅ **Get Notifications** - عرض الإشعارات
10. ✅ **Mark Notification as Read** - تحديد إشعار كمقروء
11. ✅ **Update Profile** - تحديث الملف الشخصي

---

## استكشاف الأخطاء

### إذا ظهر خطأ 404 (Not Found)
- تأكد من أن Web API يعمل
- تأكد من الـ URL الصحيح
- تأكد من `mobileUserID` أو `transfusionID` صحيح

### إذا ظهر خطأ 500 (Internal Server Error)
- تحقق من رسالة الخطأ في الـ response
- تأكد من اتصال قاعدة البيانات
- تأكد من وجود البيانات المطلوبة في قاعدة البيانات

### إذا ظهر خطأ 200 لكن `success: false`
- اقرأ رسالة الخطأ في `message`
- تحقق من البيانات المرسلة
- تحقق من القيود في قاعدة البيانات

---

## مثال على جلسة اختبار كاملة

### 1. Register
```json
POST /api/Auth/register
{
  "phoneNumber": "09999999999",
  "password": "test123",
  "firstName": "Test",
  "lastName": "User"
}
```
**Result:** `mobileUserID = 3`

### 2. Login
```json
POST /api/Auth/login
{
  "phoneNumber": "09999999999",
  "password": "test123"
}
```
**Result:** `mobileUserID = 3`, `token = "..."`

### 3. Get Profile
```
GET /api/Profile/3
```

### 4. Book Appointment
```json
POST /api/Appointments/book
{
  "mobileUserID": 3,
  "quantityRequested": 450,
  "appointmentDate": "2025-12-25",
  "appointmentTime": "10:00:00",
  "location": "Test Center",
  "source": "Mobile"
}
```
**Result:** `transfusionID = 1`

### 5. Get Appointments
```
GET /api/Appointments/user/3
```

### 6. Get Notifications
```
GET /api/Notifications/3
```

---

## ملاحظات إضافية

- جميع الـ endpoints تعمل على `http://localhost:5000/api`
- Swagger UI متاح على `http://localhost:5000/swagger`
- يمكنك نسخ curl commands من Swagger لاستخدامها في Terminal
- يمكنك حفظ الـ responses كـ examples للتوثيق

---

## روابط سريعة

- **Swagger UI:** http://localhost:5000/swagger
- **API Base URL:** http://localhost:5000/api
- **Health Check:** افتح Swagger وستجد جميع الـ endpoints

---

**استمتع بالاختبار! 🎉**
