import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'models/farmer.dart';
import 'repositories/farmer_repository.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/disease_scan_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/satellite_map_screen.dart';
import 'screens/storage_screen.dart';
import 'services/auth_service.dart';
import 'services/disease_service.dart';
import 'services/messaging_service.dart';
import 'services/recommendation_service.dart';
import 'services/satellite_service.dart';
import 'services/sensor_service.dart';
import 'services/theme_controller.dart';
import 'theme.dart';
import 'widgets/animated_nav_bar.dart';
import 'widgets/demo_tour.dart';
import 'widgets/offline_banner.dart';

void main() {
  runApp(AgriShieldApp(themeController: ThemeController()));
}

class AgriShieldApp extends StatelessWidget {
  final ThemeController themeController;
  const AgriShieldApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'AgriShield',
          debugShowCheckedModeBanner: false,
          theme: buildAgriShieldLightTheme(),
          darkTheme: buildAgriShieldDarkTheme(),
          themeMode: mode,
          home: AgriShieldHome(themeController: themeController),
        );
      },
    );
  }
}

/// V1 scope only (docs/roadmap/V1_HACKATHON_DEMO.md): Foundation + Part 1
/// (storage) + Part 2 (disease scan) + Part 3 (satellite). Modules 4-8, the
/// market layer, and the fintech layer are later-version roadmap, not
/// screens here — see docs/roadmap/README.md's version table.
class AgriShieldHome extends StatefulWidget {
  final ThemeController themeController;
  const AgriShieldHome({super.key, required this.themeController});

  @override
  State<AgriShieldHome> createState() => _AgriShieldHomeState();
}

class _AgriShieldHomeState extends State<AgriShieldHome> {
  // Wired-in implementations. Swap any Mock* for a real implementation of
  // the same interface once hardware/model/credentials exist — nothing
  // else in the app needs to change.
  final SensorService _sensorService = MockSensorService();
  final DiseaseService _diseaseService = MockDiseaseService();
  final SatelliteService _satelliteService = MockSatelliteService();
  final MessagingService _messagingService = MockMessagingService();
  final RecommendationService _recommendationService = HttpRecommendationService();
  final AuthService _authService = HttpAuthService();
  final FarmerRepository _farmerRepository = FarmerRepository();

  int _tab = 0;
  Farmer? _farmer;
  // 60-second stage tour: auto-steps through kDemoScript, driving _tab.
  // Null timer means the tour is off — normal manual navigation.
  bool _demoActive = false;
  int _demoStep = 0;
  Timer? _demoTimer;
  // null while the initial `isSignedIn` check is in flight (near-instant,
  // local SharedPreferences read); false shows the landing/sign-up/sign-in
  // flow, true proceeds straight to the app — a returning, already-signed
  // -in farmer never sees the landing screen again.
  bool? _signedIn;

  static const _titles = [
    'AgriShield', 'Storage Sensor', 'Disease Scan', 'Recommend', 'Satellite Map', 'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _authService.isSignedIn().then((signedIn) {
      if (!mounted) return;
      setState(() => _signedIn = signedIn);
      if (signedIn) _loadFarmer();
    });
  }

  void _loadFarmer() {
    _farmerRepository.load().then((f) {
      if (!mounted) return;
      setState(() => _farmer = f);
    });
  }

  void _onAuthenticated() {
    setState(() => _signedIn = true);
    _loadFarmer();
  }

  Future<void> _signOut() async {
    _stopDemo();
    await _authService.signOut();
    if (!mounted) return;
    setState(() {
      _signedIn = false;
      _farmer = null;
      _tab = 0;
    });
  }

  void _startDemo() {
    _demoTimer?.cancel();
    setState(() {
      _demoActive = true;
      _demoStep = 0;
      _tab = kDemoScript[0].tab;
    });
    _scheduleDemoStep();
  }

  void _scheduleDemoStep() {
    _demoTimer?.cancel();
    final seconds = kDemoScript[_demoStep].seconds;
    _demoTimer = Timer(Duration(seconds: seconds), () {
      if (!mounted || !_demoActive) return;
      _nextDemoStep();
    });
  }

  void _nextDemoStep() {
    if (!_demoActive) return;
    if (_demoStep >= kDemoScript.length - 1) {
      // Last step's Next replays from the top so the presenter can loop.
      setState(() {
        _demoStep = 0;
        _tab = kDemoScript[0].tab;
      });
    } else {
      setState(() {
        _demoStep++;
        _tab = kDemoScript[_demoStep].tab;
      });
    }
    _scheduleDemoStep();
  }

  void _stopDemo() {
    _demoTimer?.cancel();
    _demoTimer = null;
    if (_demoActive && mounted) setState(() => _demoActive = false);
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }

  Widget _brandedLoading(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/branding/logo.jpeg', width: 64, height: 64, fit: BoxFit.cover),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.06, duration: 900.ms, curve: Curves.easeInOut),
            const SizedBox(height: 20),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: context.colors.secondary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn == null) return _brandedLoading(context);
    if (_signedIn == false) {
      return LandingScreen(authService: _authService, onAuthenticated: _onAuthenticated);
    }

    final farmer = _farmer;
    if (farmer == null) return _brandedLoading(context);

    final screens = [
      HomeScreen(farmer: farmer, sensorService: _sensorService, messagingService: _messagingService),
      StorageScreen(sensorService: _sensorService),
      DiseaseScanScreen(diseaseService: _diseaseService),
      RecommendationScreen(recommendationService: _recommendationService),
      SatelliteMapScreen(satelliteService: _satelliteService),
      ProfileScreen(
        farmer: farmer,
        repository: _farmerRepository,
        onSaved: (updated) => setState(() => _farmer = updated),
        onSignOut: _signOut,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/branding/logo.jpeg', fit: BoxFit.cover),
          ),
        ),
        title: Text(_titles[_tab], key: ValueKey(_tab))
            .animate(key: ValueKey(_tab))
            .fadeIn(duration: 220.ms)
            .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic, duration: 220.ms),
        actions: [
          IconButton(
            icon: Icon(_demoActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                key: ValueKey(_demoActive)),
            tooltip: _demoActive ? 'End 60s demo' : 'Play 60s demo',
            onPressed: _demoActive ? _stopDemo : _startDemo,
          ),
          ListenableBuilder(
            listenable: widget.themeController,
            builder: (context, _) => IconButton(
              icon: Icon(widget.themeController.icon, key: ValueKey(widget.themeController.icon))
                  .animate(key: ValueKey(widget.themeController.icon))
                  .scaleXY(begin: 0.5, end: 1, curve: Curves.easeOutBack, duration: 300.ms)
                  .fadeIn(duration: 200.ms),
              tooltip: widget.themeController.label,
              onPressed: widget.themeController.cycle,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          if (_demoActive)
            DemoTourOverlay(
              stepIndex: _demoStep,
              onNext: _nextDemoStep,
              onEnd: _stopDemo,
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(_tab), child: screens[_tab]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedNavBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          // A manual tap takes the presenter off autopilot.
          if (_demoActive) _stopDemo();
          setState(() => _tab = i);
        },
        items: const [
          NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
          NavItem(icon: Icons.thermostat_outlined, selectedIcon: Icons.thermostat, label: 'Storage'),
          NavItem(icon: Icons.camera_alt_outlined, selectedIcon: Icons.camera_alt, label: 'Scan'),
          NavItem(icon: Icons.eco_outlined, selectedIcon: Icons.eco, label: 'Recommend'),
          NavItem(icon: Icons.map_outlined, selectedIcon: Icons.map, label: 'Map'),
          NavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}
