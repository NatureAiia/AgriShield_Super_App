import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'models/farmer.dart';
import 'repositories/farmer_repository.dart';
import 'screens/disease_scan_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/satellite_map_screen.dart';
import 'screens/storage_screen.dart';
import 'services/disease_service.dart';
import 'services/messaging_service.dart';
import 'services/satellite_service.dart';
import 'services/sensor_service.dart';
import 'services/theme_controller.dart';
import 'theme.dart';
import 'widgets/animated_nav_bar.dart';
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
  final FarmerRepository _farmerRepository = FarmerRepository();

  int _tab = 0;
  Farmer? _farmer;

  static const _titles = ['AgriShield', 'Storage Sensor', 'Disease Scan', 'Satellite Map', 'Profile'];

  @override
  void initState() {
    super.initState();
    _farmerRepository.load().then((f) => setState(() => _farmer = f));
  }

  @override
  Widget build(BuildContext context) {
    final farmer = _farmer;
    if (farmer == null) {
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

    final screens = [
      HomeScreen(farmer: farmer, sensorService: _sensorService, messagingService: _messagingService),
      StorageScreen(sensorService: _sensorService),
      DiseaseScanScreen(diseaseService: _diseaseService),
      SatelliteMapScreen(satelliteService: _satelliteService),
      ProfileScreen(
        farmer: farmer,
        repository: _farmerRepository,
        onSaved: (updated) => setState(() => _farmer = updated),
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
        onDestinationSelected: (i) => setState(() => _tab = i),
        items: const [
          NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
          NavItem(icon: Icons.thermostat_outlined, selectedIcon: Icons.thermostat, label: 'Storage'),
          NavItem(icon: Icons.camera_alt_outlined, selectedIcon: Icons.camera_alt, label: 'Scan'),
          NavItem(icon: Icons.map_outlined, selectedIcon: Icons.map, label: 'Map'),
          NavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}
