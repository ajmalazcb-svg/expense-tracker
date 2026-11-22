# GitHub Actions APK Build Setup

This repository includes a GitHub Actions workflow that automatically builds release APKs and App Bundles.

## How to Get Your APK

### Option 1: Automatic on Push
1. Create a GitHub repository
2. Push this code to the `main` branch
3. Go to **Actions** tab in GitHub
4. Wait for "Build Release APK" workflow to complete
5. Click the workflow run → **Artifacts** → Download `release-apks.zip`

### Option 2: Manual Trigger
1. Go to **Actions** tab
2. Select "Build Release APK" workflow
3. Click **Run workflow** → **Run workflow**
4. Download artifact when complete

### Option 3: Create a Release (Auto-uploads to GitHub Releases)
```bash
git tag v1.0.0
git push origin v1.0.0
```
This creates a GitHub Release with APKs attached.

## What You Get

The workflow produces:
- **`app-arm64-v8a-release.apk`** - For modern 64-bit ARM devices (most phones)
- **`app-armeabi-v7a-release.apk`** - For older 32-bit ARM devices
- **`app-x86_64-release.apk`** - For emulators/x86 devices
- **`app-release.aab`** - App Bundle for Google Play Store

**Install the `arm64-v8a` APK on your phone.**

## First-Time Setup

### 1. Create GitHub Repo
```bash
cd expense_tracker
git init
git add .
git commit -m "Initial commit"
gh repo create expense-tracker --public --source=. --push
```

### 2. Enable Actions
- Go to repo **Settings** → **Actions** → **General**
- Enable "Allow all actions and reusable workflows"
- Save

### 3. (Optional) For Signed APKs
Add these secrets in **Settings** → **Secrets and variables** → **Actions**:
- `KEYSTORE_BASE64` - Base64 encoded keystore file
- `KEYSTORE_PASSWORD` - Keystore password
- `KEY_ALIAS` - Key alias
- `KEY_PASSWORD` - Key password

Then uncomment the signing section in `build-apk.yml`.

## Troubleshooting

**Build fails?**
- Check the Actions log for errors
- Common: Run `flutter pub get` locally first, commit `pubspec.lock`

**APK too large?**
- The `--split-per-abi` flag creates smaller per-architecture APKs
- Total size ~15-20MB per APK

**Need older Flutter version?**
- Change `flutter-version` in workflow (e.g., `'3.19.0'`)

## Local Build (Alternative)
```bash
cd expense_tracker
flutter pub get
flutter build apk --release --split-per-abi
# APKs in build/app/outputs/flutter-apk/
```