# Google ML Kit Text Recognition ProGuard Rules
# These rules prevent R8 from failing when it encounters references to 
# other ML Kit script recognizers (Chinese, Japanese, etc.) that aren't 
# included in our dependencies.

-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep rules for ML Kit to prevent over-aggressive minification
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
