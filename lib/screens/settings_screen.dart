import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/user_settings.dart';
import '../models/expense_data.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserSettings, ExpenseData>(
      builder: (context, settings, expenseData, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: settings.isDarkMode,
                    onChanged: (value) => settings.setDarkMode(value),
                    secondary: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: AppTheme.primaryColor),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Currency'),
                    subtitle: Text(settings.currency),
                    leading: const Icon(Icons.currency_exchange, color: AppTheme.primaryColor),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showCurrencyPicker(context, settings),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Budget Alerts'),
                    subtitle: const Text('Get notified when approaching budget limits'),
                    value: settings.budgetAlertsEnabled,
                    onChanged: (value) => settings.setBudgetAlerts(value),
                    secondary: const Icon(Icons.notifications_active, color: AppTheme.primaryColor),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Daily Reminder Time'),
                    subtitle: Text('${settings.notificationTime.format(context)}'),
                    leading: const Icon(Icons.schedule, color: AppTheme.primaryColor),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _pickNotificationTime(context, settings),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Data Section
            _buildSectionHeader('Data Management'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Export to Excel'),
                    subtitle: const Text('Download all data as Excel file'),
                    leading: const Icon(Icons.download, color: AppTheme.primaryColor),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _exportToExcel(context, expenseData, settings.currency),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Export to PDF Report'),
                    subtitle: const Text('Generate monthly PDF report'),
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _exportToPDF(context, expenseData, settings.currency),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Backup to Cloud'),
                    subtitle: const Text('Sync data with Firebase'),
                    leading: const Icon(Icons.cloud_upload, color: AppTheme.primaryColor),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _backupToCloud(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Clear All Data'),
                    subtitle: const Text('Reset app to initial state'),
                    leading: const Icon(Icons.delete_forever, color: AppTheme.dangerColor),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _confirmClearData(context, expenseData),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Monthly Rollover Section
            _buildSectionHeader('Monthly Rollover'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start a new month',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will:\n'
                      '• Move current card outstanding to previous\n'
                      '• Move bill balances to total amount\n'
                      '• Clear expense log\n'
                      '• Keep daily expense budgets',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmRollover(context, expenseData),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Roll to Next Month'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                    leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Built with Flutter'),
                    subtitle: const Text('Cross-platform expense tracker'),
                    leading: const Icon(Icons.flutter_dash, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, UserSettings settings) {
    const currencies = ['AED', 'USD', 'EUR', 'GBP', 'INR', 'SAR', 'QAR', 'KWD', 'BHD', 'OMR'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              return ListTile(
                title: Text(currency),
                selected: currency == settings.currency,
                onTap: () {
                  settings.setCurrency(currency);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickNotificationTime(BuildContext context, UserSettings settings) async {
    final time = await showTimePicker(
      context: context,
      initialTime: settings.notificationTime,
    );
    if (time != null) {
      await settings.setNotificationTime(time);
      // Reschedule notifications
      await NotificationService.cancelAll();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification time set to ${time.format(context)}')),
      );
    }
  }

  void _exportToExcel(BuildContext context, ExpenseData expenseData, String currency) async {
    try {
      await ExportService.exportToExcel(expenseData, currency);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported to Excel successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: AppTheme.dangerColor),
      );
    }
  }

  void _exportToPDF(BuildContext context, ExpenseData expenseData, String currency) async {
    try {
      await ExportService.exportToPDF(expenseData, currency);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported to PDF successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e'), backgroundColor: AppTheme.dangerColor),
      );
    }
  }

  void _backupToCloud(BuildContext context) async {
    try {
      final firebaseService = FirebaseService();
      // Try anonymous sign in if not signed in
      if (firebaseService.currentUser == null) {
        await firebaseService.signInAnonymously();
      }
      await firebaseService.backupData(context.read<ExpenseData>());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backed up to cloud successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e'), backgroundColor: AppTheme.dangerColor),
      );
    }
  }

  void _confirmClearData(BuildContext context, ExpenseData expenseData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all your expenses, credit cards, bills, and settings. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              // Clear database
              await expenseData._db.close();
              // Re-initialize
              await expenseData._db.init();
              // Reload with defaults
              await expenseData._loadData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _confirmRollover(BuildContext context, ExpenseData expenseData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Roll to Next Month?'),
        content: const Text('This will:\n• Move current card outstanding to previous\n• Move bill balances to total amount\n• Clear expense log\n• Keep daily expense budgets'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              expenseData.rollToNextMonth();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rolled to next month')),
              );
            },
            child: const Text('Roll Over'),
          ),
        ],
      ),
    );
  }
}