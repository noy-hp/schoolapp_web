import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderBanner(),

            // Mission & Vision (kept)
            _SectionTitle('Mission & Vision'),
            _MissionVisionRow(),

            // New posters/flyers section (replaces Fast Facts + Leadership)
            _SectionTitle('Information Posters & Flyers'),
            _PosterGrid(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isNarrow = w < 900;
    final titleStyle = TextStyle(
      fontSize: isNarrow ? 34 : 44,
      fontWeight: FontWeight.w800,
      letterSpacing: .3,
      color: const Color(0xFF13321B),
    );
    final subtitleStyle = TextStyle(
      fontSize: isNarrow ? 16 : 18,
      height: 1.45,
      color: Colors.black87,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(isNarrow ? 20 : 32, 28, isNarrow ? 20 : 32, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFEFF7EF), const Color(0xFFF4FBF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: const Border(bottom: BorderSide(color: Color(0xFFE6EAE9))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment:
                isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Text('About Savannakhent College of Health', style: titleStyle),
              const SizedBox(height: 14),
              Text(
                'We are dedicated to shaping the next generation of healthcare professionals—'
                'through rigorous training, community service, and a commitment to lifelong learning.',
                style: subtitleStyle,
                textAlign: isNarrow ? TextAlign.start : TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isNarrow = w < 900;
    return Padding(
      padding: EdgeInsets.fromLTRB(isNarrow ? 20 : 32, 28, isNarrow ? 20 : 32, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                fontSize: isNarrow ? 26 : 30,
                fontWeight: FontWeight.w800,
                letterSpacing: .3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionVisionRow extends StatelessWidget {
  const _MissionVisionRow();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isNarrow = w < 1000;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 20 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.flag_rounded,
                  title: 'Our Mission',
                  text:
                      'To educate competent, compassionate healthcare professionals '
                      'who advance the wellbeing of our communities through clinical '
                      'excellence, ethical practice, and collaborative leadership.',
                ),
              ),
              SizedBox(width: isNarrow ? 0 : 16, height: isNarrow ? 12 : 0),
              Expanded(
                child: _InfoCard(
                  icon: Icons.visibility_rounded,
                  title: 'Our Vision',
                  text:
                      'To be a leading regional institution in health sciences, recognized '
                      'for innovative teaching, impactful research, and meaningful partnerships.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _InfoCard({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE8EDFF),
              child: Icon(icon, color: const Color(0xFF3F69FF)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .2)),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 15.5, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Posters/Flyers grid (replaces Fast Facts + Leadership)
class _PosterGrid extends StatelessWidget {
  const _PosterGrid();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1200 ? 3 : (w >= 800 ? 2 : 1);

    // Update paths to match your files in assets/about/
    final posters = <_Poster>[
      const _Poster(
        title: 'Admissions Summary (Lao)',
        assetPath: 'assets/about/recruitment_banner.jpg',
      ),
      const _Poster(
        title: 'Brochure — Front',
        assetPath: 'assets/about/brochure_front.jpg',
      ),
      const _Poster(
        title: 'Brochure — Back',
        assetPath: 'assets/about/brochure_back.jpg',
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(w < 900 ? 20 : 32, 4, w < 900 ? 20 : 32, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GridView.builder(
            shrinkWrap: true,
            primary: false,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: cols == 1 ? 1.6 : 1.2,
            ),
            itemCount: posters.length,
            itemBuilder: (context, i) => _PosterCard(poster: posters[i]),
          ),
        ),
      ),
    );
  }
}

class _Poster {
  final String title;
  final String assetPath;
  const _Poster({required this.title, required this.assetPath});
}

class _PosterCard extends StatelessWidget {
  final _Poster poster;
  const _PosterCard({required this.poster});

  void _openViewer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.asset(poster.assetPath, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openViewer(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                poster.assetPath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
                color: Colors.white,
              ),
              child: Text(
                poster.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
