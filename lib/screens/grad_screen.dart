// lib/screens/grad_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only: iframe viewer
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
    // add more when ready, e.g.:
    // 'grad 2': 'assets/news_pdfs/grad2.pdf',
  };

  // Current selection (when not overridden by Library)
  late String _selected;

  // Optional overrides when navigated from Library
  String? _overrideAsset;   // e.g., 'assets/library_pdfs/3.pdf'
  String? _overrideTitle;

  // Viewer state (iframe URL uses PDF hash params)
  int _page = 1;
  double _zoom = 100; // %
  bool _fitWidth = false;

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
        if ((_overrideAsset ?? '').isNotEmpty) {
          _page = 1;
          _zoom = 100;
          _fitWidth = false;
        }
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

  /// Build iframe src with hash params (page/zoom/FitH).
  String _buildPdfSrc() {
    final base = _assetUrlForWeb(_activeAsset());
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                if ((_overrideAsset ?? '').isEmpty) ...[
                  const Text('Select PDF:', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _selected,
                    items: _newsPdfs.keys
                        .map((label) =>
                            DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _selected = v;
                        _page = 1;
                        _zoom = 100;
                        _fitWidth = false;
                      });
                      _reloadIframe();
                    },
                  ),
                ],

                TextButton.icon(
                  onPressed: _reloadIframe,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),

                // Page controls (iframe uses hash-only; no knowledge of page count)
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: () {
                    setState(() {
                      _page = _page > 1 ? _page - 1 : 1;
                      _fitWidth = false;
                    });
                    _reloadIframe();
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('$_page / –', style: const TextStyle(fontWeight: FontWeight.w600)),
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

                // Zoom controls
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

                TextButton.icon(
                  onPressed: () {
                    setState(() => _fitWidth = true);
                    _reloadIframe();
                  },
                  icon: const Icon(Icons.fit_screen),
                  label: const Text('Fit width'),
                ),

                TextButton.icon(
                  onPressed: _openInNewTab,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

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
                      child: Text('The web PDF viewer is only available on Flutter Web.'),
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
