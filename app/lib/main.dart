import 'package:flutter/material.dart';
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
import 'theme.dart';
import 'widgets/offline_banner.dart';

void main() {
  runApp(const AgriShieldApp());
}

class AgriShieldApp extends StatelessWidget {
  const AgriShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriShield',
      debugShowCheckedModeBanner: false,
      theme: buildAgriShieldTheme(),
      home: const AgriShieldHome(),
    );
  }
}

/// V1 scope only (docs/roadmap/V1_HACKATHON_DEMO.md): Foundation + Part 1
/// (storage) + Part 2 (disease scan) + Part 3 (satellite). Modules 4-8, the
/// market layer, and the fintech layer are later-version roadmap, not
/// screens here — see docs/roadmap/README.md's version table.
class AgriShieldHome extends StatefulWidget {
  const AgriShieldHome({super.key});

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        title: Text(_titles[_tab]),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: screens[_tab]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.thermostat), label: 'Storage'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
