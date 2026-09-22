import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../theme.dart';

/// "Working offline — will sync when connected" indicator.
/// docs/roadmap/UI_UX_DESIGN_SPEC.md's brief (built as a static demo in
/// prototype/AgriShieldMobileApp.jsx) shows this always-on; here, wired to
/// real connectivity, it shows only while actually offline — showing it
/// while genuinely online would be a false claim, which this whole
/// roadmap's honesty principle rules out. Behavior, not wording, changed.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final ConnectivityService _connectivity = ConnectivityService();
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _connectivity.isOnline().then((v) => setState(() => _online = v));
    _connectivity.onChange().listen((v) => setState(() => _online = v));
  }

  @override
  Widget build(BuildContext context) {
    if (_online) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: AgriShieldColors.alert,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Working offline — will sync when connected',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
