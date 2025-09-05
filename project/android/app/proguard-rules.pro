# This file contains ProGuard rules for a Flutter application.
# It is used to define rules for code shrinking and obfuscation.

# Flutter specific rules.
# Keep the Flutter main activity to prevent it from being removed.
-keep class io.flutter.app.FlutterActivity
-keep class io.flutter.app.FlutterApplication
-keep class com.example.new_happiness_hub.MainActivity { *; }

# Keep all Firebase classes.
# The ** wildcard matches any package or subpackage.
-keep class com.google.firebase.** { *; }

# Keep all Google Mobile Services classes (required by Firebase).
-keep class com.google.android.gms.** { *; }

# Keep the Firebase platform info class.
-keep class com.google.firebase.platforminfo.FirebaseLibrary { *; }

# Keep the Signature attribute, which is required for some Firebase services.
-keepattributes Signature

# Rules for common libraries that may be used.
# You can uncomment these as needed based on your pubspec.yaml file.

# For flutter_local_notifications
#-keep class io.flutter.plugins.flutter_local_notifications.** { *; }
