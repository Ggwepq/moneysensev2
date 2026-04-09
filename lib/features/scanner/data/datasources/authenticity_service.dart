import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum AuthenticityResult { genuine, counterfeit, unknown }

class VerificationResult {
  final AuthenticityResult status;
  final double confidence;
  final String label;

  VerificationResult({
    required this.status,
    required this.confidence,
    required this.label,
  });
}

class AuthenticityService {
  AuthenticityService._();
  static final AuthenticityService instance = AuthenticityService._();

  Uint8List? _modelBytes;
  bool _isInit = false;

  static const String _modelPath =
      'assets/models/moneysense-verifier-resnet18.tflite';

  static const List<String> _labels = [
    'genuine_20',
    'counterfeit_20',
    'genuine_50',
    'counterfeit_50',
    'genuine_100',
    'counterfeit_100',
    'genuine_200',
    'counterfeit_200',
    'genuine_500',
    'counterfeit_500',
    'genuine_1000',
    'counterfeit_1000',
  ];

  static const List<double> _mean = [0.485, 0.456, 0.406];
  static const List<double> _std = [0.229, 0.224, 0.225];

  Future<void> init() async {
    if (_isInit) return;
    try {
      final data = await rootBundle.load(_modelPath);
      _modelBytes = data.buffer.asUint8List();
      _isInit = true;
      debugPrint('[AuthenticityService] ResNet-18 model bytes loaded.');
    } catch (e) {
      debugPrint('[AuthenticityService] Error loading model: $e');
    }
  }

  /// Verifies a bill from a byte array (JPEG/PNG) and a bounding box.
  Future<VerificationResult> verify({
    required Uint8List imageBytes,
    required Rect? boundingBox,
    bool forceCounterfeit = false,
  }) async {
    if (forceCounterfeit) {
      return VerificationResult(
        status: AuthenticityResult.counterfeit,
        confidence: 0.999,
        label: 'counterfeit_cheat',
      );
    }

    if (!_isInit) await init();
    if (_modelBytes == null) {
      return VerificationResult(
        status: AuthenticityResult.unknown,
        confidence: 0,
        label: 'Error',
      );
    }

    // Get external directory for debug logging (easier to access via ADB)
    final debugDir = await getExternalStorageDirectory();
    final debugPath = debugDir?.path ?? (await getTemporaryDirectory()).path;

    // Run heavy processing in compute
    return await compute(_processAndPredict, {
      'imageBytes': imageBytes,
      'boundingBox': boundingBox != null
          ? [
              boundingBox.left,
              boundingBox.top,
              boundingBox.width,
              boundingBox.height,
            ]
          : null,
      'modelBytes': _modelBytes,
      'debugPath': debugPath,
    });
  }

  static Future<VerificationResult> _processAndPredict(
    Map<String, dynamic> args,
  ) async {
    final Uint8List imageBytes = args['imageBytes'];
    final List<double>? bbox = args['boundingBox'];
    final Uint8List modelBytes = args['modelBytes'];
    final String debugPath = args['debugPath'];

    // DEBUG: Save full frame
    try {
      File('$debugPath/debug_full_frame.jpg').writeAsBytesSync(imageBytes);
    } catch (e) {
      debugPrint('[AuthenticityService] Debug logging error: $e');
    }

    // 1. Decode
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      return VerificationResult(
        status: AuthenticityResult.unknown,
        confidence: 0,
        label: 'Decode Error',
      );
    }

    // 2. Crop if bbox available
    if (bbox != null) {
      final left = (bbox[0] * image.width).toInt();
      final top = (bbox[1] * image.height).toInt();
      final width = (bbox[2] * image.width).toInt();
      final height = (bbox[3] * image.height).toInt();

      image = img.copyCrop(
        image,
        x: left,
        y: top,
        width: width,
        height: height,
      );
    }

    // DEBUG: Save high-res processed input BEFORE model resizing
    try {
      final debugImage = img.copyResize(
        image,
        width: 640,
        interpolation: img.Interpolation.linear,
      );
      File('$debugPath/debug_processed_input.jpg')
          .writeAsBytesSync(img.encodeJpg(debugImage));
    } catch (e) {
      debugPrint('[AuthenticityService] Debug logging error: $e');
    }

    // 3. Resize to ResNet size (224x224) with PADDING to avoid squeezing
    // We resize the largest side to 224 and pad the rest with black.
    final canvas = img.Image(width: 224, height: 224);
    final resized = img.copyResize(
      image,
      width: image.width > image.height ? 224 : null,
      height: image.height >= image.width ? 224 : null,
      interpolation: img.Interpolation.linear,
    );
    
    // Center the resized image on the 224x224 canvas
    final dx = (224 - resized.width) ~/ 2;
    final dy = (224 - resized.height) ~/ 2;
    img.compositeImage(canvas, resized, dstX: dx, dstY: dy);
    image = canvas;

    // 4. Preprocess (Normalized Float32)
    final input = Float32List(1 * 224 * 224 * 3);
    int pIdx = 0;
    for (var pixel in image) {
      final r = pixel.r / 255.0;
      final g = pixel.g / 255.0;
      final b = pixel.b / 255.0;

      input[pIdx++] = (r - _mean[0]) / _std[0];
      input[pIdx++] = (g - _mean[1]) / _std[1];
      input[pIdx++] = (b - _mean[2]) / _std[2];
    }

    // 5. Load interpreter for this compute task (using bytes)
    final interpreter = Interpreter.fromBuffer(modelBytes);
    final output = List<double>.filled(
      _labels.length,
      0,
    ).reshape([1, _labels.length]);

    interpreter.run(input.buffer.asUint8List(), output);
    interpreter.close();

    final probs = _softmax(List<double>.from(output[0]));

    int maxIdx = 0;
    double maxScore = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxScore) {
        maxScore = probs[i];
        maxIdx = i;
      }
    }

    final label = _labels[maxIdx];
    final isCounterfeit = label.contains('counterfeit');

    return VerificationResult(
      status: isCounterfeit
          ? AuthenticityResult.counterfeit
          : AuthenticityResult.genuine,
      confidence: maxScore,
      label: label,
    );
  }

  static List<double> _softmax(List<double> logits) {
    double maxLogit = logits.reduce(max);
    final exps = logits.map((v) => exp(v - maxLogit)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((v) => v / sum).toList();
  }
}
