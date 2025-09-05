// lib/screens/pdf_view_screen.dart
import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web-only imports
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// IMPORTANT: On modern Flutter Web, platformViewRegistry is in dart:ui_web
import 'dart:ui_web' as ui;

class PdfViewScreen extends StatefulWidget {
  const PdfViewScreen({super.key});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  String? _asset;         // assets/library_pdfs/xxx.pdf
  String? _title;         // shown in the header
  bool _handledArgs = false;

  int _page = 1;
  double _zoom = 100;
  bool _fitWidth = false;

  late final String _viewTypeId;
  bool _viewRegistered = false;
  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    _viewTypeId = 'lib-pdf-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read route arguments once
    if (!_handledArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _asset = args['asset'] as String?;
        _title = args['title'] as String?;
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
          ..src = _buildPdfSrc();
        return _iframe!;
      });
      _viewRegistered = true;
    }
  }

  String _assetUrlForWeb(String assetPath) {
    final p = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
    return Uri.base.resolve(p).toString();
  }

  String _buildPdfSrc() {
    final asset = _asset ?? '';
    final base = _assetUrlForWeb(asset);
    if (_fitWidth) return '$base#view=FitH';
    return '$base#page=$_page&zoom=${_zoom.toInt()}';
  }

  void _reload() {
    if (!kIsWeb || _iframe == null) return;
    _iframe!.src = _buildPdfSrc();
  }

  void _openNewTab() {
    if (!kIsWeb) return;
    final url = _buildPdfSrc();
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final title = _title ?? 'Document';
    final missing = _asset == null || _asset!.isEmpty;

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
              style: const TextStyle(
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
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
                TextButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: () {
                    setState(() {
                      _page = _page > 1 ? _page - 1 : 1;
                      _fitWidth = false;
                    });
                    _reload();
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
                    _reload();
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Zoom out',
                  onPressed: () {
                    setState(() {
                      _zoom = (_zoom - 10).clamp(40, 400);
                      _fitWidth = false;
                    });
                    _reload();
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
                    _reload();
                  },
                  icon: const Icon(Icons.zoom_in),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _fitWidth = true);
                    _reload();
                  },
                  icon: const Icon(Icons.fit_screen),
                  label: const Text('Fit width'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Open in new tab',
                  onPressed: _openNewTab,
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
              child: missing
                  ? const Center(
                      child: Text(
                        'No document specified.',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : !kIsWeb
                      ? const Center(
                          child: Text('This viewer is available on Flutter Web.'),
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
