import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/disease_result.dart';
import 'api_config.dart';

/// Runs Part 2's offline plant-disease check on a leaf photo.
///
/// The real version (per docs/roadmap/README.md's recommended stack) is a
/// TensorFlow Lite model trained on PlantVillage, run on-device via the
/// `tflite_flutter` package with no internet needed. That requires a
/// trained `assets/model.tflite` + label file that don't exist yet, so
/// [MockDiseaseService] is what's wired into the app for now — it has the
/// exact same interface a real `TFLiteDiseaseService` would implement, so
/// swapping one in later is a one-line change in main.dart, not a rewrite.
abstract class DiseaseService {
  Future<DiseaseResult> analyze(Uint8List photoBytes);
}

class MockDiseaseService implements DiseaseService {
  @override
  Future<DiseaseResult> analyze(Uint8List photoBytes) async {
    // Simulates on-device inference latency.
    await Future.delayed(const Duration(milliseconds: 2200));
    return const DiseaseResult(
      likelyIssue: 'Maize Northern Leaf Blight',
      confidence: 0.94,
    );
  }
}

/// V2 addition (docs/roadmap/V2_INTELLIGENCE_LAYER.md) — calls the
/// backend's `/scans/diagnose` (backend/app/services/disease_model_service.py,
/// ported from AgriLite-FL) instead of running on-device. A heavier,
/// online-only second opinion alongside the on-device check, not a
/// replacement for it — needs a reachable backend.
class ServerDiseaseService implements DiseaseService {
  @override
  Future<DiseaseResult> analyze(Uint8List photoBytes) async {
    final request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/scans/diagnose'))
      ..files.add(http.MultipartFile.fromBytes('file', photoBytes, filename: 'leaf.jpg'));
    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception('Server diagnosis failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return DiseaseResult(
      likelyIssue: data['likely_issue'] as String,
      confidence: 1.0, // the backend returns a single best label, no per-class score
      advice: data['advice'] as String?,
    );
  }
}
