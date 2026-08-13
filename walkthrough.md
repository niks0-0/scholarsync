# ScholarSync Phase 2 — Walkthrough

## What Was Built in Phase 2

Phase 2 implements the complete **Firebase Authentication** infrastructure and **Google Sign-In** flow.

---

## Key Achievements

1. **Firebase Project & App Setup**:
   - Created Firebase Project: `scholarsync-app-2026`
   - Registered Android App: `com.example.scholarsync.scholarsync`
   - Configured Android debug SHA-1 fingerprint (`53:55:B6:91:00:14:29:67:5B:73:4B:6B:62:10:2C:21:2F:A6:90:D2`)
   - Downloaded and placed `android/app/google-services.json`
   - Generated `lib/core/firebase/firebase_options.dart` via FlutterFire CLI
   - Configured `android/build.gradle.kts` and `android/app/build.gradle.kts` for `com.google.gms.google-services`

2. **Clean Domain & Data Layer Architecture**:
   - **`AuthUser`**: Clean domain representation of an authenticated user (`uid`, `email`, `displayName`, `photoUrl`, `isEmailVerified`, `initials`, `displayNameOrEmail`).
   - **`AuthFailure` / `AuthException`**: Typed error enum mapping raw `FirebaseAuthException` codes into clean UI messages.
   - **`AuthRepository`**: Domain interface defining authentication contracts.
   - **`FirebaseAuthService`**: Encapsulates raw `FirebaseAuth` and `GoogleSignIn` SDK calls. Handles ID token retrieval (`getIdToken(forceRefresh)`).
   - **`FirebaseAuthRepository`**: Implements `AuthRepository` by delegating to `FirebaseAuthService` and mapping SDK types to domain types.

3. **State Management & UI Integration**:
   - **`AuthProvider`**: Updated `ChangeNotifier` to subscribe to `authStateChanges` stream and expose `currentUser`, `status`, `isLoading`, and `error`.
   - **`main.dart`**: Initialized Firebase (`Firebase.initializeApp`) before running `ScholarSyncApp`.
   - **UI Screens**:
     - `LoginScreen`: Wired Google Sign-In button and Email/Password sign-in.
     - `RegisterScreen`: Wired Google Sign-In and Email/Password registration.
     - `SplashScreen`: Automatically restores session if user is already authenticated.
     - `PlaceholderScreen`: Displays authenticated user details and sign-out button.

---

## Google Sign-In Flow

```
User Taps "Continue with Google"
  ↓
AuthProvider.signInWithGoogle()
  ↓
FirebaseAuthRepository.signInWithGoogle()
  ↓
FirebaseAuthService.signInWithGoogle()
  ↓
GoogleSignIn.signIn() → GoogleCredential
  ↓
FirebaseAuth.signInWithCredential(credential) → User
  ↓
Mapped to AuthUser
  ↓
AuthProvider notifies listeners → Navigates to /home
```

---

## Verification

### Static Analysis
```bash
flutter analyze --no-pub
# Output: Analyzing ScholarSync... No issues found! (ran in 20.9s)
```

---

## Architecture Boundaries (Phase 2 Rule Compliance)

- ✅ No Firebase SDK types exposed to UI widgets.
- ✅ No Supabase Auth or database code introduced.
- ✅ Google credentials exchanged with Firebase Authentication ONLY.
- ✅ ID tokens available via `auth.getIdToken()` for future Phase 3 backend integration.
