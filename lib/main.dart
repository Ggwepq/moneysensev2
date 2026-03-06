import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/scanner/data/datasources/camera_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Discover cameras before the app starts so [availableCamerasProvider]
  // can be seeded. Falls back to an empty list on devices with no cameras
  // (e.g. some emulators) without crashing.
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (_) {
    // Camera permission not granted yet or no camera on device — the
    // scanner screen will show an appropriate error state.
  }

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
        // Seed the cameras list so CameraControllerNotifier can pick a lens.
        availableCamerasProvider.overrideWithValue(cameras),
      ],
      child: const MoneySenseApp(),
    ),
  );
}
