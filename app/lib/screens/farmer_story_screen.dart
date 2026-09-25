import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

/// "How AgriShield helps you" — four swipeable pages answering, in plain
/// words, the four things a farmer actually asks: what does it do for my
/// harvest, is it easier, is it cheaper, can I use it on my phone. No tech
/// words. Costs come from the project's own sourced figures
/// (docs/roadmap/V1_HACKATHON_DEMO.md: zeer cooler ~$1, PICS bag ~$2–3);
/// the sensor lease price isn't set yet and says so.
class FarmerStoryScreen extends StatefulWidget {
  /// Label for the last page's button — "Get started" from the landing
  /// screen, "Done" when opened from inside the app.
  final String finishLabel;
  final VoidCallback? onFinish;

  const FarmerStoryScreen({super.key, this.finishLabel = 'Done', this.onFinish});

  @override
  State<FarmerStoryScreen> createState() => _FarmerStoryScreenState();
}

class _FarmerStoryScreenState extends State<FarmerStoryScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pageCount - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      Navigator.of(context).pop();
      widget.onFinish?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [_SafePage(), _EasierPage(), _CheaperPage(), _AnyPhonePage()],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pageCount; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? context.colors.secondary : context.colors.outline,
                      borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_page == _pageCount - 1 ? widget.finishLabel : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared page frame: a big animated picture on top, the farmer's question
/// as a small label, a short answer as the headline, then the detail.
class _StoryPage extends StatelessWidget {
  final String question;
  final String answer;
  final Widget picture;
  final Widget body;

  const _StoryPage({required this.question, required this.answer, required this.picture, required this.body});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 8),
        SizedBox(height: 190, child: Center(child: picture)),
        const SizedBox(height: 20),
        Text(question.toUpperCase(), style: context.text.labelSmall?.copyWith(color: context.colors.secondary))
            .animate()
            .fadeIn(duration: 300.ms),
        const SizedBox(height: 6),
        Text(answer, style: context.text.headlineSmall?.copyWith(height: 1.2))
            .animate()
            .fadeIn(delay: 100.ms, duration: 350.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 16),
        body.animate().fadeIn(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _Bubble({required this.icon, required this.color}) : size = 150;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: context.isDark ? 0.22 : 0.14),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

class _SafePage extends StatelessWidget {
  const _SafePage();

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      question: 'What does it do for me?',
      answer: 'It watches your harvest, so you don\'t lose it.',
      picture: Stack(
        alignment: Alignment.center,
        children: [
          _Bubble(icon: Icons.inventory_2_rounded, color: context.colors.secondary),
          Positioned(
            right: 0,
            top: 10,
            child: const Icon(Icons.visibility_rounded, size: 48, color: AgriShieldBrand.amberBright)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.9, end: 1.15, duration: 900.ms, curve: Curves.easeInOut),
          ),
        ],
      ).animate().scaleXY(begin: 0.8, end: 1, duration: 450.ms, curve: Curves.easeOutBack),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Point(icon: Icons.thermostat_rounded, text: 'A small solar box sits in your store and feels if it is too hot or too damp.'),
          _Point(icon: Icons.eco_rounded, text: 'Take a photo of a sick leaf and get a first answer on the spot.'),
          _Point(icon: Icons.public_rounded, text: 'See if your area is drying out, before you can tell by eye.'),
        ],
      ),
    );
  }
}

class _EasierPage extends StatelessWidget {
  const _EasierPage();

  @override
  Widget build(BuildContext context) {
    return const _StoryPage(
      question: 'Will it make my life easier?',
      answer: 'It tells you what to do — in plain words.',
      picture: _SmsCard(
        text: 'Your maize is getting damp. Move it into a sealed bag today to stop mold.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Point(icon: Icons.check_circle_rounded, text: 'No numbers to work out. One message, one thing to do.'),
          _Point(icon: Icons.notifications_off_rounded, text: 'Nothing wrong? It stays quiet. It only calls when it matters.'),
          _Point(icon: Icons.support_agent_rounded, text: 'Not sure? It points you to an extension officer.'),
        ],
      ),
    );
  }
}

class _CheaperPage extends StatelessWidget {
  const _CheaperPage();

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      question: 'Will it save me money?',
      answer: 'Less food thrown away. Cheap fixes you can do yourself.',
      picture: Stack(
        alignment: Alignment.center,
        children: [
          const _Bubble(icon: Icons.savings_rounded, color: AgriShieldStatus.low),
          for (var i = 0; i < 3; i++)
            Positioned(
              top: 0,
              left: 40.0 + i * 38,
              child: const Icon(Icons.circle, size: 16, color: AgriShieldBrand.amberBright)
                  .animate(onPlay: (c) => c.repeat())
                  .moveY(begin: -10, end: 70, delay: (i * 350).ms, duration: 1100.ms, curve: Curves.easeIn)
                  .fadeOut(delay: (i * 350 + 700).ms, duration: 400.ms),
            ),
        ],
      ),
      body: const Column(
        children: [
          _PriceRow(price: 'Free', what: 'Warnings by SMS or phone call'),
          _PriceRow(price: 'about \$1', what: 'Build a clay-pot cooler (zeer pot) — no electricity'),
          _PriceRow(price: 'about \$2–3', what: 'A sealed PICS bag that keeps pests out of grain'),
          _PriceRow(price: 'Per season', what: 'Rent the solar sensor — price still being set with local suppliers'),
        ],
      ),
    );
  }
}

class _AnyPhonePage extends StatelessWidget {
  const _AnyPhonePage();

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      question: 'Can I use it on my phone?',
      answer: 'Yes — any phone. Even with no internet.',
      picture: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, icon, label, h) in [
            (0, Icons.smartphone_rounded, 'App', 110.0),
            (1, Icons.sms_rounded, 'SMS', 86.0),
            (2, Icons.phone_in_talk_rounded, 'Call', 86.0),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: h,
                    decoration: BoxDecoration(
                      color: context.colors.secondary.withValues(alpha: context.isDark ? 0.22 : 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 36, color: context.colors.secondary),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: 0, end: -6, delay: (i * 200).ms, duration: 800.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 8),
                  Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                ],
              ).animate().fadeIn(delay: (i * 150).ms).slideY(begin: 0.3, end: 0),
            ),
        ],
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Point(icon: Icons.phone_android_rounded, text: 'Smartphone: the full app, and it keeps working with no signal.'),
          _Point(icon: Icons.dialpad_rounded, text: 'Basic phone: the same warnings arrive as an SMS.'),
          _Point(icon: Icons.record_voice_over_rounded, text: 'Can\'t read the message? A voice call reads it out to you.'),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Point({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: context.colors.secondary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15, height: 1.4, color: context.colors.onSurface))),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String price;
  final String what;
  const _PriceRow({required this.price, required this.what});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AgriShieldRadii.control),
        border: Border.all(color: context.colors.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(price, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.secondary)),
          ),
          Expanded(child: Text(what, style: TextStyle(fontSize: 14, height: 1.3, color: context.colors.onSurface))),
        ],
      ),
    );
  }
}

/// A basic-phone SMS: the plain message a farmer would actually receive.
class _SmsCard extends StatelessWidget {
  final String text;
  const _SmsCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF4B5563), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.sms_rounded, size: 16, color: AgriShieldBrand.mint),
              const SizedBox(width: 6),
              Text('AgriShield', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('now', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 300.ms)
        .scaleXY(begin: 0.85, end: 1, curve: Curves.easeOutBack)
        .then(delay: 600.ms)
        .shake(hz: 4, rotation: 0.02, duration: 400.ms);
  }
}
