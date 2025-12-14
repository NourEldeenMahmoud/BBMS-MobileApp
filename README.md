# BBMS Mobile App

Blood Bank Management System - Mobile Application built with Flutter.

## Features

- **Authentication**: Login with phone number and password
- **Home Screen**: View statistics, upcoming appointments, and quick actions
- **Book Appointment**: Schedule new blood donation appointments
- **My Appointments**: View and manage upcoming and past appointments
- **Profile**: View personal details and donation statistics
- **Donation History**: View complete donation history with statistics
- **Notifications**: View and manage notifications

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Demo Credentials

- **Phone Number**: `1234567890`
- **Password**: `123456`

## Project Structure

```
lib/
├── config/          # Theme configuration
├── models/          # Data models
├── services/        # API and storage services
├── providers/       # State management (Provider)
├── utils/           # Utility classes
├── widgets/         # Reusable widgets
├── screens/         # App screens
└── routes/          # Navigation routes
```

## State Management

This app uses **Provider** for state management. All providers are located in `lib/providers/`.

## API Integration

Currently using `MockApiService` for development. To switch to real API:

1. Update `lib/services/api_service.dart` with your API endpoints
2. Replace `MockApiService` with `ApiService` in all providers
3. Update `baseUrl` in `api_service.dart` with your server IP/URL

## Dependencies

- `provider`: State management
- `shared_preferences`: Local storage
- `intl`: Date formatting
- `http`: HTTP requests
- `google_fonts`: Custom fonts (Lexend)
- `table_calendar`: Calendar widget

## Notes

- The app uses Mock Data for testing
- All API calls are abstracted and ready for real API integration
- Theme supports both light and dark modes
- Responsive design for different screen sizes
