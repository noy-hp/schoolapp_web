// lib/screens/grad_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only imports for the iframe viewer
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// Modern Flutter Web: platformViewRegistry lives here
import 'dart:ui_web' as ui;

class GradScreen extends StatefulWidget {
  const GradScreen({super.key});

  @override
  State<GradScreen> createState() => _GradScreenState();
}

class _GradScreenState extends State<GradScreen> {
  /// NEWS PDFs shown in the dropdown. Make sure these files exist
  /// and are listed under `assets:` in pubspec.yaml, e.g.
  ///
  /// flutter:
  ///   assets:
  ///     - assets/news_pdfs/
  // In grad_screen.dart
final Map<String, String> _newsPdfs = const {
  'grad 1': 'assets/news_pdfs/grad1.pdf',   // <- renamed label + file
  'Great student1': 'assets/news_pdfs/GreatStudent1.pdf',
  'Great student2': 'assets/news_pdfs/GreatStudent2.pdf',
};


  // Current News selection (only used when no Library override is provided).
  late String _selected; // we set it in initState from _newsPdfs

  // If we came from Library, these override the dropdown.
  String? _overrideAsset; // e.g., 'assets/library_pdfs/3.pdf'
  String? _overrideTitle;

  // Simple viewer state
  int _page = 1;
  double _zoom = 100; // 40–400 works well with Chrome viewer
  bool _fitWidth = false;

  // Web view registration
  bool _viewRegistered = false;
  late final String _viewTypeId;
  html.IFrameElement? _iframe;

  // Ensure we parse route args only once
  bool _handledArgs = false;

  @override
  void initState() {
    super.initState();

    // Pick a safe default that always exists
    _selected = _newsPdfs.keys.first;

    // Unique ID for HtmlElementView
    _viewTypeId = 'pdf-view-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read optional arguments exactly once (when launched from Library)
    if (!_handledArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _overrideAsset = args['asset'] as String?;
        _overrideTitle = args['title'] as String?;
        // Reset viewer state when opening a specific file
        if ((_overrideAsset ?? '').isNotEmpty) {
          _page = 1;
          _zoom = 100;
          _fitWidth = false;
        }
      }
      _handledArgs = true;
    }

    // Register the HtmlElementView factory once (web only)
    if (kIsWeb && !_viewRegistered) {
      ui.platformViewRegistry.registerViewFactory(_viewTypeId, (int _) {
        _iframe = html.IFrameElement()
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true
          ..src = _buildPdfSrc(); // initial load
        return _iframe!;
      });
      _viewRegistered = true;
    }
  }

  /// Returns the active asset path: Library override (if any) or selected News PDF.
  String _activeAsset() {
    if ((_overrideAsset ?? '').isNotEmpty) {
      return _overrideAsset!;
    }
    // _selected is always one of the keys in _newsPdfs
    return _newsPdfs[_selected]!;
  }

  /// Resolve a proper URL for the asset on web.
  String _assetUrlForWeb(String assetPath) {
    final p = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
    return Uri.base.resolve(p).toString();
  }

  /// Build the iframe src with viewer params.
  String _buildPdfSrc() {
    final asset = _activeAsset();
    final base = _assetUrlForWeb(asset);
    if (_fitWidth) return '$base#view=FitH';
    return '$base#page=$_page&zoom=${_zoom.toInt()}';
  }

  void _reloadIframe() {
    if (!kIsWeb || _iframe == null) return;
    _iframe!.src = _buildPdfSrc();
  }

  void _openInNewTab() {
    if (!kIsWeb) return;
    html.window.open(_buildPdfSrc(), '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final title = _overrideTitle ?? 'News & Announcements';

    return Scaffold(
      appBar: const NavBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          // Title
          Center(
            child: Text(
              title,
              style: GoogleFonts.merriweather(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                // Show News dropdown only when NOT viewing a Library PDF
                if ((_overrideAsset ?? '').isEmpty) ...[
                  const Text('Select PDF:', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _selected,
                    items: _newsPdfs.keys
                        .map(
                          (label) => DropdownMenuItem<String>(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selected = value; // guaranteed to be in map
                        _page = 1;
                        _zoom = 100;
                        _fitWidth = false;
                      });
                      _reloadIframe();
                    },
                  ),
                  const SizedBox(width: 8),
                ],

                TextButton.icon(
                  onPressed: _reloadIframe,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),

                const SizedBox(width: 8),
                // Page -
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: () {
                    setState(() {
                      _page = _page > 1 ? _page - 1 : 1;
                      _fitWidth = false; // page makes sense in zoom mode
                    });
                    _reloadIframe();
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('$_page / –',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: () {
                    setState(() {
                      _page += 1;
                      _fitWidth = false;
                    });
                    _reloadIframe();
                  },
                  icon: const Icon(Icons.chevron_right),
                ),

                const SizedBox(width: 8),
                // Zoom
                IconButton(
                  tooltip: 'Zoom out',
                  onPressed: () {
                    setState(() {
                      _zoom = (_zoom - 10).clamp(40, 400);
                      _fitWidth = false;
                    });
                    _reloadIframe();
                  },
                  icon: const Icon(Icons.zoom_out),
                ),
                Text('${_zoom.toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                IconButton(
                  tooltip: 'Zoom in',
                  onPressed: () {
                    setState(() {
                      _zoom = (_zoom + 10).clamp(40, 400);
                      _fitWidth = false;
                    });
                    _reloadIframe();
                  },
                  icon: const Icon(Icons.zoom_in),
                ),

                const SizedBox(width: 8),
                // Fit width
                TextButton.icon(
                  onPressed: () {
                    setState(() => _fitWidth = true);
                    _reloadIframe();
                  },
                  icon: const Icon(Icons.fit_screen),
                  label: const Text('Fit width'),
                ),

                const SizedBox(width: 8),
                // Open in new tab
                IconButton(
                  tooltip: 'Open in new tab',
                  onPressed: _openInNewTab,
                  icon: const Icon(Icons.open_in_new),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Viewer
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
              ),
              child: !kIsWeb
                  ? const Center(
                      child: Text(
                        'The web PDF viewer is only available on Flutter Web.',
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: HtmlElementView(viewType: _viewTypeId),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
