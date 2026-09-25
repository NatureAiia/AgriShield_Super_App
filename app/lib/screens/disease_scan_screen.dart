import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/disease_result.dart';
import '../services/disease_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/leaf_scan_animation.dart';
import '../widgets/pressable.dart';

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
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AgriShieldRadii.card),
            border: Border.all(color: context.colors.secondary, width: 2),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _scanning
                  ? const LeafScanAnimation(key: ValueKey('scanning'))
                  : Pressable(
                      key: const ValueKey('idle'),
                      onTap: _runScan,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle),
                            child: Icon(Icons.camera_alt, color: context.colors.onPrimary, size: 36),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scaleXY(begin: 1.0, end: 1.05, duration: 1200.ms, curve: Curves.easeInOut),
                          const SizedBox(height: 10),
                          Text('Tap to photograph a leaf',
                              style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _result == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LIKELY ISSUE', style: context.text.labelSmall),
                                  Text(_result!.likelyIssue,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                                ],
                              ),
                            ),
                            _ConfidenceRing(confidence: _result!.confidence),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_result!.confidenceLabel} — first opinion, not a final answer.',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: context.colors.onSurface.withValues(alpha: 0.6)),
                        ),
                        if (_result!.advice != null) ...[
                          const SizedBox(height: 10),
                          Text(_result!.advice!, style: TextStyle(color: context.colors.onSurface)),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: context.colors.error, foregroundColor: context.colors.onError),
                            onPressed: () {},
                            icon: const Icon(Icons.phone),
                            label: const Text('Find an extension officer nearby'),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                ),
        ),
      ],
    );
  }
}

/// The model's confidence as a ring that fills on reveal.
class _ConfidenceRing extends StatelessWidget {
  final double confidence;
  const _ConfidenceRing({required this.confidence});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: confidence.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: v,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                color: context.colors.secondary,
                backgroundColor: context.colors.outline,
              ),
            ),
            Text('${(v * 100).round()}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: context.colors.onSurface)),
          ],
        ),
      ),
    );
  }
}
