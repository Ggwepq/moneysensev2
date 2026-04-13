import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum AuthenticityResult { genuine, counterfeit, unknown }

class VerificationResult {
  final AuthenticityResult status;
  final double confidence;
  final String label;
  final String? collaborativeDenom;
  final String? reason;
  
  // Multi-stage scores for diagnostics
  final double? classifierScore;
  final List<String>? ocrAlerts;

  VerificationResult({
    required this.status,
    required this.confidence,
    required this.label,
    this.collaborativeDenom,
    this.reason,
    this.classifierScore,
    this.ocrAlerts,
  });
}

class IdentificationResult {
  final String denomination;
  final double confidence;
  
  IdentificationResult({required this.denomination, required this.confidence});
}

class AuthenticityService {
  AuthenticityService._();
  static final AuthenticityService instance = AuthenticityService._();

  final TextRecognizer _textRecognizer = TextRecognizer();
  Uint8List? _modelBytes;
  Uint8List? _siameseBytes;
  Map<String, List<List<double>>> _referenceEmbeddings = {};
  bool _isInit = false;

  static const String _modelPath =
      'assets/models/moneysense-verifier-resnet18.tflite';
  static const String _siamesePath = 
      'assets/models/moneysense-siamese.tflite';
  static const String _referencesPath = 
      'assets/models/reference_embeddings.json';

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
      // Load Classifier
      final data = await rootBundle.load(_modelPath);
      _modelBytes = data.buffer.asUint8List();
      
      // Load Siamese
      try {
        final siameseData = await rootBundle.load(_siamesePath);
        _siameseBytes = siameseData.buffer.asUint8List();
        debugPrint('[AuthenticityService] Siamese model bytes loaded.');
      } catch (e) {
        debugPrint('[AuthenticityService] ⚠ Siamese model not found at $_siamesePath');
      }

      // Load Reference Embeddings
      await _loadReferences();

      _isInit = true;
      debugPrint('[AuthenticityService] Multi-stage ready.');
    } catch (e) {
      debugPrint('[AuthenticityService] ✗ Error loading models: $e');
    }
  }

  Future<void> _loadReferences() async {
    try {
      final jsonStr = await rootBundle.loadString(_referencesPath);
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final embs = data['embeddings'] as Map<String, dynamic>;
      
      _referenceEmbeddings = embs.map((key, value) {
        final list = value as List;
        // Handle both single vector and multi-vector formats for robustness
        if (list.isNotEmpty && list.first is num) {
          return MapEntry(key, [List<double>.from(list)]);
        }
        return MapEntry(key, list.map((v) => List<double>.from(v as List)).toList());
      });
      debugPrint('[AuthenticityService] Loaded multi-reference embeddings for: ${_referenceEmbeddings.keys.join(", ")}');
    } catch (e) {
      debugPrint('[AuthenticityService] ⚠ Failed to load reference embeddings: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }

  /// Extracts denomination text from the image using OCR.
  /// Used for early identification before the authentication delay.
  Future<String?> getDenominationFromOCR(Uint8List imageBytes) async {
    final debugDir = await getExternalStorageDirectory();
    final debugPath = debugDir?.path ?? (await getTemporaryDirectory()).path;
    final ocrResult = await _runOCR(imageBytes, debugPath);
    return ocrResult.detectedDenom;
  }

  /// Performs collaborative identification using Siamese and OCR.
  /// Used for early identification (The "Triple Check").
  Future<IdentificationResult> getCollaborativeIdentification({
    required Uint8List imageBytes,
    required Rect? boundingBox,
    required String yoloDenom,
    required double yoloConfidence,
    required String type,
  }) async {
    if (!_isInit) await init();
    
    final debugDir = await getExternalStorageDirectory();
    final debugPath = debugDir?.path ?? (await getTemporaryDirectory()).path;

    // 1. Skip Siamese for coins (No reference data yet)
    if (type == 'coin') {
      debugPrint('[AuthenticityService/ID] 🪙 Type is coin. Skipping Siamese, running OCR check.');
      final ocrResult = await _runOCR(imageBytes, debugPath, boundingBox);
      return IdentificationResult(
        denomination: ocrResult.detectedDenom ?? yoloDenom,
        confidence: yoloConfidence,
      );
    }

    // 2. Task: Siamese Feature Extraction (Compute-bound)
    Future<List<double>?> siameseTask;
    if (_siameseBytes != null) {
      siameseTask = compute(_processSiamese, {
        'imageBytes': imageBytes,
        'boundingBox': boundingBox != null
            ? [boundingBox.left, boundingBox.top, boundingBox.width, boundingBox.height]
            : null,
        'modelBytes': _siameseBytes,
        'debugPath': debugPath,
      });
    } else {
      siameseTask = Future.value(null);
    }

    // 3. Task: OCR
    final ocrTask = _runOCR(imageBytes, debugPath, boundingBox);

    final results = await Future.wait([siameseTask, ocrTask]);
    final liveEmbedding = results[0] as List<double>?;
    final ocrResult = results[1] as _OCRResult;

    String? siameseBestDenom;
    double siameseBestScore = -1.0;

    // 4. Multi-Denomination Siamese Check
    if (liveEmbedding != null) {
      for (final entry in _referenceEmbeddings.entries) {
        final denom = entry.key;
        final refs = entry.value;
        
        double maxSim = -1.0;
        for (final ref in refs) {
          final sim = _calculateSimilarity(liveEmbedding, ref);
          if (sim > maxSim) maxSim = sim;
        }
        
        if (maxSim > siameseBestScore) {
          siameseBestScore = maxSim;
          siameseBestDenom = denom;
        }
      }
      debugPrint('[AuthenticityService/ID] Siamese Winner: $siameseBestDenom (Score: ${siameseBestScore.toStringAsFixed(4)})');
    }

    // 5. Decision Logic (CONSENSUS)
    
    // Rule 1: OCR is Gold Standard for text.
    if (ocrResult.detectedDenom != null) {
      debugPrint('[AuthenticityService/ID] 🎯 OCR Voted: ${ocrResult.detectedDenom}');
      // Return OCR match with highest visual confidence as fallback for percentage display
      return IdentificationResult(
        denomination: ocrResult.detectedDenom!,
        confidence: max(yoloConfidence, siameseBestScore),
      );
    }

    // Rule 2: Siamese Competition Logic
    if (siameseBestDenom != null) {
      // Extreme confidence: Siamese Corrects YOLO
      if (siameseBestScore > 0.94) {
        debugPrint('[AuthenticityService/ID] 🎯 Siamese VETO: $siameseBestDenom (Score: $siameseBestScore > 0.94)');
        return IdentificationResult(denomination: siameseBestDenom, confidence: siameseBestScore);
      }
      // Agreement: Confirms YOLO
      if (siameseBestDenom == yoloDenom && siameseBestScore > 0.85) {
        debugPrint('[AuthenticityService/ID] 🎯 Siamese CONFIRMED YOLO $yoloDenom (Score: $siameseBestScore)');
        return IdentificationResult(denomination: yoloDenom, confidence: max(yoloConfidence, siameseBestScore));
      }
      // Moderate Disagreement: Siamese vs YOLO
      if (siameseBestDenom != yoloDenom && siameseBestScore > 0.90) {
        debugPrint('[AuthenticityService/ID] ⚖ Siamese Correcting YOLO to $siameseBestDenom (Score: $siameseBestScore)');
        return IdentificationResult(denomination: siameseBestDenom, confidence: siameseBestScore);
      }
      
      debugPrint('[AuthenticityService/ID] ⚖ Consensus Weak. Sticking with YOLO $yoloDenom.');
    }

    return IdentificationResult(denomination: yoloDenom, confidence: yoloConfidence);
  }

  /// Verifies a bill using both physical feature modeling (ResNet) 
  /// and collaborative text analysis (OCR).
  Future<VerificationResult> verify({
    required Uint8List imageBytes,
    required Rect? boundingBox,
    required String yoloDenom,
    bool forceCounterfeit = false,
  }) async {
    debugPrint('[AuthenticityService] 🔍 Starting Verification for YOLO=$yoloDenom');
    
    if (forceCounterfeit) {
      debugPrint('[AuthenticityService] ! Force Counterfeit enabled.');
      return VerificationResult(
        status: AuthenticityResult.counterfeit,
        confidence: 0.999,
        label: 'counterfeit_cheat',
      );
    }

    if (!_isInit) await init();
    if (_modelBytes == null) {
      debugPrint('[AuthenticityService] ⚠ Model not loaded.');
      return VerificationResult(
        status: AuthenticityResult.unknown,
        confidence: 0,
        label: 'Error',
      );
    }

    final debugDir = await getExternalStorageDirectory();
    final debugPath = debugDir?.path ?? (await getTemporaryDirectory()).path;

    // Cache the full frame image for debugging
    try {
      final fullFrameFile = File('$debugPath/debug_full_frame.jpg');
      await fullFrameFile.writeAsBytes(imageBytes);
      debugPrint('[AuthenticityService] 💾 Saved debug_full_frame.jpg');
    } catch (e) {
      debugPrint('[AuthenticityService] ✗ Failed to save full frame: $e');
    }

    // 1. Parallel Task: ResNet-18 (Physical Authenticity)
    debugPrint('[AuthenticityService] → Spawning ResNet classifier task...');
    final resNetTask = compute(_processAndPredict, {
      'imageBytes': imageBytes,
      'boundingBox': boundingBox != null
          ? [boundingBox.left, boundingBox.top, boundingBox.width, boundingBox.height]
          : null,
      'modelBytes': _modelBytes,
      'debugPath': debugPath,
    });

    // 2. Parallel Task: OCR (Collaborative Identification)
    debugPrint('[AuthenticityService] → Starting OCR pass...');
    final ocrTask = _runOCR(imageBytes, debugPath, boundingBox);

    final results = await Future.wait([resNetTask, ocrTask]);
    final resNetResult = results[0] as VerificationResult;
    final ocrResult = results[1] as _OCRResult;

    debugPrint('[AuthenticityService] ✓ Model Tasks Complete.');
    debugPrint('[AuthenticityService]   • ResNet status: ${resNetResult.status.name} (${(resNetResult.confidence * 100).toStringAsFixed(1)}%)');
    debugPrint('[AuthenticityService]   • OCR detected denomination: ${ocrResult.detectedDenom ?? "None"}');
    
    // 3. Consensus & Decision
    AuthenticityResult finalStatus = resNetResult.status;
    String? finalDenom = ocrResult.detectedDenom ?? yoloDenom;
    String? reason;
    
    // Rule 1: OCR Keywords (Veto Power)
    if (ocrResult.hasSecurityAlert) {
      finalStatus = AuthenticityResult.counterfeit;
      final alerts = ocrResult.alerts.join(", ");
      reason = 'OCR Keyword detected: $alerts';
      debugPrint('[AuthenticityService] ‼ CONSENSUS: OCR VETO (Counterfeit keyword found)');
    } 

    return VerificationResult(
      status: finalStatus,
      confidence: resNetResult.confidence,
      label: resNetResult.label,
      collaborativeDenom: finalDenom,
      reason: reason,
      classifierScore: resNetResult.confidence,
      ocrAlerts: ocrResult.alerts,
    );
  }

  static double _calculateSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  static Future<List<double>?> _processSiamese(Map<String, dynamic> args) async {
    final Uint8List imageBytes = args['imageBytes'];
    final List<double>? bbox = args['boundingBox'];
    final Uint8List modelBytes = args['modelBytes'];
    
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return null;

    if (bbox != null) {
      image = img.copyCrop(image, 
        x: (bbox[0] * image.width).toInt(), 
        y: (bbox[1] * image.height).toInt(), 
        width: (bbox[2] * image.width).toInt(), 
        height: (bbox[3] * image.height).toInt());
    }

    final canvas = img.Image(width: 224, height: 224);
    final resized = img.copyResize(image, 
      width: image.width > image.height ? 224 : null, 
      height: image.height >= image.width ? 224 : null);
    img.compositeImage(canvas, resized, dstX: (224 - resized.width) ~/ 2, dstY: (224 - resized.height) ~/ 2);
    
    final input = Float32List(224 * 224 * 3);
    int p = 0;
    for (var pix in canvas) {
      input[p++] = (pix.r / 255.0 - _mean[0]) / _std[0];
      input[p++] = (pix.g / 255.0 - _mean[1]) / _std[1];
      input[p++] = (pix.b / 255.0 - _mean[2]) / _std[2];
    }

    try {
      final interpreter = Interpreter.fromBuffer(modelBytes);
      // Assuming 512 dimensions for ResNet18 feature extractor
      final output = List<double>.filled(512, 0).reshape([1, 512]);
      interpreter.run(input.buffer.asUint8List(), output);
      interpreter.close();
      
      return List<double>.from(output[0]);
    } catch (e) {
      debugPrint('[AuthenticityIsolate/Siamese] ✗ Inference failed: $e');
      return null;
    }
  }

  Future<_OCRResult> _runOCR(Uint8List imageBytes, String debugPath, [Rect? boundingBox]) async {
    try {
      
      InputImage input;
      
      // If we have a bounding box, crop the image first to improve OCR accuracy
      if (boundingBox != null) {
        final decoded = img.decodeImage(imageBytes);
        if (decoded != null) {
          final cropped = img.copyCrop(decoded,
            x: (boundingBox.left * decoded.width).toInt(),
            y: (boundingBox.top * decoded.height).toInt(),
            width: (boundingBox.width * decoded.width).toInt(),
            height: (boundingBox.height * decoded.height).toInt(),
          );
          
          final croppedBytes = Uint8List.fromList(img.encodeJpg(cropped));
          
          // Debug cache the OCR input
          try {
            final ocrFile = File('$debugPath/debug_ocr_input.jpg');
            await ocrFile.writeAsBytes(croppedBytes);
          } catch (_) {}

          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/ocr_temp.jpg');
          await tempFile.writeAsBytes(croppedBytes);
          input = InputImage.fromFilePath(tempFile.path);
        } else {
          input = InputImage.fromBytes(bytes: imageBytes, metadata: InputImageMetadata(
            size: Size.zero, rotation: InputImageRotation.rotation0deg, format: InputImageFormat.bgra8888, bytesPerRow: 0)); // Fallback placeholder
        }
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/ocr_temp.jpg');
        await tempFile.writeAsBytes(imageBytes);
        input = InputImage.fromFilePath(tempFile.path);
      }
      final recognizedText = await _textRecognizer.processImage(input);
      final text = recognizedText.text.toUpperCase();
      
      debugPrint('[AuthenticityService/OCR] Raw Recognized Text: "${text.replaceAll("\n", " ")}"');
      
      final alerts = <String>[];
      // Intelligent Fragment Detection
      const alertKeys = [
        'PLAY MONEY', 'SPECIMEN', 'SAMPOL', 'NOT FOR CIRCULATION', 
        'TOY MONEY', 'VALUABLE ONLY AS A TOY', 'REPLICA', 'NO VALUE',
        'FAKE', 'IMITATION', 'TRAINING ONLY'
      ];
      
      for (var k in alertKeys) {
        if (text.contains(k)) {
          alerts.add(k);
        } else if (k.length >= 6) {
          final prefix = k.substring(0, 5);
          if (text.contains(prefix)) alerts.add('$prefix...');
        }
      }

      String? detectedDenom;
      
      // TAGALOG WORD DICTIONARY (High Trust)
      final tagalogMap = {
        'DALAWAMPUNG': '20',
        'LIMAMPUNG': '50',
        'SANDAAN': '100',
        'DALAWANG DAAN': '200',
        'LIMANG DAAN': '500',
        'SANG LIBO': '1000',
        'ISANG LIBO': '1000',
      };
      
      for (var entry in tagalogMap.entries) {
        if (text.contains(entry.key)) {
          debugPrint('[AuthenticityService/OCR] Tagalog word matched: ${entry.key} → ${entry.value}');
          detectedDenom = entry.value;
          break;
        }
      }

      // NUMERIC CROSS-CHECK
      if (detectedDenom == null) {
        final nums = ['1000', '500', '200', '100', '50', '20'];
        for (var n in nums) {
          if (text.contains(n)) {
            debugPrint('[AuthenticityService/OCR] Numeric match: $n');
            detectedDenom = n;
            break; 
          }
        }
      }

      return _OCRResult(
        hasSecurityAlert: alerts.isNotEmpty,
        alerts: alerts,
        detectedDenom: detectedDenom,
      );
    } catch (e) {
      debugPrint('[AuthenticityService/OCR] ✗ Pass failed: $e');
      return const _OCRResult();
    }
  }

  static Future<VerificationResult> _processAndPredict(Map<String, dynamic> args) async {
    final Uint8List imageBytes = args['imageBytes'];
    final List<double>? bbox = args['boundingBox'];
    final Uint8List modelBytes = args['modelBytes'];
    
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return VerificationResult(status: AuthenticityResult.unknown, confidence: 0, label: 'err');

    if (bbox != null) {
      image = img.copyCrop(image, 
        x: (bbox[0] * image.width).toInt(), 
        y: (bbox[1] * image.height).toInt(), 
        width: (bbox[2] * image.width).toInt(), 
        height: (bbox[3] * image.height).toInt());
    }

    final canvas = img.Image(width: 224, height: 224);
    final resized = img.copyResize(image, 
      width: image.width > image.height ? 224 : null, 
      height: image.height >= image.width ? 224 : null);
    img.compositeImage(canvas, resized, dstX: (224 - resized.width) ~/ 2, dstY: (224 - resized.height) ~/ 2);
    
    // Cache the processed input image for debugging
    try {
      final debugPath = args['debugPath'] as String;
      final processedFile = File('$debugPath/debug_processed_input.jpg');
      processedFile.writeAsBytesSync(img.encodeJpg(canvas));
      debugPrint('[AuthenticityIsolate] 💾 Saved debug_processed_input.jpg');
    } catch (e) {
      // Ignore errors in background isolate
    }
    
    // Cache the processed input image for debugging
    try {
      final debugPath = args['debugPath'] as String;
      final processedFile = File('$debugPath/debug_processed_input.jpg');
      processedFile.writeAsBytesSync(img.encodeJpg(canvas));
      debugPrint('[AuthenticityIsolate] 💾 Saved debug_processed_input.jpg');
    } catch (e) {
      // Ignore errors in background isolate
    }
    
    // Cache the processed input image for debugging
    try {
      final debugPath = args['debugPath'] as String;
      final processedFile = File('$debugPath/debug_processed_input.jpg');
      processedFile.writeAsBytesSync(img.encodeJpg(canvas));
      debugPrint('[AuthenticityIsolate] 💾 Saved debug_processed_input.jpg');
    } catch (e) {
      // Ignore errors in background isolate
    }
    
    // Cache the processed input image for debugging
    try {
      final debugPath = args['debugPath'] as String;
      final processedFile = File('$debugPath/debug_processed_input.jpg');
      processedFile.writeAsBytesSync(img.encodeJpg(canvas));
    } catch (e) {
      // Ignore errors in background isolate
    }
    
    final input = Float32List(224 * 224 * 3);
    int p = 0;
    for (var pix in canvas) {
      input[p++] = (pix.r / 255.0 - _mean[0]) / _std[0];
      input[p++] = (pix.g / 255.0 - _mean[1]) / _std[1];
      input[p++] = (pix.b / 255.0 - _mean[2]) / _std[2];
    }

    final interpreter = Interpreter.fromBuffer(modelBytes);
    final output = List<double>.filled(_labels.length, 0).reshape([1, _labels.length]);
    interpreter.run(input.buffer.asUint8List(), output);
    interpreter.close();

    final probs = _softmax(List<double>.from(output[0]));
    int maxIdx = 0;
    for (int i=1; i<probs.length; i++) if (probs[i] > probs[maxIdx]) maxIdx = i;

    final label = _labels[maxIdx];
    return VerificationResult(
      status: label.contains('counterfeit') ? AuthenticityResult.counterfeit : AuthenticityResult.genuine,
      confidence: probs[maxIdx],
      label: label,
    );
  }

  static List<double> _softmax(List<double> logits) {
    double m = logits.reduce(max);
    final exps = logits.map((v) => exp(v - m)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((v) => v / sum).toList();
  }
}

class _OCRResult {
  final bool hasSecurityAlert;
  final List<String> alerts;
  final String? detectedDenom;
  const _OCRResult({this.hasSecurityAlert = false, this.alerts = const [], this.detectedDenom});
}
