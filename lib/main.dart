import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models/expense_data.dart';
import 'models/user_settings.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/expense_plan_screen.dart';
import 'screens/expense_log_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/receipt_scanner_screen.dart';
import 'theme/app_theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Dubai'));

  // Initialize notifications
  await NotificationService.init(flutterLocalNotificationsPlugin);

  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.init();

  // Load user settings
  final settings = UserSettings();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseData(databaseService)),
        ChangeNotifierProvider(create: (_) => settings),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSettings>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Expense Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          routes: {
            '/expense-plan': (context) => const ExpensePlanScreen(),
            '/expense-log': (context) => const ExpenseLogScreen(),
            '/reports': (context) => const ReportsScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/receipt-scanner': (context) => const ReceiptScannerScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}