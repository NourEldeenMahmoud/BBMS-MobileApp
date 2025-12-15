# دليل اختبار API - BBMS Web API
## API Testing Guide

---

## 📋 جدول المحتويات
1. [Authentication Endpoints](#authentication)
2. [Profile Endpoints](#profile)
3. [Appointments Endpoints](#appointments)
4. [Donations Endpoints](#donations)
5. [Notifications Endpoints](#notifications)

---

## 🔐 Authentication Endpoints

### 1. Login
**POST** `/api/Auth/login`

**Request Body:**
```json
{
  "phoneNumber": "01012345678",
  "password": "password123"
}
```

**Response (Success):**
```json
{
  "success": true,
  "token": "base64_encoded_token",
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

**cURL:**
```bash
curl -X 'POST' \
  'http://localhost:5000/api/Auth/login' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "phoneNumber": "01012345678",
  "password": "password123"
}'
```

---

### 2. Register
**POST** `/api/Auth/register`

**Request Body (Minimum Required):**
```json
{
  "phoneNumber": "01111111111",
  "password": "password123",
  "firstName": "Ahmed",
  "lastName": "Mohamed"
}
```

**Request Body (Full):**
```json
{
  "phoneNumber": "01111111111",
  "password": "password123",
  "firstName": "Ahmed",
  "lastName": "Mohamed",
  "secondName": "Ali",
  "thirdName": "Hassan",
  "email": "ahmed@example.com",
  "bloodType": "O+",
  "dateOfBirth": "1990-01-01",
  "address": "Cairo, Egypt",
  "imagePath": ""
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Registration successful",
  "token": "base64_encoded_token",
  "user": {
    "mobileUserID": 2,
    "personID": 2,
    "phoneNumber": "01111111111",
    "fullName": "Ahmed Mohamed",
    "email": "ahmed@example.com",
    "bloodType": "O+",
    "dateOfBirth": "1990-01-01",
    "address": "Cairo, Egypt",
    "imagePath": ""
  }
}
```

**cURL:**
```bash
curl -X 'POST' \
  'http://localhost:5000/api/Auth/register' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "phoneNumber": "01111111111",
  "password": "password123",
  "firstName": "Ahmed",
  "lastName": "Mohamed"
}'
```

---

## 👤 Profile Endpoints

### 1. Get Profile
**GET** `/api/Profile/{mobileUserID}`

**Headers:**
```
Authorization: Bearer {token}
```

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

**cURL:**
```bash
curl -X 'GET' \
  'http://localhost:5000/api/Profile/1' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

### 2. Update Profile
**POST** `/api/Profile/update/{mobileUserID}`

**Request Body:**
```json
{
  "email": "newemail@example.com",
  "address": "New Address, Cairo",
  "imagePath": "/path/to/image.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

**cURL:**
```bash
curl -X 'POST' \
  'http://localhost:5000/api/Profile/update/1' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  -d '{
  "email": "newemail@example.com",
  "address": "New Address, Cairo"
}'
```

---

## 📅 Appointments Endpoints

### 1. Get Appointments
**GET** `/api/Appointments/user/{mobileUserID}`

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

**cURL:**
```bash
curl -X 'GET' \
  'http://localhost:5000/api/Appointments/user/1' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

### 2. Book Appointment
**POST** `/api/Appointments/book`

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

**cURL:**
```bash
curl -X 'POST' \
  'http://localhost:5000/api/Appointments/book' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  -d '{
  "mobileUserID": 1,
  "quantityRequested": 450,
  "appointmentDate": "2025-12-20",
  "appointmentTime": "10:00:00",
  "location": "City Blood Center",
  "source": "Mobile App"
}'
```

---

### 3. Cancel Appointment
**POST** `/api/Appointments/cancel/{transfusionID}`

**Response:**
```json
{
  "success": true,
  "message": "Appointment cancelled successfully"
}
```

**cURL:**
```bash
curl -X 'POST' \
  'http://localhost:5000/api/Appointments/cancel/1' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

### 4. Reschedule Appointment
**POST** `/api/Appointments/reschedule/{transfusionID}`

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

**cURL:**
```bash
curl -X 'POST' \
  'http://localhost:5000/api/Appointments/reschedule/1' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  -d '{
  "appointmentDate": "2025-12-25",
  "appointmentTime": "14:00:00"
}'
```

---

## 🩸 Donations Endpoints

### 1. Get Donation History
**GET** `/api/Donations/history/{mobileUserID}`

**Response:**
```json
{
  "donations": [
    {
      "donationID": 1,
      "donationDate": "2025-09-15",
      "bloodVolume": 450.0,
      "location": ""
    }
  ]
}
```

**cURL:**
```bash
curl -X 'GET' \
  'http://localhost:5000/api/Donations/history/1' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

### 2. Get Donation Stats
**GET** `/api/Donations/stats/{mobileUserID}`

**Response:**
```json
{
  "totalDonations": 5,
  "totalVolume": 2250.0,
  "lastDonationDate": "2025-09-15"
}
```

**cURL:**
```bash
curl -X 'GET' \
  'http://localhost:5000/api/Donations/stats/1' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

## 🔔 Notifications Endpoints

### 1. Get Notifications
**GET** `/api/Notifications/{mobileUserID}`

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
    }
  ]
}
```

**cURL:**
```bash
curl -X 'GET' \
  'http://localhost:5000/api/Notifications/1' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

### 2. Mark Notification as Read
**POST** `/api/Notifications/read/{notificationID}`

**Response:**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

**cURL:**
```bash
curl -X 'POST' \
  'http://localhost:5000/api/Notifications/read/1' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

### 3. Clear All Notifications
**POST** `/api/Notifications/clear/{mobileUserID}`

**Response:**
```json
{
  "success": true,
  "message": "All notifications cleared"
}
```

**cURL:**
```bash
curl -X 'POST' \
  'http://localhost:5000/api/Notifications/clear/1' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

## 🧪 سيناريوهات الاختبار

### سيناريو 1: تسجيل دخول وتسجيل خروج كامل
1. **Register** → احصل على `token` و `mobileUserID`
2. **Get Profile** → تحقق من البيانات
3. **Get Appointments** → تحقق من المواعيد (قد تكون فارغة)
4. **Get Donations** → تحقق من تاريخ التبرعات (قد يكون فارغ)
5. **Get Notifications** → تحقق من الإشعارات

### سيناريو 2: حجز موعد
1. **Login** → احصل على `token` و `mobileUserID`
2. **Book Appointment** → احجز موعد جديد
3. **Get Appointments** → تحقق من الموعد الجديد
4. **Reschedule Appointment** → غير موعد الموعد
5. **Cancel Appointment** → ألغِ الموعد

### سيناريو 3: تحديث الملف الشخصي
1. **Login** → احصل على `token` و `mobileUserID`
2. **Get Profile** → احصل على البيانات الحالية
3. **Update Profile** → حدث البيانات
4. **Get Profile** → تحقق من التحديثات

---

## 📝 ملاحظات مهمة

1. **Token**: بعد Login أو Register، احفظ `token` واستخدمه في Header:
   ```
   Authorization: Bearer {token}
   ```

2. **mobileUserID**: بعد Login أو Register، احفظ `mobileUserID` واستخدمه في جميع الـ endpoints الأخرى.

3. **Base URL**: 
   - Local: `http://localhost:5000/api`
   - Network: `http://192.168.1.2:5000/api` (استبدل بـ IP جهازك)

4. **Swagger UI**: افتح `http://localhost:5000/swagger` لرؤية جميع الـ endpoints وتجربتها مباشرة.

---

## ✅ Checklist للاختبار

- [ ] Login (تسجيل دخول)
- [ ] Register (تسجيل جديد)
- [ ] Get Profile (الحصول على الملف الشخصي)
- [ ] Update Profile (تحديث الملف الشخصي)
- [ ] Get Appointments (الحصول على المواعيد)
- [ ] Book Appointment (حجز موعد)
- [ ] Reschedule Appointment (تغيير موعد)
- [ ] Cancel Appointment (إلغاء موعد)
- [ ] Get Donation History (تاريخ التبرعات)
- [ ] Get Donation Stats (إحصائيات التبرعات)
- [ ] Get Notifications (الإشعارات)
- [ ] Mark Notification as Read (تحديد الإشعار كمقروء)
- [ ] Clear All Notifications (حذف جميع الإشعارات)

---

## 🐛 Troubleshooting

### مشكلة: "Connection timed out"
- تحقق من أن Web API يعمل
- تحقق من IP address في `api_service.dart`
- تحقق من Windows Firewall

### مشكلة: "401 Unauthorized"
- تحقق من أن Token صحيح
- تأكد من إرسال Header: `Authorization: Bearer {token}`

### مشكلة: "404 Not Found"
- تحقق من أن الـ endpoint موجود
- تحقق من Base URL
- تحقق من Route path

---

## 📚 المزيد من المعلومات

- `QUICK_START.md` - دليل البدء السريع
- `TROUBLESHOOTING.md` - حل المشاكل الشائعة
- `HOW_TO_RUN_VS.md` - كيفية تشغيل Web API من Visual Studio
