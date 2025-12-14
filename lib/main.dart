import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/appointments_provider.dart';
import 'providers/donations_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/book_appointment_screen.dart';
import 'screens/my_appointments_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/donation_history_screen.dart';
import 'screens/notifications_screen.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
        ChangeNotifierProvider(create: (_) => DonationsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'BBMS Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRouter.login,
        routes: {
          AppRouter.login: (context) => const LoginScreen(),
          AppRouter.register: (context) => const RegisterScreen(),
          AppRouter.home: (context) => const HomeScreen(),
          AppRouter.bookAppointment: (context) => const BookAppointmentScreen(),
          AppRouter.myAppointments: (context) => const MyAppointmentsScreen(),
          AppRouter.profile: (context) => const ProfileScreen(),
          AppRouter.editProfile: (context) => const EditProfileScreen(),
          AppRouter.donationHistory: (context) => const DonationHistoryScreen(),
          AppRouter.notifications: (context) => const NotificationsScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle any additional routes if needed
          return null;
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
