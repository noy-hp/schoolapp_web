// lib/screens/pdf_view_screen.dart
import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only viewer
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

class PdfViewScreen extends StatefulWidget {
  const PdfViewScreen({super.key});
  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  // From Navigator.pushNamed('/pdf-view', arguments: {'asset': 'assets/library_pdfs/x.pdf', 'title': 'Title'})
  // Or arguments: {'url': 'https://example.com/file.pdf', 'title': 'Title'}
  String? _assetPath;
  String? _httpUrl;
  String _title = 'Document';

  // toolbar state
  int _page = 1;
  double _zoom = 100; // 40–400
  bool _fitWidth = false;

  // iframe plumbing
  bool _registered = false;
  late final String _viewTypeId;
  html.IFrameElement? _iframe;

  bool _handledArgs = false;

  @override
  void initState() {
    super.initState();
    _viewTypeId = 'pdf-view-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_handledArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _assetPath = args['asset'] as String?;
        _httpUrl = args['url'] as String?;
        _title = (args['title'] as String?)?.trim().isNotEmpty == true
            ? args['title'] as String
            : 'Document';
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
          ..src = _buildPdfSrc(); // initial
        return _iframe!;
      });
      _registered = true;
    }
  }

  // Build a URL that works on Flutter Web + GitHub Pages.
  // IMPORTANT: Flutter serves assets under ".../assets/assets/...".
  String _assetUrlForWeb(String assetPath) {
    final origin = Uri.base.origin;        // http://localhost:xxxx or https://noy-hp.github.io
    var base = Uri.base.path;              // "/" locally, "/schoolapp_web/" on Pages
    if (!base.endsWith('/')) base += '/';
    final rel = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
    return '$origin${base}assets/$rel';
  }

  String _activeUrl() {
    if ((_httpUrl ?? '').toString().startsWith('http')) {
      return _httpUrl!;
    }
    if ((_assetPath ?? '').isNotEmpty) {
      return _assetUrlForWeb(_assetPath!);
    }
    // Fallback to a harmless about:blank when nothing provided
    return 'about:blank';
  }

  String _buildPdfSrc() {
    final base = _activeUrl();
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
    return Scaffold(
      appBar: const NavBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          Center(
            child: Text(
              _title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
                TextButton.icon(
                  onPressed: _reloadIframe,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),

                // Page controls (hash params, no page count)
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
                  ? const Center(child: Text('PDF viewer is available on Web only.'))
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
