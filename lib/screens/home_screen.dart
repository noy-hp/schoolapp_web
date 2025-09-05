import 'package:flutter/material.dart';
// Use the shared, updated NavBar (with “News” and “Learn with AI” labels)
import '../widgets/nav_bar.dart' as topnav;

/// ----------------------
/// HOME SCREEN
/// ----------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topnav.NavBar(), // <-- use the shared NavBar
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        _HeroBanner(),
        _BelowHeroStrip(),
      ],
    );
  }
}

/// FULL-WIDTH hero that shows the whole image (no cropping).
/// Adjust [kHeroAspectRatio] if your photo isn't 16:9.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  /// If your photo is not 16:9, change this to the correct ratio.
  /// e.g. 3/2, 4/3, 21/9, etc.
  static const double kHeroAspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Calculate height so the image fits the width exactly by aspect ratio.
    final desiredHeight = (size.width / kHeroAspectRatio);
    // Keep it at most nearly the viewport height (looks nice on laptops).
    final heroHeight = desiredHeight.clamp(360.0, size.height * 0.92);

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo – fits width, preserves full image.
          Positioned.fill(
            child: Image.asset(
              'assets/hero/home_hero.jpg', // <- your image path
              fit: BoxFit.fitWidth,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB7D3C4), Color(0xFFDCE6DF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Add your hero image at assets/hero/home_hero.jpg',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Subtle dark vignette to improve contrast for any future overlays
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.10),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // (No headline panel — removed as requested)
        ],
      ),
    );
  }
}

/// Slim info chip strip under the hero
class _BelowHeroStrip extends StatelessWidget {
  const _BelowHeroStrip();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 48 : 18,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8FA),
        border: Border(
          top: BorderSide(color: Color(0xFFE6ECF3)),
          bottom: BorderSide(color: Color(0xFFE6ECF3)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
            spacing: 18,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _ChipInfo(icon: Icons.info_outline, text: 'Request Info'),
              _ChipInfo(icon: Icons.map_outlined, text: 'Visit Campus'),
              _ChipInfo(icon: Icons.assignment_outlined, text: 'Apply'),
              _ChipInfo(icon: Icons.favorite_border, text: 'Give to School'),
              _ChipInfo(icon: Icons.groups_outlined, text: 'Alumni'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ChipInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      onPressed: () {},
      avatar: Icon(icon, size: 18, color: const Color(0xFF1B3A2A)),
      label: Text(text),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      backgroundColor: const Color(0xFFEFF5F1),
      side: const BorderSide(color: Color(0xFFDCE6DF)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
