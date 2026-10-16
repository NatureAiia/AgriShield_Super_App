import 'package:flutter/material.dart';
import 'dart:async';
import 'models/farmer.dart';
import 'repositories/farmer_repository.dart';
import 'screens/advice_chat_screen.dart';
import 'screens/advisor_screen.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/disease_scan_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/satellite_map_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/storage_screen.dart';
import 'screens/weather_screen.dart';
import 'models/advisor.dart';
import 'services/advisor_service.dart';
import 'services/auth_service.dart';
import 'services/calendar_service.dart';
import 'services/chat_service.dart';
import 'services/disease_service.dart';
import 'services/drought_service.dart';
import 'services/language_controller.dart';
import 'services/messaging_service.dart';
import 'services/recommendation_service.dart';
import 'services/satellite_service.dart';
import 'services/sensor_service.dart';
import 'services/weather_service.dart';
import 'services/theme_controller.dart';
import 'theme.dart';
import 'widgets/animated_nav_bar.dart';
import 'widgets/demo_tour.dart';
import 'widgets/offline_banner.dart';
import 'widgets/ui_kit.dart';

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
  final ChatService _chatService = HttpChatService();
  final LanguageController _languageController = LanguageController();
  final WeatherService _weatherService = HttpWeatherService();
  final AdvisorService _advisorService = HttpAdvisorService();
  final CalendarService _calendarService = HttpCalendarService();
  final DroughtService _droughtService = HttpDroughtService();

  // "Ask AgriShield"'s keyword router answers with a suite name
  // (backend/app/services/advice_router.py); only the suites with a real
  // screen here get a tab to jump to — weather/prices are still roadmap
  // (see ComingSoonCarousel), so those replies just skip the deep-link.
  static const _routeToTab = {
    'storage': 1,
    'disease_scan': 2,
    'recommendations': 3,
    'satellite': 4,
  };

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
  // Keep the branded splash up for a short, fixed minimum so it reads as
  // a deliberate loading screen rather than a flicker.
  bool _splashDone = false;

  static const _titles = [
    'AgriShield', 'Crop Storage', 'Leaf Scan', 'Farm Advice', 'Satellite View', 'My Profile',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _splashDone = true);
    });
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

  void _openChat() {
    if (_demoActive) _stopDemo();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdviceChatScreen(
          chatService: _chatService,
          languageController: _languageController,
          onOpenRoute: (route) {
            final tab = _routeToTab[route];
            Navigator.of(context).pop();
            if (tab != null) setState(() => _tab = tab);
          },
        ),
      ),
    );
  }

  void _openWeather() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Weather & Spraying')),
          body: WeatherScreen(farmer: _farmer!, weatherService: _weatherService),
        ),
      ),
    );
  }

  void _openAdvisorHub({
    AdvisorRequestType initialRequestType = AdvisorRequestType.consultation,
    String initialNotes = '',
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdvisorScreen(
          farmer: _farmer!,
          advisorService: _advisorService,
          initialRequestType: initialRequestType,
          initialNotes: initialNotes,
        ),
      ),
    );
  }

  void _openCalendar({String? prefillTitle}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CalendarScreen(
          farmer: _farmer!,
          calendarService: _calendarService,
          prefillTitle: prefillTitle,
        ),
      ),
    );
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

  void _toggleTheme() => widget.themeController.toggle(Theme.of(context).brightness);

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2);
    final out = parts.map((p) => p[0].toUpperCase()).join();
    return out.isEmpty ? 'A' : out;
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    return h < 12 ? 'Mangwanani · Good morning' : h < 17 ? 'Masikati · Good afternoon' : 'Manheru · Good evening';
  }

  /// Home: avatar + greeting + name, like the design's "Welcome Back".
  /// Other tabs: round back button, centered title, theme toggle.
  PreferredSizeWidget _header(BuildContext context, Farmer farmer) {
    final demoButton = CircleIconButton(
      icon: _demoActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
      tooltip: _demoActive ? 'End 60s demo' : 'Play 60s demo',
      onPressed: _demoActive ? _stopDemo : _startDemo,
    );
    final themeButton = ThemeToggleButton(onToggle: _toggleTheme);
    final Widget content = _tab == 0
        ? Row(
            key: const ValueKey('home-header'),
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [context.colors.primary, context.colors.secondary]),
                  boxShadow: context.softShadow,
                ),
                child: Text(_initials(farmer.name),
                    style: TextStyle(color: context.colors.onPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: context.palette.muted)),
                    Text(farmer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              demoButton,
              const SizedBox(width: 8),
              themeButton,
            ],
          )
        : Row(
            key: ValueKey('page-header-$_tab'),
            children: [
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back to home',
                onPressed: () => setState(() => _tab = 0),
              ),
              Expanded(
                child: Text(_titles[_tab],
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              themeButton,
            ],
          );
    return PreferredSize(
      preferredSize: const Size.fromHeight(76),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: content),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone || _signedIn == null) return const SplashScreen();
    if (_signedIn == false) {
      return LandingScreen(authService: _authService, onAuthenticated: _onAuthenticated, onToggleTheme: _toggleTheme);
    }

    final farmer = _farmer;
    if (farmer == null) return const SplashScreen();

    final screens = [
      HomeScreen(
        farmer: farmer,
        sensorService: _sensorService,
        messagingService: _messagingService,
        onOpenTab: (i) => setState(() => _tab = i),
        onOpenWeather: _openWeather,
      ),
      StorageScreen(sensorService: _sensorService),
      DiseaseScanScreen(
        diseaseService: _diseaseService,
        onFindAdvisor: (issue) => _openAdvisorHub(
          initialRequestType: AdvisorRequestType.diseaseEscalation,
          initialNotes: 'Diagnosed as: $issue',
        ),
        onScheduleSpraying: (issue) => _openCalendar(prefillTitle: 'Spray for $issue'),
      ),
      RecommendationScreen(recommendationService: _recommendationService),
      SatelliteMapScreen(
        satelliteService: _satelliteService,
        farmer: farmer,
        droughtService: _droughtService,
      ),
      ProfileScreen(
        farmer: farmer,
        repository: _farmerRepository,
        onSaved: (updated) => setState(() => _farmer = updated),
        onSignOut: _signOut,
        onOpenWeather: _openWeather,
        onOpenAdvisorHub: () => _openAdvisorHub(),
        onOpenCalendar: () => _openCalendar(),
        languageController: _languageController,
      ),
    ];

    return Scaffold(
      appBar: _header(context, farmer),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openChat,
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Ask AgriShield'),
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
          NavItem(icon: Icons.eco_outlined, selectedIcon: Icons.eco, label: 'Advice'),
          NavItem(icon: Icons.map_outlined, selectedIcon: Icons.map, label: 'Map'),
          NavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}
