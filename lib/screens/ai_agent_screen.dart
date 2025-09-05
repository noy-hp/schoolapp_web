import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/nav_bar.dart';

/// Change this to match your backend endpoint.
/// Example assumes a POST http://localhost:3000/chat with JSON { "message": "..." }
const String kChatEndpoint = 'http://localhost:3000/chat';

class AIAgentScreen extends StatefulWidget {
  const AIAgentScreen({super.key});

  @override
  State<AIAgentScreen> createState() => _AIAgentScreenState();
}

class _AIAgentScreenState extends State<AIAgentScreen> {
  final List<_ChatMessage> _messages = [
    const _ChatMessage(role: _Role.assistant, text: 'Hi! Ask me anything 😊'),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
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

    try {
      final uri = Uri.parse(kChatEndpoint);
      final res = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        String reply = '';
        try {
          final decoded = jsonDecode(res.body);
          // Flexible parsing to match common backend shapes
          reply = (decoded['reply'] ??
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
            text: 'Network error: $e\n(Check that your backend is running and CORS is enabled.)'));
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
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            '🤖 Ask with AI Agent',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Chat area
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                // Typing indicator at the end when sending
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
                      child: Text(
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
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
