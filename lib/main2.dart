import 'package:flutter/material.dart';
import 'dart:async'; // Import ini diperlukan untuk fungsi Timer/Delay

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Help Me Bot',
      theme: ThemeData(useMaterial3: true),
      // Aplikasi dimulai dari SplashScreen
      home: const SplashScreen(),
    );
  }
}

// --- HALAMAN 1: SPLASH SCREEN (BIRU) ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // LOGIKA TIMER: Tunggu 5 detik, lalu pindah halaman
    Timer(const Duration(seconds: 5), () {
      // pushReplacement digunakan agar user tidak bisa kembali ke splash screen
      // jika menekan tombol back di HP
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Warna Biru Gelap
    final Color darkBlue = const Color(0xFF1B2C4B); 

    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Besar
            const Icon(
              Icons.smart_toy_outlined, 
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // Judul "Help Me"
            const Text(
              "Help Me",
              style: TextStyle(
                fontFamily: 'Serif', 
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            // Subtitle
            const Text(
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

// --- HALAMAN 2: HOME SCREEN (PUTIH) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF1B2C4B);
    final Color lightGray = const Color(0xFFEEEEEE);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // Agar tidak tertutup poni/notch HP
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Kecil di atas
              Icon(
                Icons.smart_toy_outlined, // Ganti dengan Image.asset jika ada gambar
                size: 60,
                color: darkBlue,
              ),
              const SizedBox(height: 30),
              
              // Teks Sapaan
              const Text(
                "Hai, silahkan pilih mode interaksi chatbot anda!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Tombol-tombol Pilihan
              _buildButton("Mode Interaksi A", lightGray),
              const SizedBox(height: 15),
              _buildButton("Mode Interaksi B", lightGray),
              const SizedBox(height: 15),
              _buildButton("Mode Interaksi C", lightGray),
              const SizedBox(height: 15),
              _buildButton("Mode Interaksi D", lightGray),
            ],
          ),
        ),
      ),
    );
  }

  // Widget custom untuk membuat tombol lebih rapi
  Widget _buildButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          print("$text dipilih");
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
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}