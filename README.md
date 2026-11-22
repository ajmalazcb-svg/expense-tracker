# Expense Tracker - Flutter App

A comprehensive expense tracker app built with Flutter, based on your Monthly Expense Plan Excel sheet.

## Features

### Core Features (from Excel)
- **Monthly Income Tracking** - Salary + Other Income
- **Credit Card Management** - 6 cards (DIB 1, DIB 2, Ajman Bank, NBF, FAB, Citi)
  - Previous Outstanding, New Spending, Payments
  - Current Outstanding = Previous + New - Payment
  - Minimum Due & Total Due from bank statements
- **Rent & Monthly Bills** - Room Rent, Tabby, BOTIM, Cash Now, Office
  - Balance = Total Amount - Paid
- **Daily Expenses Budget** - Petrol, Grocery, Outside Food, Others
  - Left = Set Aside - Spent (auto-calculated from Expense Log)
- **Monthly Summary** - All automatic calculations

### Mobile-Enhanced Features
- **Quick Daily Entry** - Add expenses in 10 seconds via bottom sheet
- **Receipt Scanner (OCR)** - Camera/gallery scan with ML Kit text recognition
  - Auto-extracts amount, merchant, date, category
- **Charts & Reports** - Visual spending analysis
  - Income vs Expenses bar chart
  - Credit card outstanding pie chart
  - Rent/bills breakdown
  - Daily spending trend line chart
  - Category spending pie chart
- **Budget Alerts** - Notifications at 75%, 90%, 100% of budget
- **Cloud Sync Ready** - Firebase integration (Firestore + Auth)
- **Export** - Excel & PDF export (framework ready)
- **Dark Mode** - Full theme support
- **Multi-currency** - AED, USD, EUR, GBP, INR, etc.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── expense_data.dart     # All data models & business logic
│   └── user_settings.dart    # User preferences
├── services/
│   ├── database_service.dart # SQLite local storage
│   └── notification_service.dart # Local notifications
├── theme/
│   └── app_theme.dart        # Light/dark themes
└── screens/
    ├── home_screen.dart      # Dashboard + navigation
    ├── expense_plan_screen.dart # Income, Cards, Bills, Daily Budget tabs
    ├── expense_log_screen.dart  # Expense log with filters
    ├── reports_screen.dart   # Charts & analytics
    ├── settings_screen.dart  # App settings
    └── receipt_scanner_screen.dart # OCR receipt scanning
```

## Getting Started

### Prerequisites
- Flutter SDK 3.2.0+
- Android Studio / VS Code
- Android SDK (for Android) or Xcode (for iOS)

### Installation

```bash
cd expense_tracker
flutter pub get
flutter run
```

### Firebase Setup (for cloud sync)
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package `com.example.expense_tracker`
3. Add iOS app with bundle ID `com.example.expenseTracker`
4. Download `google-services.json` → `android/app/`
5. Download `GoogleService-Info.plist` → `ios/Runner/`
6. Enable Authentication (Email/Password) and Firestore Database
7. Run `flutterfire configure` (optional, for auto-config)

## Key Calculations (matching Excel)

| Field | Formula |
|-------|---------|
| Current Outstanding | Previous + New Spending - Payment |
| Bill Balance | Total Amount - Paid |
| Daily Left | Budget - Spent (from Expense Log) |
| Total Available | Salary + Other Income |
| Total Monthly Payments | Card Payments + Bills Paid |
| Remaining After Payments | Total Available - Total Monthly Payments |
| Cash Left After Daily | Remaining After Payments - Daily Budget |
| Total Outstanding | Card Outstanding + Bill Balances |

## Default Data (from your Excel)

**Credit Cards:**
- DIB 1: 12,000 prev, 2,169.94 min due
- DIB 2: 12,000 prev, 1,378.58 min due
- Ajman Bank: 11,000 prev, 3,307.67 min due
- NBF: 5,000 prev, 1,148.83 min due
- FAB: 6,500 prev, 572.84 min due
- Citi: 17,000 prev, 1,576.37 min due

**Rent & Bills:**
- Room Rent: 2,100 payable
- Tabby: 1,500 payable (5,000 total)
- BOTIM: 1,218.44 payable (4,000 total)
- Cash Now: 1,733.33 payable (10,425.56 total, 3,492.24 paid)
- Office: 1,000 payable (10,000 total)

**Daily Budget:**
- Petrol: 400
- Grocery: 500
- Outside Food: 150
- Others: 200 (Baby Toys)

**Income:** 7,500 AED salary

## Monthly Rollover

Tap "Roll to Next Month" in Settings or Dashboard to:
1. Move current card outstanding → previous outstanding
2. Clear new spending & payments
3. Move bill balances → total amount, clear paid
4. Clear expense log
5. Keep daily budgets

## Notifications

Budget alerts trigger at:
- 75% - Info notification
- 90% - Warning notification
- 100% - Critical notification

Daily reminder at configurable time (default 8 PM).

## OCR Receipt Scanning

Uses Google ML Kit Text Recognition:
1. Tap "Scan Receipt" → Camera or Gallery
2. Auto-extracts: Amount, Merchant, Date
3. Guesses category from merchant name
4. Review & save as expense entry

Supported merchants for auto-category:
- **Petrol**: ADNOC, ENOC, Emarat, petrol, fuel, gas
- **Grocery**: Lulu, Carrefour, Spinneys, Waitrose, Choithrams, supermarket, grocery
- **Outside Food**: KFC, McDonald's, Subway, Pizza, Burger, Starbucks, Costa, restaurant, cafe

## Export (Coming Soon)

- Excel export with all sheets (Plan + Log)
- PDF monthly report with charts
- Cloud backup to Firebase

## License

MIT License - Feel free to use and modify.