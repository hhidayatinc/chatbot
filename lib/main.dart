import 'package:flutter/material.dart';
import 'dart:async';

import 'package:chatbot/mode_variasi_a.dart';
import 'package:chatbot/mode_variasi_b.dart';
import 'package:chatbot/mode_variasi_c.dart';

void main() => runApp(const MyApp());

enum InteractionMode { a, b, c, d }

String modeLabel(InteractionMode m) {
  switch (m) {
    case InteractionMode.a:
      return "Mode Interaksi A";
    case InteractionMode.b:
      return "Mode Interaksi B";
    case InteractionMode.c:
      return "Mode Interaksi C";
    case InteractionMode.d:
      return "Mode Interaksi D";
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Help Me Bot',
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF1B2C4B);
    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.smart_toy_outlined, size: 120, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Help Me",
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              "Subtitle",
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF1B2C4B);
    final lightGray = const Color(0xFFEEEEEE);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.smart_toy_outlined, size: 60, color: darkBlue),
              const SizedBox(height: 30),
              const Text(
                "Hai, silahkan pilih mode interaksi chatbot anda!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              _buildModeButton(context, InteractionMode.a, lightGray),
              const SizedBox(height: 15),
              _buildModeButton(context, InteractionMode.b, lightGray),
              const SizedBox(height: 15),
              _buildModeButton(context, InteractionMode.c, lightGray),
              const SizedBox(height: 15),
              _buildModeButton(context, InteractionMode.d, lightGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    InteractionMode mode,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // Routing sesuai mode
          switch (mode) {
            case InteractionMode.a:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModeVariasiA()),
              );
              break;

            case InteractionMode.b:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModeVariasiB()),
              );
              break;

            case InteractionMode.c:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModeVariasiC()),
              );
              break;

            case InteractionMode.d:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _ComingSoonScreen(title: "Mode Variasi D"),
                ),
              );
              break;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          modeLabel(mode),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// placeholder untuk C & D biar app aman
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1B2C4B);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 56),
              const SizedBox(height: 14),
              const Text(
                "Mode ini belum dibuat.",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text("Nanti kita lanjut bikin Mode C & D ya."),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali"),
              )
          
          
            ],
          ),
        ),
      ),
    );
  }
}
