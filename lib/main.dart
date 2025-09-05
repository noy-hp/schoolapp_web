// lib/main.dart
import 'package:flutter/material.dart';

import 'package:schoolapp_web/screens/home_screen.dart';
import 'package:schoolapp_web/screens/about_screen.dart';
import 'package:schoolapp_web/screens/grad_screen.dart';
import 'package:schoolapp_web/screens/library_screen.dart';
import 'package:schoolapp_web/screens/ai_agent_screen.dart';
import 'package:schoolapp_web/screens/pdf_view_screen.dart';

void main() {
  runApp(const SchoolWebApp());
}

class SchoolWebApp extends StatelessWidget {
  const SchoolWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Web App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/about': (_) => const AboutScreen(),
        '/library': (_) => const LibraryScreen(),
        '/grad': (_) => const GradScreen(),
        '/news': (_) => const GradScreen(),
        '/ai-agent': (_) => const AIAgentScreen(),
        '/learn-ai': (_) => const AIAgentScreen(),
        '/pdf-view': (_) => const PdfViewScreen(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5ED7)),
        useMaterial3: true,
      ),
    );
  }
}
