import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/disease_result.dart';
import '../services/disease_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

class DiseaseScanScreen extends StatefulWidget {
  final DiseaseService diseaseService;
  const DiseaseScanScreen({super.key, required this.diseaseService});

  @override
  State<DiseaseScanScreen> createState() => _DiseaseScanScreenState();
}

class _DiseaseScanScreenState extends State<DiseaseScanScreen> {
  bool _scanning = false;
  DiseaseResult? _result;

  Future<void> _runScan() async {
    setState(() {
      _scanning = true;
      _result = null;
    });
    // No real camera capture wired up yet — an empty byte buffer stands in
    // for a captured photo; swapping in `image_picker` here doesn't change
    // this screen's flow, only where photoBytes comes from.
    final result = await widget.diseaseService.analyze(Uint8List(0));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AgriShieldColors.accent, width: 2, style: BorderStyle.solid),
          ),
          child: Center(
            child: _scanning
                ? const Text('Checking leaf photo…',
                    style: TextStyle(color: AgriShieldColors.accent, fontWeight: FontWeight.w700))
                : GestureDetector(
                    onTap: _runScan,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: const BoxDecoration(color: AgriShieldColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 10),
                        const Text('Tap to photograph a leaf',
                            style: TextStyle(color: AgriShieldColors.primary, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
          ),
        ),
        if (_result != null) ...[
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LIKELY ISSUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                Text(_result!.likelyIssue,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AgriShieldColors.primary)),
                const SizedBox(height: 6),
                Text('${_result!.confidenceLabel} — first opinion, not a final answer.',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AgriShieldColors.alert),
                    onPressed: () {},
                    icon: const Icon(Icons.phone),
                    label: const Text('Find an extension officer nearby'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
