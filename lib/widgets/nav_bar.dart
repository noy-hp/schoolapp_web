import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isCompact = w < 900;

    // Soft pastel blue + subtle bottom border
    const bg = Color(0xFFD2E9FF);

    final brandStyle = GoogleFonts.merriweather(
      fontSize: isCompact ? 22 : 30, // BIG brand text
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      color: Colors.black87,
    );

    final itemStyle = GoogleFonts.inter(
      fontSize: isCompact ? 14 : 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: Colors.black87,
    );

    Widget navItem(String label, String route) {
      final current = ModalRoute.of(context)?.settings.name;
      final isActive = current == route || (route == '/' && (current == null || current == '/'));
      const activeColor = Color(0xFF0B5ED7);

      return TextButton(
        onPressed: () {
          if (current != route) Navigator.pushNamed(context, route);
        },
        style: TextButton.styleFrom(
          foregroundColor: isActive ? activeColor : Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: itemStyle.copyWith(color: isActive ? activeColor : Colors.black87),
        ),
      );
    }

    return Material(
      color: bg,
      elevation: 0,
      child: Container(
        height: preferredSize.height,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 24),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFB9D6F7))),
        ),
        child: Row(
          children: [
            // BRAND
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Savannakhet College of Health',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: brandStyle,
                ),
              ),
            ),

            // MENU
            if (!isCompact) ...[
              navItem('Home', '/'),
              navItem('About', '/about'),
              navItem('News', '/grad'),            // label changed
              navItem('Library', '/library'),
              navItem('Learn with AI', '/ai-agent'), // label changed
            ] else
              _NavPopupMenu(
                style: itemStyle,
                onSelect: (route) => Navigator.pushNamed(context, route),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavPopupMenu extends StatelessWidget {
  final TextStyle style;
  final void Function(String route) onSelect;
  const _NavPopupMenu({required this.style, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menu',
      itemBuilder: (_) => [
        PopupMenuItem(value: '/', child: Text('Home', style: style)),
        PopupMenuItem(value: '/about', child: Text('About', style: style)),
        PopupMenuItem(value: '/grad', child: Text('News', style: style)),            // label changed
        PopupMenuItem(value: '/library', child: Text('Library', style: style)),
        PopupMenuItem(value: '/ai-agent', child: Text('Learn with AI', style: style)),// label changed
      ],
      onSelected: onSelect,
      icon: const Icon(Icons.menu),
    );
  }
}
