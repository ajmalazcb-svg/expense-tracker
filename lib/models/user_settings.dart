import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings extends ChangeNotifier {
  static const _darkModeKey = 'dark_mode';
  static const _currencyKey = 'currency';
  static const _budgetAlertsKey = 'budget_alerts';
  static const _notificationTimeKey = 'notification_time';

  bool _isDarkMode = false;
  String _currency = 'AED';
  bool _budgetAlertsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0); // 8 PM

  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  TimeOfDay get notificationTime => _notificationTime;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _currency = prefs.getString(_currencyKey) ?? 'AED';
    _budgetAlertsEnabled = prefs.getBool(_budgetAlertsKey) ?? true;
    final hour = prefs.getInt('${_notificationTimeKey}_hour') ?? 20;
    final minute = prefs.getInt('${_notificationTimeKey}_minute') ?? 0;
    _notificationTime = TimeOfDay(hour: hour, minute: minute);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
    notifyListeners();
  }

  Future<void> setBudgetAlerts(bool enabled) async {
    _budgetAlertsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_budgetAlertsKey, enabled);
    notifyListeners();
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    _notificationTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_notificationTimeKey}_hour', time.hour);
    await prefs.setInt('${_notificationTimeKey}_minute', time.minute);
    notifyListeners();
  }
}