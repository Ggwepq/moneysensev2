import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneysensev2/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('supports value equality', () {
      expect(
        const AppSettings(),
        const AppSettings(),
      );
    });

    test('props are correct for default values', () {
      const settings = AppSettings();
      expect(settings.themeMode, AppThemeMode.system);
      expect(settings.language, AppLanguage.english);
      expect(settings.fontScale, 1.0);
      expect(settings.useFrontCamera, false);
      expect(settings.useFlashlight, false);
      expect(settings.denominationVibration, true);
      expect(settings.shakeToGoBack, true);
      expect(settings.goBackTimerSeconds, 20);
      expect(settings.gesturalNavigation, true);
      expect(settings.inertialNavigation, true);
      expect(settings.visionProfile, VisionProfile.lowVision);
      expect(settings.ttsEnabled, true);
      expect(settings.hapticFeedback, true);
    });

    test('copyWith updates fields correctly', () {
      const settings = AppSettings();
      final newSettings = settings.copyWith(
        themeMode: AppThemeMode.dark,
        language: AppLanguage.tagalog,
        fontScale: 1.5,
        useFrontCamera: true,
        useFlashlight: true,
        denominationVibration: false,
        shakeToGoBack: false,
        goBackTimerSeconds: 10,
        gesturalNavigation: false,
        inertialNavigation: false,
        visionProfile: VisionProfile.fullyBlind,
        ttsEnabled: false,
        hapticFeedback: false,
      );

      expect(newSettings.themeMode, AppThemeMode.dark);
      expect(newSettings.language, AppLanguage.tagalog);
      expect(newSettings.fontScale, 1.5);
      expect(newSettings.useFrontCamera, true);
      expect(newSettings.useFlashlight, true);
      expect(newSettings.denominationVibration, false);
      expect(newSettings.shakeToGoBack, false);
      expect(newSettings.goBackTimerSeconds, 10);
      expect(newSettings.gesturalNavigation, false);
      expect(newSettings.inertialNavigation, false);
      expect(newSettings.visionProfile, VisionProfile.fullyBlind);
      expect(newSettings.ttsEnabled, false);
      expect(newSettings.hapticFeedback, false);
    });

    test('flutterThemeMode returns correct ThemeMode', () {
      expect(
        const AppSettings(themeMode: AppThemeMode.light).flutterThemeMode,
        ThemeMode.light,
      );
      expect(
        const AppSettings(themeMode: AppThemeMode.dark).flutterThemeMode,
        ThemeMode.dark,
      );
      expect(
        const AppSettings(themeMode: AppThemeMode.system).flutterThemeMode,
        ThemeMode.system,
      );
    });

    test('isTagalog returns correct boolean', () {
      expect(
        const AppSettings(language: AppLanguage.tagalog).isTagalog,
        true,
      );
      expect(
        const AppSettings(language: AppLanguage.english).isTagalog,
        false,
      );
    });
  });
}
