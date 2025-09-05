import 'package:flutter/material.dart';

void main() {
  runApp(const SchoolApp()); // 👈 Make sure this matches the class name below
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchoolApp Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savannakhet College — Website')),
      body: const Center(
        child: Text(
          'Hello! This is the new Flutter web site.\n'
          'If you can read this on GitHub Pages, deploy worked ✅',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
