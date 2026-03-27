# Conservative app-level R8 rules for the first Play release.
# Most Firebase and Google Play services libraries already ship their own
# consumer rules, so this file stays intentionally small.

# Keep source and line information so Crashlytics reports remain readable
# after minification.
-keepattributes SourceFile,LineNumberTable

# Preserve classes exposed to WebView JavaScript bridges.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
