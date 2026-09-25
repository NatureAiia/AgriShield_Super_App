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
        // Offline badge — the stunt judges remember: Wi-Fi OFF, still works.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 14, color: context.colors.onPrimary),
              const SizedBox(width: 6),
              Text('OFFLINE AI — no internet needed',
                  style: TextStyle(
                      color: context.colors.onPrimary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
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
                        Text('LIKELY ISSUE', style: context.text.labelSmall),
                        Text(_result!.likelyIssue,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                        const SizedBox(height: 6),
                        // Confidence bar — animates from 0 to value on reveal.
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _result!.confidence.clamp(0.0, 1.0)),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: v,
                                  minHeight: 8,
                                  backgroundColor: context.colors.outline,
                                  valueColor: AlwaysStoppedAnimation<Color>(context.colors.secondary),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_result!.confidence * 100).toStringAsFixed(0)}% • ${_result!.confidenceLabel} — first opinion, not a final answer.',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: context.colors.onSurface.withValues(alpha: 0.65)),
                              ),
                            ],
                          ),
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
