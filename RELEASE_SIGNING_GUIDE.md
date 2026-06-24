# PennyPilot Release Signing Guide

## Overview
This guide explains how to properly sign your APK/AAB for Google Play Store release.

## What Was Done ✅

### 1. Generated Release Keystore
- **File**: `android/app/release.keystore`
- **Alias**: `pennypilot-key`
- **Validity**: 10,000 days (approximately 27 years)
- **Algorithm**: RSA 2048-bit
- **Certificate Details**: CN=PennyPilot, Organization=PennyPilot, Location=Pakistan, State=Sindh, Country=PK

### 2. Updated build.gradle.kts
The Android build configuration has been updated with release signing config:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = "pennypilot-key"
        keyPassword = "pennypilot123"
        storeFile = file("release.keystore")
        storePassword = "pennypilot123"
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

## Build Commands

### Build AAB (Android App Bundle) for Play Store
```bash
cd D:\Flutter Projects\pennypilot
flutter build appbundle --release
```

**Output Location**: `build/app/outputs/bundle/release/app-release.aab`

### Build APK for Testing
```bash
cd D:\Flutter Projects\pennypilot
flutter build apk --release
```

**Output Location**: `build/app/outputs/apk/release/app-release.apk`

## Verify Release Signing

### Check APK Signature
```bash
jarsigner -verify -verbose -certs build\app\outputs\apk\release\app-release.apk
```

### Expected Output
You should see:
```
jar verified.
```

### Check Certificate Details
```bash
keytool -list -v -keystore android\app\release.keystore -alias pennypilot-key -storepass pennypilot123
```

## Important: Keystore Security

⚠️ **CRITICAL**: Keep your `release.keystore` file and password safe!
- **File Location**: `android/app/release.keystore`
- **Store Password**: `pennypilot123`
- **Key Alias**: `pennypilot-key`
- **Key Password**: `pennypilot123`

### Best Practices:
1. **Backup your keystore** - Store a copy in a secure location
2. **Never commit to Git** - Add `android/app/release.keystore` to `.gitignore`
3. **Keep password safe** - Don't share the keystore or password with unauthorized people
4. **Production apps** - Use strong, unique passwords (current one is for development)

### Add to .gitignore (if not already)
```
android/app/release.keystore
```

## Upload to Play Store

### Step 1: Build Release AAB
```bash
flutter build appbundle --release
```

### Step 2: Sign is Automatic
The build system automatically signs the AAB with the release keystore configured in `build.gradle.kts`.

### Step 3: Upload to Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app (PennyPilot)
3. Navigate to **Release → Production**
4. Click **"Create New Release"**
5. Upload the AAB file from `build/app/outputs/bundle/release/app-release.aab`
6. Fill in release notes and click **"Review release"**
7. Approve and release

## Troubleshooting

### Error: "Unsigned APK or AAB"
- **Solution**: Ensure `release.keystore` exists in `android/app/`
- **Verify**: `Get-ChildItem android/app/release.keystore`

### Error: "Wrong Password"
- **Solution**: Double-check the keystore and key passwords match in `build.gradle.kts`
- **Current Passwords**: Both are `pennypilot123`

### Error: "Cannot find release.keystore"
- **Solution**: Regenerate keystore
```bash
cd D:\Flutter Projects\pennypilot\android\app
keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias pennypilot-key -storepass pennypilot123 -keypass pennypilot123 -dname "CN=PennyPilot,O=PennyPilot,L=Pakistan,S=Sindh,C=PK"
```

### Build Fails During Signing
- Ensure `release.keystore` file is readable
- Check file permissions
- Verify file size is not 0 bytes

## App Details for Play Store

- **Package Name**: `com.examplee.pennypilot`
- **App Name**: PennyPilot
- **Min SDK**: As configured in Flutter
- **Target SDK**: As configured in Flutter

## Version Information

When uploading a new version:
1. Update `version` in `pubspec.yaml` (e.g., `1.0.1+2`)
2. Rebuild AAB: `flutter build appbundle --release`
3. Upload to Play Store
4. Increment version code (the `+2` part) for each release

## Next Steps

- [ ] Build AAB: `flutter build appbundle --release`
- [ ] Verify signing works (check output)
- [ ] Upload to Play Store Console
- [ ] Fill in app description, screenshots, and permissions
- [ ] Submit for review

---

**Last Updated**: June 23, 2026
**Status**: Release signing configured and ready ✅

