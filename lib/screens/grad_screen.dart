import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only iframe
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// Modern Flutter Web
import 'dart:ui_web' as ui;

class GradScreen extends StatefulWidget {
  const GradScreen({super.key});
  @override
  State<GradScreen> createState() => _GradScreenState();
}

class _GradScreenState extends State<GradScreen> {
  /// Label -> asset path (match file names exactly, case-sensitive)
  final Map<String, String> _newsPdfs = const {
    'grad 1': 'assets/news_pdfs/grad1.pdf',
    // add more here when ready
  };

  // Current selection (when not overridden by Library)
  late String _selected;

  // Optional overrides when navigated from Library
  String? _overrideAsset;   // e.g., 'assets/library_pdfs/3.pdf'
  String? _overrideTitle;

  // iframe plumbing
  bool _registered = false;
  late final String _viewTypeId;
  html.IFrameElement? _iframe;

  // Ensure we read args once
  bool _handledArgs = false;

  @override
  void initState() {
    super.initState();
    _selected = _newsPdfs.keys.first;
    _viewTypeId = 'pdf-view-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_handledArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _overrideAsset = args['asset'] as String?;
        _overrideTitle = args['title'] as String?;
      }
      _handledArgs = true;
    }

    if (kIsWeb && !_registered) {
      ui.platformViewRegistry.registerViewFactory(_viewTypeId, (_) {
        _iframe = html.IFrameElement()
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true
          ..src = _buildPdfSrc(); // initial load
        return _iframe!;
      });
      _registered = true;
    }
  }

  /// Active asset: Library override wins; otherwise dropdown selection.
  String _activeAsset() =>
      (_overrideAsset != null && _overrideAsset!.isNotEmpty)
          ? _overrideAsset!
          : _newsPdfs[_selected]!;

  /// Build a URL that works on Flutter Web + GitHub Pages.
  /// IMPORTANT: Flutter serves assets under ".../assets/assets/...".
  String _assetUrlForWeb(String assetPath) {
    final origin = Uri.base.origin;          // http://localhost:xxxx or https://noy-hp.github.io
    var base = Uri.base.path;                // "/" locally, "/schoolapp_web/" on Pages
    if (!base.endsWith('/')) base += '/';
    final rel = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
    return '$origin${base}assets/$rel';      // → .../assets/assets/news_pdfs/grad1.pdf
  }

  /// Always open "fit to width" for readability.
  String _buildPdfSrc() {
    final base = _assetUrlForWeb(_activeAsset());
    return '$base#view=FitH'; // Fit to page width (no custom toolbar controls)
  }

  void _reloadIframe() {
    if (!kIsWeb || _iframe == null) return;
    _iframe!.src = _buildPdfSrc();
  }

  @override
  Widget build(BuildContext context) {
    final title = _overrideTitle ?? 'News & Announcements';

    // Roomy canvas – fewer margins so the doc is larger
    final horizontalPad = MediaQuery.sizeOf(context).width < 900 ? 8.0 : 12.0;

    return Scaffold(
      appBar: const NavBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Small top row: optional PDF picker only (no custom tools)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPad),
            child: Row(
              children: [
                if ((_overrideAsset ?? '').isEmpty) ...[
                  const Text('Select PDF:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selected,
                    items: _newsPdfs.keys
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selected = v);
                      _reloadIframe();
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Big viewer – fills the rest of the page
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(horizontalPad, 6, horizontalPad, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
              ),
              child: !kIsWeb
                  ? const Center(
                      child: Text('The web PDF viewer is only available on Flutter Web.'),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: HtmlElementView(viewType: _viewTypeId),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
