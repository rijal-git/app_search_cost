# Google Sign-In Configuration Guide

## Problem: ApiException Error Code 10

**Error Message:**
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:, null, null)
```

**Cause:**
Error code 10 = `DEVELOPER_ERROR` - SHA-1 fingerprint tidak match antara APK dan Firebase Console

---

## Solution: Register SHA-1 Fingerprint

### Step 1: Get Debug SHA-1 Fingerprint

Run this command in Terminal:

```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 under `debugAndroidTest` or `debug` variant. Example output:
```
SHA-1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

### Step 2: Get Release SHA-1 Fingerprint

For release APK, you need the release keystore. If you don't have one:

```bash
cd android/app
keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

Then get SHA-1:
```bash
keytool -list -v -keystore android/app/release.keystore -alias release
```

### Step 3: Register in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `app-cost-deff0`
3. Go to **Project Settings** → **Your Apps**
4. Select Android app
5. Under "SHA certificate fingerprints", click **Add fingerprint**
6. Paste both SHA-1:
   - Debug SHA-1
   - Release SHA-1

### Step 4: Download Updated google-services.json

1. Click **Download google-services.json**
2. Replace `android/app/google-services.json` with new file
3. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release --split-per-abi
   ```

---

## Alternative: Enable Google Sign-In in Firebase

1. Go to Firebase Console
2. Select project
3. Go to **Authentication**
4. Click **Sign-in method** tab
5. Enable **Google** provider
6. Add OAuth 2.0 credentials (if not already added)

---

## Testing

After registration, test with:

```dart
// Test in debug
final user = await AuthService().signInWithGoogle();
print("Success: ${user?.email}");
```

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| `NETWORK_ERROR` | Check internet connection |
| `INTERNAL_ERROR` | Clear app data & cache |
| `SIGN_IN_FAILED` (10) | Register SHA-1 fingerprint |
| `API_NOT_AVAILABLE` | Enable Google API in Firebase |

---

## Current Project Info

**Firebase Project:** `app-cost-deff0`
**Package Name:** `com.example.app_search_cost`
**Current Certificate Hash:** `fc911ba2f6cde63562f726f722825e05020c4752`

For more info: https://firebase.google.com/docs/auth/android/start
