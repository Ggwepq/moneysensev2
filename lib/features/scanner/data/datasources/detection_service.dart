import 'dart:isolate';
import 'dart:io';

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
    required this.inputSize, // Just in case, though we detect it now
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
  final double cx, cy, w, h;
  final int inSize;
  final String debugMsg;
  const _InferResult(this.classIdx, this.score, this.cx, this.cy, this.w, this.h, this.inSize, this.debugMsg);
}

// ── Isolate Entry Point ───────────────────────────────────────────────────

void _persistentIsolateEntry(SendPort setupPort) {
  final receivePort = ReceivePort();
  setupPort.send(receivePort.sendPort);

  Interpreter? interpreter;
  int numClasses = 9;
  double confThreshold = 0.25;
  int inputSize = 640;

  receivePort.listen((message) {
    if (message is _InitCommand) {
      try {
        final options = InterpreterOptions()..threads = 4;
        
        if (Platform.isAndroid) {
          options.addDelegate(GpuDelegateV2());
        } else if (Platform.isIOS) {
          options.addDelegate(CoreMlDelegate());
        }

        interpreter = Interpreter.fromBuffer(
          message.modelBytes,
          options: options,
        );
        numClasses = message.numClasses;
        confThreshold = message.confThreshold;
        inputSize = message.inputSize;
        
        interpreter!.allocateTensors();
        message.replyPort.send(true);
      } catch (e) {
        try {
          interpreter = Interpreter.fromBuffer(
            message.modelBytes,
            options: InterpreterOptions()..threads = 4,
          );
          interpreter!.allocateTensors();
          message.replyPort.send(true);
        } catch (e2) {
          message.replyPort.send(false);
        }
      }
    } else if (message is _InferCommand) {
      if (interpreter == null) {
        message.replyPort.send(const _InferResult(-1, 0, 0, 0, 0, 0, 0, 'Interpreter not initialized'));
        return;
      }

      final sw = Stopwatch()..start();
      try {
        final inputT = interpreter!.getInputTensor(0);
        final outT = interpreter!.getOutputTensor(0);

        // ── 1. Dynamic Shape & Type Detection ───────────────────────────
        final shape = inputT.shape;
        final type = inputT.type;
        int inSize = inputSize;
        bool isNCHW = false;
        bool isQuantized = type == TensorType.uint8;

        if (shape[1] == 3) {
          isNCHW = true;
          inSize = shape[2];
        } else {
          inSize = shape[1];
        }

        // Use a generic List to allow both Uint8List and Float32List
        final List tensor = isQuantized ? Uint8List(inSize * inSize * 3) : Float32List(inSize * inSize * 3);
        final scaleX = message.width / inSize;
        final scaleY = message.height / inSize;

        for (int y = 0; y < inSize; y++) {
          final srcY = (y * scaleY).toInt().clamp(0, message.height - 1);
          final uvR = srcY >> 1;
          final yRowOffset = srcY * message.yRowStride;
          final uvRowOffset = uvR * message.uRowStride;
          
          for (int x = 0; x < inSize; x++) {
            final srcX = (x * scaleX).toInt().clamp(0, message.width - 1);
            
            final yIdx = yRowOffset + srcX;
            final uvC = srcX >> 1;
            final uIdx = uvRowOffset + (uvC * message.uPixStride);
            final vIdx = uvRowOffset + (uvC * message.vPixStride);

            final Y = message.yBytes[yIdx] & 0xFF;
            final U = (message.uBytes[uIdx] & 0xFF) - 128;
            final V = (message.vBytes[vIdx] & 0xFF) - 128;

            double rV = (Y + 1.402 * V).clamp(0.0, 255.0);
            double gV = (Y - 0.344136 * U - 0.714136 * V).clamp(0.0, 255.0);
            double bV = (Y + 1.772 * U).clamp(0.0, 255.0);

            if (!isQuantized) {
              rV /= 255.0;
              gV /= 255.0;
              bV /= 255.0;
            }

            if (isNCHW) {
              tensor[(0 * inSize * inSize) + (y * inSize + x)] = isQuantized ? rV.toInt() : rV;
              tensor[(1 * inSize * inSize) + (y * inSize + x)] = isQuantized ? gV.toInt() : gV;
              tensor[(2 * inSize * inSize) + (y * inSize + x)] = isQuantized ? bV.toInt() : bV;
            } else {
              final dstIdx = (y * inSize + x) * 3;
              tensor[dstIdx]     = isQuantized ? rV.toInt() : rV;
              tensor[dstIdx + 1] = isQuantized ? gV.toInt() : gV;
              tensor[dstIdx + 2] = isQuantized ? bV.toInt() : bV;
            }
          }
        }
        final preTime = sw.elapsedMilliseconds;

        // ── 2. TFLite Execution ──────────────────────────────────────────
        if (isQuantized) {
          inputT.setTo(tensor as Uint8List);
        } else {
          inputT.setTo((tensor as Float32List).buffer.asUint8List());
        }
        
        interpreter!.invoke();
        
        final outShape = outT.shape;
        final rows = outShape[1];
        final cols = outShape[2];
        
        final output = Float32List(rows * cols);
        outT.copyTo(output.buffer.asUint8List());
        final inferTime = sw.elapsedMilliseconds - preTime;

        // ── 3. Post-processing (Fast Parsing) ──────────────────────────────
        int bestCls = -1;
        double bestScore = confThreshold;
        double bcx = 0, bcy = 0, bw = 0, bh = 0;

        for (int i = 0; i < cols; i++) {
          for (int c = 0; c < numClasses; c++) {
            final score = output[(4 + c) * cols + i];
            if (score > bestScore) {
              bestScore = score;
              bestCls = c;
              bcx = output[0 * cols + i];
              bcy = output[1 * cols + i];
              bw  = output[2 * cols + i];
              bh  = output[3 * cols + i];
            }
          }
        }
        final postTime = sw.elapsedMilliseconds - preTime - inferTime;

        final debugMsg = '[Isolate] Model:${inSize}px isNCHW:$isNCHW | Done: ${preTime}ms pre, ${inferTime}ms infer, ${postTime}ms post.';
        message.replyPort.send(_InferResult(bestCls, bestScore, bcx, bcy, bw, bh, inSize, debugMsg));
      } catch (e, st) {
        message.replyPort.send(_InferResult(-1, 0, 0, 0, 0, 0, 0, 'ERROR: $e\n$st'));
      }
    }
  });
}


// ── DetectionService ───────────────────────────────────────────────────────

class DetectionService {
  DetectionService._();
  static final DetectionService instance = DetectionService._();

  static const String _assetPath     = 'assets/models/moneysense-bills.tflite';
  static const int    _inputSize     = 640;
  static const double _confThreshold = 0.50;
  static const int    _minIntervalMs = 120;

  static const List<String> _denominations = [
    '1', '5', '10', '20', '50', '100', '200', '500', '1000',
  ];
  static const List<String> _types = [
    'coin', 'coin', 'coin', 'bill', 'bill', 'bill', 'bill', 'bill', 'bill',
  ];
  static const int _numClasses = 9;

  SendPort? _isolateCommandPort;
  ReceivePort? _isolateSetupPort;
  Isolate? _isolate;
  
  bool _isInit = false;
  bool _isRunning = false;
  int _lastInferMs = 0;

  bool get isReady => _isInit && _isolateCommandPort != null;
  bool get isProcessing => _isRunning;

  Future<void> init() async {
    if (_isInit) return;
    try {
      debugPrint('[DetectionService] loading $_assetPath ...');
      final data = await rootBundle.load(_assetPath);
      final modelBytes = data.buffer.asUint8List();

      _isolateSetupPort = ReceivePort();
      _isolate = await Isolate.spawn(_persistentIsolateEntry, _isolateSetupPort!.sendPort);
      _isolateCommandPort = await _isolateSetupPort!.first as SendPort;

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
        debugPrint('[DetectionService] ✓ Universal isolate ready.');
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
  }

  Future<DetectionResult?> processFrame(CameraImage image) async {
    if (!isReady || _isRunning) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastInferMs < _minIntervalMs) return null;

    _lastInferMs = now;
    _isRunning = true;

    try {
      if (image.planes.length < 3) return null;

      final replyPort = ReceivePort();
      _isolateCommandPort!.send(_InferCommand(
        yBytes: image.planes[0].bytes,
        uBytes: image.planes[1].bytes,
        vBytes: image.planes[2].bytes,
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

      if (res.debugMsg.isNotEmpty) {
        debugPrint(res.debugMsg);
      }

      if (res.classIdx < 0) return null;

      final denomination = _denominations[res.classIdx];
      String type = _types[res.classIdx];

      double sBcx = res.cx;
      double sBcy = res.cy;
      double sBw  = res.w;
      double sBh  = res.h;
      
      if ((sBcx > 1.1 || sBw > 1.1) && res.inSize > 0) {
        sBcx /= res.inSize;
        sBcy /= res.inSize;
        sBw  /= res.inSize;
        sBh  /= res.inSize;
      }

      sBcx = sBcx.clamp(0.0, 1.0);
      sBcy = sBcy.clamp(0.0, 1.0);
      sBw = sBw.clamp(0.0, 1.0);
      sBh = sBh.clamp(0.0, 1.0);

      // ── Dynamic 20 Peso Discrimination ───────────────────────────────────
      // If the model detects '20', we use the aspect ratio of the bounding box
      // to determine if it is a coin or a bill.
      // Bills are ~2.4x wider than tall (or taller than wide).
      // Coins are approximately square (1:1 aspect ratio).
      if (denomination == '20') {
        final aspectRatio = sBw / sBh;
        // If aspect ratio is square-ish [0.85, 1.25], it's likely a coin.
        // We also check for inverted orientation (unlikely for coins but safe).
        if (aspectRatio > 0.85 && aspectRatio < 1.17) {
          type = 'coin';
        } else {
          type = 'bill';
        }
      }

      return DetectionResult(
        denomination: denomination,
        type: type,
        confidence: res.score,
        boundingBox: Rect.fromCenter(
          center: Offset(sBcx, sBcy),
          width: sBw,
          height: sBh,
        ),
      );
    } catch (e) {
      debugPrint('[DetectionService] ✗ error: $e');
      return null;
    } finally {
      _isRunning = false;
    }
  }
}
