import 'package:chatbot/active_study_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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

enum SectionKey { ringkasan, syarat, langkah, estimasi, kontak }

String sectionLabel(SectionKey k) {
  switch (k) {
    case SectionKey.ringkasan:
      return "Ringkasan";
    case SectionKey.syarat:
      return "Syarat";
    case SectionKey.langkah:
      return "Langkah";
    case SectionKey.estimasi:
      return "Estimasi";
    case SectionKey.kontak:
      return "Kontak";
  }
}

class ProcedureContent {
  final String id;
  final String title;
  final String summary;
  final List<String> steps;
  final List<String> requirements;
  final String estimate;
  final String contact;

  const ProcedureContent({
    required this.id,
    required this.title,
    required this.summary,
    required this.steps,
    required this.requirements,
    required this.estimate,
    required this.contact,
  });
}

/// Contoh konten (nanti kamu ganti sesuai website/prosedur yang kamu pakai)
const procedures = <ProcedureContent>[
  ProcedureContent(
    id: "aktif_kuliah",
    title: "Aktif Kuliah",
    summary:
        "Panduan singkat untuk mengurus status aktif kuliah sesuai ketentuan layanan.",
    steps: [
      "Siapkan NIM dan identitas mahasiswa.",
      "Cek ketentuan dan periode layanan yang berlaku.",
      "Ajukan permohonan melalui kanal layanan yang ditentukan.",
      "Tunggu verifikasi dan konfirmasi dari petugas.",
    ],
    requirements: ["NIM", "Kartu identitas", "Data pendukung (jika diminta)"],
    estimate: "Estimasi proses: 1–3 hari kerja (tergantung antrean).",
    contact: "Kontak layanan: Admin Pelayanan (jam kerja).",
  ),
  ProcedureContent(
    id: "peminjaman_ruang",
    title: "Peminjaman Ruang",
    summary: "Panduan peminjaman ruang untuk kegiatan akademik/kemahasiswaan.",
    steps: [
      "Tentukan tanggal & jam penggunaan ruang.",
      "Ajukan permohonan sesuai prosedur peminjaman ruang.",
      "Petugas mengecek ketersediaan ruang.",
      "Dapatkan konfirmasi (disetujui/ditolak) beserta catatan.",
    ],
    requirements: ["Nama kegiatan", "Penanggung jawab", "Waktu & durasi"],
    estimate:
        "Estimasi proses: 1 hari kerja (bisa lebih cepat jika slot tersedia).",
    contact: "Kontak: Pelayanan Umum / Unit terkait peminjaman ruang.",
  ),
];

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ActiveStudyChatScreen(variant: InteractionVariant.B),
            ),
          );
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

class ChatScreen extends StatefulWidget {
  final InteractionMode mode;
  const ChatScreen({super.key, required this.mode});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ProcedureContent? selected;
  SectionKey currentSection = SectionKey.ringkasan;
  bool showDetail = false;
  int stepIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void selectProcedure(ProcedureContent p) {
    setState(() {
      selected = p;
      currentSection = SectionKey.ringkasan;
      showDetail = false;
      stepIndex = 0;
    });
  }

  void nextStep() {
    if (selected == null) return;
    setState(() {
      stepIndex = (stepIndex + 1).clamp(0, selected!.steps.length);
    });
  }

  void prevStep() {
    if (selected == null) return;
    setState(() {
      stepIndex = (stepIndex - 1).clamp(0, selected!.steps.length);
    });
  }

  void toggleDetail() {
    setState(() => showDetail = !showDetail);
    if (widget.mode == InteractionMode.c && showDetail && selected != null) {
      _openBottomSheetDetail();
    }
  }

  void setSection(SectionKey k) {
    setState(() {
      currentSection = k;
      showDetail = false;
      stepIndex = 0;
    });
  }

  void _openBottomSheetDetail() {
    final p = selected;
    if (p == null) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(_detailText(p, currentSection)),
          ),
        );
      },
    ).whenComplete(() {
      // setelah ditutup, set showDetail balik false biar “disclosure” konsisten
      if (mounted) setState(() => showDetail = false);
    });
  }

  String _summaryText(ProcedureContent p, SectionKey sec) {
    switch (sec) {
      case SectionKey.ringkasan:
        return p.summary;
      case SectionKey.syarat:
        return "Syarat utama (ringkas): ${p.requirements.take(2).join(", ")}";
      case SectionKey.langkah:
        return "Langkah (ringkas): tekan 'Lanjut' untuk melihat langkah berikutnya.";
      case SectionKey.estimasi:
        return "Estimasi (ringkas): ${p.estimate}";
      case SectionKey.kontak:
        return "Kontak (ringkas): ${p.contact}";
    }
  }

  String _detailText(ProcedureContent p, SectionKey sec) {
    switch (sec) {
      case SectionKey.ringkasan:
        return "Ringkasan lengkap:\n\n${p.summary}";
      case SectionKey.syarat:
        return "Syarat lengkap:\n\n- ${p.requirements.join("\n- ")}";
      case SectionKey.langkah:
        return "Langkah lengkap:\n\n1) ${p.steps.join("\n2) ").replaceFirst("2)", "2)")}";
      case SectionKey.estimasi:
        return "Estimasi:\n\n${p.estimate}";
      case SectionKey.kontak:
        return "Kontak:\n\n${p.contact}";
    }
  }

  Widget _botBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF1B2C4B);

    return Scaffold(
      appBar: AppBar(
        title: Text(modeLabel(widget.mode)),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: selected == null ? _buildPickProcedure() : _buildProcedureFlow(),
      ),
    );
  }

  Widget _buildPickProcedure() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _botBubble("Halo! Pilih topik layanan yang ingin kamu baca:"),
        const SizedBox(height: 10),
        ...procedures.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: () => selectProcedure(p),
              child: Text(p.title),
            ),
          ),
        ),
        const Spacer(),
        Text(
          "Mode ini akan menguji progressive disclosure (A–D).",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProcedureFlow() {
    final p = selected!;
    final summary = _summaryText(p, currentSection);

    // Mode A: fokus step-by-step (langkah tampil progresif)
    final isModeA = widget.mode == InteractionMode.a;
    // Mode B: section-first (user pilih section dulu)
    final isModeB = widget.mode == InteractionMode.b;
    // Mode D: inline expand/collapse
    final isModeD = widget.mode == InteractionMode.d;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _botBubble("Topik: ${p.title}"),
        if (isModeB) _sectionChips(),
        _botBubble(summary),

        if (currentSection == SectionKey.langkah)
          _botBubble(_currentStepText(p)),

        if (isModeD && showDetail) _botBubble(_detailText(p, currentSection)),

        const Spacer(),

        _actionBar(p, isModeA: isModeA),
      ],
    );
  }

  Widget _sectionChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: SectionKey.values.map((k) {
          final selected = k == currentSection;
          return ChoiceChip(
            label: Text(sectionLabel(k)),
            selected: selected,
            onSelected: (_) => setSection(k),
          );
        }).toList(),
      ),
    );
  }

  String _currentStepText(ProcedureContent p) {
    if (p.steps.isEmpty) return "Tidak ada langkah yang tersedia.";
    final idx = stepIndex.clamp(0, p.steps.length - 1);
    return "Langkah ${idx + 1}/${p.steps.length}:\n${p.steps[idx]}";
  }

  Widget _actionBar(ProcedureContent p, {required bool isModeA}) {
    final isLangkah = currentSection == SectionKey.langkah;

    return SafeArea(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          // A: langsung fokus “Langkah”
          if (isModeA) _btn("Langkah", () => setSection(SectionKey.langkah)),

          if (!isModeA)
            _btn("Ringkasan", () => setSection(SectionKey.ringkasan)),

          if (!isModeA) _btn("Syarat", () => setSection(SectionKey.syarat)),

          if (!isModeA) _btn("Langkah", () => setSection(SectionKey.langkah)),

          if (!isModeA) _btn("Estimasi", () => setSection(SectionKey.estimasi)),

          _btn(
            widget.mode == InteractionMode.c
                ? "Lihat detail"
                : (showDetail ? "Tutup detail" : "Lihat detail"),
            toggleDetail,
          ),

          if (isLangkah) _btn("Back", prevStep),
          if (isLangkah) _btn("Lanjut", nextStep),

          _btn("Ganti Topik", () => setState(() => selected = null)),
          _btn("Selesai", () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
