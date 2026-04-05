import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../domain/entities/scanner_state.dart';

// ── Persistent Isolate messages ─────────────────────────────────────────────

abstract class _IsolateCommand {}

class _InitCommand extends _IsolateCommand {
  final Uint8List modelBytes;
  final int inputSize;
  final int numClasses;
  final double confThreshold;
  final SendPort replyPort;

  _InitCommand({
    required this.modelBytes,
    required this.inputSize,
    required this.numClasses,
    required this.confThreshold,
    required this.replyPort,
  });
}

class _InferCommand extends _IsolateCommand {
  final Uint8List yBytes, uBytes, vBytes;
  final int width, height;
  final int yRowStride, uRowStride, uPixStride, vRowStride, vPixStride;
  final SendPort replyPort;

  _InferCommand({
    required this.yBytes,
    required this.uBytes,
    required this.vBytes,
    required this.width,
    required this.height,
    required this.yRowStride,
    required this.uRowStride,
    required this.uPixStride,
    required this.vRowStride,
    required this.vPixStride,
    required this.replyPort,
  });
}

class _InferResult {
  final int classIdx;
  final double score;
  final String debugMsg;
  const _InferResult(this.classIdx, this.score, this.debugMsg);
}

// ── Isolate Entry Point ───────────────────────────────────────────────────

void _persistentIsolateEntry(SendPort setupPort) {
  final receivePort = ReceivePort();
  setupPort.send(receivePort.sendPort);

  Interpreter? interpreter;
  int inputSize = 640;
  int numClasses = 9;
  double confThreshold = 0.25;

  receivePort.listen((message) {
    if (message is _InitCommand) {
      try {
        interpreter = Interpreter.fromBuffer(
          message.modelBytes,
          options: InterpreterOptions()..threads = 1,
        );
        inputSize = message.inputSize;
        numClasses = message.numClasses;
        confThreshold = message.confThreshold;
        message.replyPort.send(true);
      } catch (e) {
        message.replyPort.send(false);
      }
    } else if (message is _InferCommand) {
      if (interpreter == null) {
        message.replyPort.send(const _InferResult(-1, 0, 'Interpreter not initialized'));
        return;
      }

      final buf = StringBuffer();
      try {
        buf.write('[isolate] YUV→RGBA. ');
        final rgba = _yuv420ToRgba(
          message.yBytes, message.uBytes, message.vBytes,
          message.width, message.height,
          message.yRowStride, message.uRowStride, message.uPixStride,
          message.vRowStride, message.vPixStride,
        );

        final tensor = Float32List(inputSize * inputSize * 3);
        final scaleX = message.width / inputSize;
        final scaleY = message.height / inputSize;

        for (int y = 0; y < inputSize; y++) {
          for (int x = 0; x < inputSize; x++) {
            final srcX = (x * scaleX).toInt().clamp(0, message.width - 1);
            final srcY = (y * scaleY).toInt().clamp(0, message.height - 1);
            final srcIdx = (srcY * message.width + srcX) * 4;
            final dstIdx = (y * inputSize + x) * 3;
            tensor[dstIdx] = rgba[srcIdx] / 255.0;
            tensor[dstIdx + 1] = rgba[srcIdx + 1] / 255.0;
            tensor[dstIdx + 2] = rgba[srcIdx + 2] / 255.0;
          }
        }

        final input = [
          List.generate(inputSize, (y) =>
            List.generate(inputSize, (x) => [
              tensor[(y * inputSize + x) * 3],
              tensor[(y * inputSize + x) * 3 + 1],
              tensor[(y * inputSize + x) * 3 + 2],
            ]),
          ),
        ];

        final outShape = interpreter!.getOutputTensor(0).shape;
        final output = List.generate(
          outShape[0],
          (_) => List.generate(
            outShape[1],
            (_) => List<double>.filled(outShape[2], 0.0),
          ),
        );

        interpreter!.run(input, output);

        final numAnchors = output[0][0].length;
        int bestCls = -1;
        double bestScore = confThreshold;
        double absMax = 0;

        for (int i = 0; i < numAnchors; i++) {
          for (int c = 0; c < numClasses; c++) {
            final score = output[0][4 + c][i];
            if (score > absMax) absMax = score;
            if (score > bestScore) {
              bestScore = score;
              bestCls = c;
            }
          }
        }

        buf.write('bestCls=$bestCls score=${bestScore.toStringAsFixed(3)} absMax=${absMax.toStringAsFixed(3)}');
        message.replyPort.send(_InferResult(bestCls, bestScore, buf.toString()));
      } catch (e, st) {
        message.replyPort.send(_InferResult(-1, 0, 'ERROR: $e\n$st'));
      }
    }
  });
}

Uint8List _yuv420ToRgba(
  Uint8List yB, Uint8List uB, Uint8List vB,
  int w, int h,
  int yRS, int uRS, int uPS, int vRS, int vPS,
) {
  final rgba = Uint8List(w * h * 4);
  for (int row = 0; row < h; row++) {
    for (int col = 0; col < w; col++) {
      final yIdx = row * yRS + col;
      final uvR  = row >> 1;
      final uvC  = col >> 1;
      final uIdx = uvR * uRS + uvC * uPS;
      final vIdx = uvR * vRS + uvC * vPS;

      final Y = yB[yIdx] & 0xFF;
      final U = (uB[uIdx] & 0xFF) - 128;
      final V = (vB[vIdx] & 0xFF) - 128;

      final r = (Y + 1.402    * V               ).clamp(0, 255).toInt();
      final g = (Y - 0.344136 * U - 0.714136 * V).clamp(0, 255).toInt();
      final b = (Y + 1.772    * U               ).clamp(0, 255).toInt();

      final p = (row * w + col) * 4;
      rgba[p]     = r;
      rgba[p + 1] = g;
      rgba[p + 2] = b;
      rgba[p + 3] = 255;
    }
  }
  return rgba;
}

// ── DetectionService ───────────────────────────────────────────────────────

class DetectionService {
  DetectionService._();
  static final DetectionService instance = DetectionService._();

  static const String _assetPath     = 'assets/models/moneysense-bills.tflite';
  static const int    _inputSize     = 640;
  static const double _confThreshold = 0.50;  // Raised to 0.5 to prevent noisy false positives
  static const int    _minIntervalMs = 500;

  static const List<String> _denominations = [
    '1', '5', '10', '20', '50', '100', '200', '500', '1000',
  ];
  static const List<String> _types = [
    'coin', 'coin', 'coin', 'coin',
    'bill', 'bill', 'bill', 'bill', 'bill',
  ];
  static const int _numClasses = 9;

  SendPort? _isolateCommandPort;
  ReceivePort? _isolateSetupPort;
  Isolate? _isolate;
  
  bool _isInit = false;
  bool _isRunning = false;
  int _lastInferMs = 0;
  int _frameCount = 0;
  int _inferCount = 0;

  bool get isReady => _isInit && _isolateCommandPort != null;

  Future<void> init() async {
    if (_isInit) return;
    try {
      debugPrint('[DetectionService] loading $_assetPath ...');
      final data = await rootBundle.load(_assetPath);
      final modelBytes = data.buffer.asUint8List();

      // Spin up the persistent isolate
      _isolateSetupPort = ReceivePort();
      _isolate = await Isolate.spawn(_persistentIsolateEntry, _isolateSetupPort!.sendPort);
      _isolateCommandPort = await _isolateSetupPort!.first as SendPort;

      // Initialize interpreter in isolate
      final initReplyPort = ReceivePort();
      _isolateCommandPort!.send(_InitCommand(
        modelBytes: modelBytes,
        inputSize: _inputSize,
        numClasses: _numClasses,
        confThreshold: _confThreshold,
        replyPort: initReplyPort.sendPort,
      ));

      final success = await initReplyPort.first as bool;
      initReplyPort.close();

      if (success) {
        _isInit = true;
        debugPrint('[DetectionService] ✓ persistent isolate ready.');
      } else {
        debugPrint('[DetectionService] ✗ persistent isolate init failed.');
      }
    } catch (e) {
      debugPrint('[DetectionService] ✗ init FAILED: $e');
    }
  }

  void dispose() {
    _isolate?.kill();
    _isolateSetupPort?.close();
    _isInit = false;
    _isolateCommandPort = null;
    debugPrint('[DetectionService] disposed');
  }

  Future<DetectionResult?> processFrame(CameraImage image) async {
    _frameCount++;

    if (!isReady || _isRunning) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastInferMs < _minIntervalMs) return null;

    _lastInferMs = now;
    _isRunning = true;
    _inferCount++;

    debugPrint('[DetectionService] → inference #$_inferCount frame#$_frameCount image=${image.width}x${image.height}');

    try {
      if (image.planes.length < 3) return null;

      final yBytes = Uint8List.fromList(image.planes[0].bytes);
      final uBytes = Uint8List.fromList(image.planes[1].bytes);
      final vBytes = Uint8List.fromList(image.planes[2].bytes);

      final replyPort = ReceivePort();
      _isolateCommandPort!.send(_InferCommand(
        yBytes: yBytes,
        uBytes: uBytes,
        vBytes: vBytes,
        width: image.width,
        height: image.height,
        yRowStride: image.planes[0].bytesPerRow,
        uRowStride: image.planes[1].bytesPerRow,
        uPixStride: image.planes[1].bytesPerPixel ?? 1,
        vRowStride: image.planes[2].bytesPerRow,
        vPixStride: image.planes[2].bytesPerPixel ?? 1,
        replyPort: replyPort.sendPort,
      ));

      final res = await replyPort.first as _InferResult;
      replyPort.close();

      debugPrint('[DetectionService] ← #$_inferCount: ${res.debugMsg}');

      if (res.classIdx < 0) return null;

      final denomination = _denominations[res.classIdx];
      final type = _types[res.classIdx];
      debugPrint('[DetectionService] ✓ DETECTED: $denomination ($type) conf=${res.score.toStringAsFixed(3)}');

      return DetectionResult(
        denomination: denomination,
        type: type,
        confidence: res.score,
      );
    } catch (e, st) {
      debugPrint('[DetectionService] ✗ processFrame error: $e\n$st');
      return null;
    } finally {
      _isRunning = false;
    }
  }
}
