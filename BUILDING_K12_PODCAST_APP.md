# Building a K12 Podcast App with Google Sign-In and Firebase in Flutter

This guide details the steps required to integrate Google Sign-In into a Flutter application and extend it to build a podcast app for K12 students using Firebase Authentication and Firestore.

## 1. Prerequisites

*   **Flutter SDK:** Ensure Flutter is installed and the `flutter/bin` directory is added to your system's PATH environment variable.
    *   Verify installation by running `flutter doctor` in your terminal. If the command is not found, check your PATH configuration and restart your terminal/IDE.

## 2. Create Flutter Project

```bash
flutter create your_project_name
cd your_project_name
```

## 3. Firebase Project Setup

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Click "Add project" and follow the steps to create a new Firebase project.

## 4. Add Firebase to Flutter Project

1.  **Install FlutterFire CLI (if not already installed):**
    ```bash
    dart pub global activate flutterfire_cli
    ```
    *   *Troubleshooting:* If `flutterfire` command is not found later, ensure the Dart global path is added to your system's PATH.

2.  **Login to Firebase CLI:**
    ```bash
    firebase login
    ```
    *   This will open a browser window for authentication.
    *   *Troubleshooting:* If `flutterfire configure` fails to find projects later, ensure you are logged in.

3.  **Configure Firebase for Flutter:**
    *   Navigate to your Flutter project directory in the terminal.
    *   Run the configuration command:
        ```bash
        flutterfire configure
        ```
    *   Follow the prompts:
        *   Select the Firebase project you created.
        *   Select the platforms to configure (e.g., `android`, `web`). Use arrow keys and spacebar to select/deselect.
        *   Confirm overwriting `lib/firebase_options.dart` if it exists.
    *   This command generates/updates the `lib/firebase_options.dart` file with your project's Firebase configuration keys for the selected platforms.

4.  **Platform-Specific Setup:**
    *   **Android:**
        1.  Go to Firebase Console -> Project Settings (gear icon) -> General tab.
        2.  Scroll down to "Your apps".
        3.  If you haven't registered an Android app during `flutterfire configure`, click "Add app" and select Android. Follow the instructions.
        4.  Download the `google-services.json` file.
        5.  Place the downloaded `google-services.json` file in the `android/app/` directory of your Flutter project.
        6.  **Generate and Add SHA-1 Key:**
            *   Generate the SHA-1 key for your Android app using the following command:
                ```bash
                keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
                ```
            *   If your keystore file is not located in the default location, you can find it by checking your Android Studio settings (File > Settings > Build, Execution, Deployment > Build Tools > Gradle).
            *   The default password for the debug keystore is `android`.
            *   Copy the SHA-1 key from the output.
            *   Add the SHA-1 key to your Firebase project in the Firebase console (Project settings > General > Your apps > Android app > SHA certificate fingerprints).
    *   **iOS (Optional but Recommended):**
        1.  Go to Firebase Console -> Project Settings (gear icon) -> General tab.
        2.  If you haven't registered an iOS app during `flutterfire configure`, click "Add app" and select iOS. Follow the instructions.
        3.  Download the `GoogleService-Info.plist` file.
        4.  Place the downloaded `GoogleService-Info.plist` file in the `ios/Runner/` directory of your Flutter project (using Xcode is recommended for proper integration).

## 5. Add Dependencies

1.  Open the `pubspec.yaml` file in your Flutter project.
2.  Add the following packages under the `dependencies:` section:

    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      # ... other dependencies
      cupertino_icons: ^1.0.8
      firebase_core: ^3.13.0  # Or latest compatible
      firebase_auth: ^5.5.2  # Or latest compatible
      google_sign_in: ^6.3.0 # Or latest compatible
      cloud_firestore: ^5.0.0 # Added for Firestore database
      audioplayers: ^5.2.1 # Add audio player
    ```
3.  Save the `pubspec.yaml` file.
4.  Run `flutter pub get` in your terminal within the project directory.
    *   *Troubleshooting:* If you encounter dependency conflicts, try adjusting version constraints or running `flutter pub upgrade`.

## 6. Implement Flutter Code

1.  **Initialize Firebase:** Modify your `lib/main.dart` file to initialize Firebase before running the app:

    ```dart
    import 'package:flutter/material.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'firebase_options.dart'; // Import generated options

    void main() async { // Make main async
      WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform, // Use generated options
      );
      runApp(const MyApp());
    }
    ```

2.  **Google Sign-In and User Details Collection:**

    *   After successful Google Sign-In, collect the user's name and grade.
    *   Store this information (along with other user details) in a "users" collection in Firestore.
    *   The code navigates to `UserDetailsForm` to collect this information.

3.  **Data Flow and UI Structure:**

    *   **Grade Display:** After submitting user details, display the selected grade with a graduation hat icon.
    *   **Subjects List:** Tapping the grade icon navigates to a `SubjectListScreen`, displaying available subjects as icons in a `GridView`.
    *   **Units List:** Tapping a subject navigates to a `UnitListScreen`, displaying units for that subject as icons in a `GridView`.
    *   **Chapters List:** Tapping a unit navigates to a `ChapterListScreen`, displaying chapters for that unit in a `ListView`.
    *   **Podcast List:** Tapping a chapter navigates to a `PodcastListScreen`, displaying podcasts for that chapter in a `ListView`.
    *   **Podcast Playback:** Tapping a podcast item initiates audio playback using the `audioplayers` package.

## 7. Firestore Security Rules

Configure Firestore security rules to protect your data. The following rules allow authenticated users to:

*   Read and write their own document in the `users` collection.
*   Read data from the `grades`, `subjects`, `units`, and `chapters` collections.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Allow any authenticated user to READ from the grades collection
    match /grades/{gradeId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    // Allow any authenticated user to READ from the subjects collection
    match /subjects/{subjectId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    // Allow any authenticated user to READ from the units collection
    match /units/{unitId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    // Allow any authenticated user to READ from the chapters collection
    match /chapters/{chapterId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
        // Allow any authenticated user to READ from the podcasts collection
    match /podcasts/{podcastId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

## 8. Google Cloud Console Configuration (Crucial for Web)

These steps configure the OAuth Client ID used by Google Sign-In on the web.

1.  **Navigate to Credentials:**
    *   Go to the [Google Cloud Console APIs & Services Credentials page](https://console.cloud.google.com/apis/credentials).
    *   Ensure the correct Google Cloud project (associated with your Firebase project) is selected at the top.

2.  **Find/Verify Web Client ID:**
    *   Look under the **"OAuth 2.0 Client IDs"** section.
    *   You should see a client ID of type "Web application". This ID is automatically created when you enable Google Sign-In in Firebase or add a web app to Firebase.
    *   Copy this **Client ID** (it ends with `.apps.googleusercontent.com`).

3.  **Add Meta Tag to `index.html`:**
    *   Open the `web/index.html` file in your Flutter project.
    *   Inside the `<head>` section, add the following meta tag, replacing `YOUR_WEB_CLIENT_ID` with the ID you just copied:
        ```html
        <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">
        ```

4.  **Configure Authorized JavaScript Origins:**
    *   On the Google Cloud Console Credentials page, click the **Name** of your Web application Client ID to edit it.
    *   Scroll down to the **"Authorized JavaScript origins"** section.
    *   Click **"+ ADD URI"**.
    *   Add `http://localhost`. (Flutter web uses random ports during development, but authorizing `http://localhost` should cover them).
    *   *Troubleshooting:* If you still face origin errors after authorizing `http://localhost`, try clearing your browser cache or adding the specific `http://localhost:PORT` mentioned in the error message, though this shouldn't typically be necessary.
    *   Click **"Save"** at the bottom of the page.

5.  **Enable Required APIs:**
    *   Go to the [Google Cloud Console API Library](https://console.cloud.google.com/apis/library).
    *   Search for and ensure the following APIs are **Enabled** for your project:
        *   **Identity Toolkit API** (Usually enabled automatically by Firebase Auth)
        *   **People API** (Often required by Google Sign-In to fetch profile info)
    *   *Troubleshooting:* If you get a `PERMISSION_DENIED` error related to an API (like People API) during sign-in, enable it here. It might take a few minutes to propagate after enabling.

## 9. Run and Test

1.  Connect a device or start an emulator/simulator.
2.  Run the app:
    ```bash
    # For Android/iOS
    flutter run

    # For Web (Chrome)
    flutter run -d chrome
    ```
4.  To create an APK for testing on an Android device, run the following command:
    ```bash
    flutter build apk
    ```
    The APK will be located in the `build/app/outputs/apk/release/app-release.apk` directory.
5.  Click the "Continue with Google" button and follow the sign-in flow.
6.  Check the debug console for any errors and verify successful navigation/authentication state change in your app.

This comprehensive guide should help set up Google Sign-In and build a K12 podcast app in future projects. Remember that package versions and cloud console layouts might change over time.
