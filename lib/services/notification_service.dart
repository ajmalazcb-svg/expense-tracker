import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/user_settings.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init(FlutterLocalNotificationsPlugin plugin) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await plugin.initialize(settings);
  }

  static Future<void> scheduleBudgetAlert({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required bool daily,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Notifications for budget limits',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: daily ? DateTimeComponents.time : null,
    );
  }

  static Future<void> cancelBudgetAlert(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_alerts',
          'Instant Alerts',
          channelDescription: 'Immediate budget notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> checkAndNotifyBudget(
    String category,
    double spent,
    double budget,
    UserSettings settings,
  ) async {
    if (!settings.budgetAlertsEnabled) return;
    if (budget <= 0) return;

    final percentage = (spent / budget) * 100;

    if (percentage >= 100) {
      await showInstantNotification(
        id: category.hashCode,
        title: 'Budget Exceeded: $category',
        body: 'You\'ve spent ${spent.toStringAsFixed(2)} ${settings.currency} '
            'out of ${budget.toStringAsFixed(2)} ${settings.currency} '
            '(${percentage.toStringAsFixed(0)}%)',
      );
    } else if (percentage >= 90) {
      await showInstantNotification(
        id: category.hashCode + 1000,
        title: 'Budget Warning: $category',
        body: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your '
            '${budget.toStringAsFixed(2)} ${settings.currency} budget',
      );
    } else if (percentage >= 75) {
      await showInstantNotification(
        id: category.hashCode + 2000,
        title: 'Budget Alert: $category',
        body: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your budget',
      );
    }
  }
}