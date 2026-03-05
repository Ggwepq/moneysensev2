import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneysensev2/features/scanner/domain/entities/scanner_state.dart';
import 'package:moneysensev2/features/scanner/presentation/providers/scanner_provider.dart';

void main() {
  group('ScannerNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is idle', () {
      final state = container.read(scannerStateProvider);
      expect(state, ScannerState.idle);
    });

    test('openCamera changes state to previewing', () {
      container.read(scannerStateProvider.notifier).openCamera();
      expect(container.read(scannerStateProvider), ScannerState.previewing);
    });

    test('closeCamera changes state to idle', () {
      // First open to change state
      container.read(scannerStateProvider.notifier).openCamera();
      expect(container.read(scannerStateProvider), ScannerState.previewing);
      
      container.read(scannerStateProvider.notifier).closeCamera();
      expect(container.read(scannerStateProvider), ScannerState.idle);
    });

    test('startScanning changes state to scanning', () {
      container.read(scannerStateProvider.notifier).startScanning();
      expect(container.read(scannerStateProvider), ScannerState.scanning);
    });

    test('startProcessing changes state to processing', () {
      container.read(scannerStateProvider.notifier).startProcessing();
      expect(container.read(scannerStateProvider), ScannerState.processing);
    });

    test('showResult changes state to result', () {
      container.read(scannerStateProvider.notifier).showResult();
      expect(container.read(scannerStateProvider), ScannerState.result);
    });

    test('reset changes state to previewing', () {
      container.read(scannerStateProvider.notifier).showResult();
      container.read(scannerStateProvider.notifier).reset();
      expect(container.read(scannerStateProvider), ScannerState.previewing);
    });
  });
}
