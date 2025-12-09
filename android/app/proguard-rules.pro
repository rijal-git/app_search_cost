# Flutter
-keep class io.flutter.** { *; }

# Google Play Core (for split install)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ZXing / Barcode scanner
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**

# Firestore Models (PENTING)
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <fields>;
}
-keepattributes *Annotation*

# Gson (optional)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
