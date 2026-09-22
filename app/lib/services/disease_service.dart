import 'dart:typed_data';
import '../models/disease_result.dart';

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
    await Future.delayed(const Duration(milliseconds: 1400));
    return const DiseaseResult(
      likelyIssue: 'Maize Northern Leaf Blight',
      confidence: 0.94,
    );
  }
}
