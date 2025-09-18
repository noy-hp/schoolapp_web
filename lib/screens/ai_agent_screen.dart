// lib/screen/ai_agent_screen.dart

import 'dart:convert';
// Web-only helpers to read window.API_BASE from config.js
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_util' as jsu;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// NOTE: change this import to '../widgets/nav_bar.dart' if your folder is "widgets"
import '../widgets/nav_bar.dart';

/// RUNTIME API BASE (Option 2):
/// 1) On GitHub Pages, create a file next to index.html named `config.js`:
///      window.API_BASE = "https://YOUR-NGROK.ngrok-free.app";
/// 2) Ensure index.html loads it (inside <head>):
///      <script src="config.js"></script>
/// 3) When ngrok URL changes, edit ONLY config.js on GitHub. No rebuild needed.
String get _apiBase {
  // 1) Prefer runtime value from config.js (window.API_BASE) on the web
  if (kIsWeb) {
    try {
      final v = jsu.getProperty(html.window, 'API_BASE');
      if (v is String && v.isNotEmpty) return v;
    } catch (_) {}
    // 2) Allow local override for quick testing (DevTools console):
    //    localStorage.API_BASE = "https://NEW.ngrok-free.app"
    try {
      final v2 = html.window.localStorage['API_BASE'];
      if (v2 != null && v2.isNotEmpty) return v2;
    } catch (_) {}
  }

  // 3) Fallback for desktop/mobile or local dev
  const defined =
      String.fromEnvironment('API_BASE', defaultValue: 'http://127.0.0.1:3000');
  return defined;
}

Uri _chatUri() => Uri.parse('$_apiBase/chat');
Uri _healthUri() => Uri.parse('$_apiBase/health');

class AIAgentScreen extends StatefulWidget {
  const AIAgentScreen({super.key});

  @override
  State<AIAgentScreen> createState() => _AIAgentScreenState();
}

enum _ApiStatus { unknown, online, offline, blocked }

class _AIAgentScreenState extends State<AIAgentScreen> {
  final List<_ChatMessage> _messages = const [
    _ChatMessage(role: _Role.assistant, text: 'Hi! Ask me anything 😊'),
  ].toList();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _sending = false;

  _ApiStatus _apiStatus = _ApiStatus.unknown;
  String _apiNote = '';

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _checkBackend() async {
    // Mixed-content guard: HTTPS page cannot call HTTP API in the browser.
    if (kIsWeb &&
        Uri.base.scheme == 'https' &&
        (_chatUri().scheme == 'http' || _healthUri().scheme == 'http')) {
      setState(() {
        _apiStatus = _ApiStatus.blocked;
        _apiNote =
            'This page is HTTPS but the API is HTTP.\n'
            'Edit config.js to use an HTTPS URL (ngrok) like:\n'
            'window.API_BASE="https://...ngrok-free.app";';
      });
      return;
    }

    try {
      final res = await http
          .get(_healthUri(), headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        setState(() {
          _apiStatus = _ApiStatus.online;
          _apiNote = 'Connected';
        });
      } else {
        setState(() {
          _apiStatus = _ApiStatus.offline;
          _apiNote = 'Server responded ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _apiStatus = _ApiStatus.offline;
        _apiNote = 'Cannot reach API: $e';
      });
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage(role: _Role.user, text: text));
      _sending = true;
      _controller.clear();
    });
    _scrollToBottom();

    // Helpful error if blocked by mixed content
    if (_apiStatus == _ApiStatus.blocked) {
      setState(() {
        _messages.add(const _ChatMessage(
          role: _Role.assistant,
          text:
              'Blocked: Site is HTTPS but API is HTTP.\n'
              'Open config.js and set an HTTPS ngrok URL, then refresh.',
        ));
        _sending = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final res = await http
          .post(
            _chatUri(),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'message': text}),
          )
          .timeout(const Duration(seconds: 60));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        String reply;
        try {
          final decoded = jsonDecode(res.body);
          reply = (decoded['reply'] ??
                  decoded['final_answer'] ??
                  decoded['answer'] ??
                  decoded['content'] ??
                  decoded['text'] ??
                  decoded.toString())
              .toString();
        } catch (_) {
          reply = res.body; // plain text fallback
        }
        setState(() {
          _messages.add(_ChatMessage(role: _Role.assistant, text: reply));
        });
      } else {
        setState(() {
          _messages.add(_ChatMessage(
              role: _Role.assistant,
              text:
                  'Server error (${res.statusCode}). Please try again later.'));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          role: _Role.assistant,
          text:
              'Network error: $e\n'
              '• Make sure your backend is running\n'
              '• API must be HTTPS when site is HTTPS (use ngrok)\n'
              '• CORS is allowed in the sample FastAPI (ALLOWED_ORIGINS=*)',
        ));
      });
    } finally {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 160,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (_apiStatus) {
      _ApiStatus.online => Colors.green,
      _ApiStatus.offline => Colors.red,
      _ApiStatus.blocked => Colors.orange,
      _ => Colors.grey,
    };

    return Scaffold(
      appBar: const NavBar(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            '🤖 Learn with AI',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // Small connection banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Material(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              child: ListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                leading: Icon(Icons.cloud, color: statusColor),
                title: Text(
                  'API: $_apiBase',
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _apiNote.isEmpty ? 'Checking…' : _apiNote,
                  style: TextStyle(fontSize: 12, color: statusColor),
                ),
                trailing: IconButton(
                  tooltip: 'Recheck connection',
                  onPressed: _checkBackend,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Chat area
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_sending && index == _messages.length) {
                  return const _TypingBubble();
                }
                final m = _messages[index];
                final isUser = m.role == _Role.user;
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 4,
                            color: Colors.black12,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: SelectableText(
                        m.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          height: 1.35,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input bar
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type your question…',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple chat model
enum _Role { user, assistant }

class _ChatMessage {
  final _Role role;
  final String text;
  const _ChatMessage({required this.role, required this.text});
}

/// Dots typing indicator
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(), SizedBox(width: 4),
            _Dot(delayMs: 150), SizedBox(width: 4),
            _Dot(delayMs: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delayMs;
  const _Dot({this.delayMs = 0});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();
  late final Animation<double> _a =
      Tween(begin: 0.2, end: 1.0).animate(CurvedAnimation(
    parent: _c,
    curve: Interval(
      widget.delayMs / 900,
      (widget.delayMs + 600) / 900,
      curve: Curves.easeInOut,
    ),
  ));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: const CircleAvatar(radius: 4, backgroundColor: Colors.black38),
    );
  }
}
