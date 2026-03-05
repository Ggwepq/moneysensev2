import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scanner_state.dart';

// ---------------------------------------------------------------------------
// Camera Open/Close state
// ---------------------------------------------------------------------------

final cameraOpenProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// Scanner State
// ---------------------------------------------------------------------------

final scannerStateProvider =
    NotifierProvider<ScannerNotifier, ScannerState>(ScannerNotifier.new);

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() => ScannerState.idle;

  void openCamera() => state = ScannerState.previewing;
  void closeCamera() => state = ScannerState.idle;
  void startScanning() => state = ScannerState.scanning;
  void startProcessing() => state = ScannerState.processing;
  void showResult() => state = ScannerState.result;
  void reset() => state = ScannerState.previewing;
}

// ---------------------------------------------------------------------------
// Detection Result
// ---------------------------------------------------------------------------

final detectionResultProvider = StateProvider<DetectionResult?>((ref) => null);
