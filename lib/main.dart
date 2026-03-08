import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/scanner/data/datasources/camera_service.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load SharedPreferences and cameras in parallel — both are needed before
  // the first frame, and running them concurrently shaves startup time.
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    availableCameras().catchError((_) => <CameraDescription>[]),
  ]);

  final prefs = results[0] as SharedPreferences;
  final cameras = results[1] as List<CameraDescription>;

  // Portrait-only — scanning works best in portrait.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Edge-to-edge display on Android.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // SharedPreferences — loaded once, used synchronously by SettingsStorage.
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Camera list — seeded so CameraControllerNotifier can pick a lens.
        availableCamerasProvider.overrideWithValue(cameras),
      ],
      child: const MoneySenseApp(),
    ),
  );
}
