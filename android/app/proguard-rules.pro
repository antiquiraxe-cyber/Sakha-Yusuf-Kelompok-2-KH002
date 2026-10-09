# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keepattributes *Annotation*

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Model Classes (keep for JSON serialization)
-keep class com.langkahawal.app.data.model.** { *; }
-keepclassmembers class com.langkahawal.app.data.model.** { *; }

# General optimization
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Security: Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
