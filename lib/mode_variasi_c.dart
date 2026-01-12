import 'package:flutter/material.dart';
import 'chat_common.dart';

enum NeedType { nonLomba, lomba }

class ModeVariasiC extends StatefulWidget {
  const ModeVariasiC({super.key});

  @override
  State<ModeVariasiC> createState() => _ModeVariasiCState();
}

class _ModeVariasiCState extends State<ModeVariasiC> {
  final List<ChatMsg> _messages = [];
  final ScrollController _scroll = ScrollController();

  NeedType? _need;

  int _stepIndex = 0;
  bool _infoShown = false;
  bool _infoRunning = false;

  static const _linkNonLomba = "https://s.ub.ac.id/surataktiffilkom";
  static const _linkLomba = "https://s.ub.ac.id/surataktiflomba";

  static const List<String> _infoList = [
    "Informasi penting 1/3:\n"
        "Surat diproses ± 3 hari kerja setelah form tersubmit/diterima.\n"
        "(Sabtu, Minggu, dan tanggal merah tidak dihitung karena libur.)",
    "Informasi penting 2/3:\n"
        "FAQ: 081132257272 (WA Center Akademik FILKOM)\n"
        "dan halofilkom.ub.ac.id",
    "Informasi penting 3/3:\n"
        "Silahkan periksa inbox atau spam email untuk file surat yang kami kirim.",
  ];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  void _boot() {
    _messages.clear();
    _need = null;
    _stepIndex = 0;
    _infoShown = false;
    _infoRunning = false;

    _pushBot(
      "Buat Surat Keterangan Aktif Kuliah, untuk apa?",
      replies: [
        QuickReply(id: "need_non", label: "Non-Lomba", onTap: () => _chooseNeed(NeedType.nonLomba)),
        QuickReply(id: "need_lomba", label: "Lomba", onTap: () => _chooseNeed(NeedType.lomba)),
      ],
    );
  }

  void _chooseNeed(NeedType need) {
    _need = need;
    _pushUser(need == NeedType.nonLomba ? "Non-Lomba" : "Lomba");

    _pushBot("Oke. Sebelum ke caranya, aku kasih dulu informasi penting buat kamu.");
    _showImportantInfoSequence();
  }

  Future<void> _showImportantInfoSequence() async {
    if (_infoShown || _infoRunning) return;
    _infoRunning = true;

    // tampilkan 3 info berturut-turut (tanpa tombol lanjut per info)
    for (final msg in _infoList) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 220));
      _pushBot(msg);
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 120));

    _infoShown = true;
    _infoRunning = false;

    _pushBot(
      "Lanjutkan ke penjelasan cara buat suratnya?",
      replies: [
        QuickReply(id: "go_steps", label: "Ya", onTap: _goToSteps),
        QuickReply(id: "change_need", label: "Tidak, ubah kebutuhan", onTap: _changeNeed),
      ],
    );
  }

  void _changeNeed() {
    _pushUser("Tidak, ubah kebutuhan");
    _boot();
  }

  // ========= Steps (step-by-step) =========

  List<StepLine> _stepsNonLomba() => const [
        StepLine(prefix: "Langkah 1/3:", text: "Klik tautan berikut: ", linkLabel: "[Buat Surat]", linkUrl: _linkNonLomba),
        StepLine(prefix: "Langkah 2/3:", text: "Isi data diri dengan teliti dan cermati setiap instruksi yang ada pada Google Form."),
        StepLine(prefix: "Langkah 3/3:", text: "Cek kembali kebenaran data, lalu klik Kirim."),
      ];

  List<StepLine> _stepsLomba() => const [
        StepLine(prefix: "Langkah 1/3:", text: "Klik tautan berikut: ", linkLabel: "[Buat Surat]", linkUrl: _linkLomba),
        StepLine(prefix: "Langkah 2/3:", text: "Jika lomba berkelompok, isi Nama/NIM/Prodi tiap anggota tim. Email aktif cukup 1 email untuk pengiriman PDF."),
        StepLine(prefix: "Langkah 3/3:", text: "Pastikan semua benar, lalu klik Kirim."),
      ];

  List<StepLine> _getSteps() => _need == NeedType.lomba ? _stepsLomba() : _stepsNonLomba();

  void _goToSteps() {
    if (_need == null) return;

    _pushUser("Ya");
    _stepIndex = 0;

    _pushBot("Berikut langkah-langkahnya:");
    _pushBotRich(BotSingleStepBubble(step: _getSteps()[_stepIndex]));
    _pushStepCTA();
  }

  void _pushStepCTA() {
    final steps = _getSteps();
    final isLast = _stepIndex >= steps.length - 1;

    if (!isLast) {
      _pushBot(
        " ",
        replies: [
          QuickReply(id: "step_next", label: "Klik untuk melanjutkan", onTap: _nextStep),
        ],
      );
    } else {
      _pushBot(
        " ",
        replies: [
          QuickReply(id: "finish", label: "Selesai", onTap: _finish),
        ],
      );
    }
  }

  void _nextStep() {
    _pushUser("Lanjut");
    final steps = _getSteps();

    if (_stepIndex + 1 < steps.length) {
      _stepIndex++;
      _pushBotRich(BotSingleStepBubble(step: steps[_stepIndex]));
      _pushStepCTA();
    } else {
      _finish();
    }
  }

  void _finish() {
    _pushUser("Selesai");
    _pushBot(
      "Oke. Terima kasih!",
      replies: [
        QuickReply(id: "restart", label: "Mulai lagi", onTap: _boot),
      ],
    );
  }

  // ========= helpers render =========

  void _pushUser(String text) {
    _messages.add(ChatMsg(fromBot: false, bubble: UserPill(text: text)));
    _scrollToBottom();
  }

  void _pushBot(String text, {List<QuickReply> replies = const []}) {
    _messages.add(ChatMsg(fromBot: true, bubble: BotBubble(text: text), quickReplies: replies));
    _scrollToBottom();
  }

  void _pushBotRich(Widget bubble) {
    _messages.add(ChatMsg(fromBot: true, bubble: bubble));
    _scrollToBottom();
  }

  void _disableRepliesAt(int index) {
    final msg = _messages[index];
    if (!msg.fromBot || msg.quickReplies.isEmpty) return;
    setState(() => msg.repliesEnabled = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 500,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1B2C4B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        title: const Text("Mode Variasi C"),
      ),
      body: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        itemCount: _messages.length,
        itemBuilder: (_, i) {
          final m = _messages[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: m.fromBot ? Alignment.centerLeft : Alignment.centerRight,
              child: Column(
                crossAxisAlignment: m.fromBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  m.bubble,
                  if (m.fromBot && m.quickReplies.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: m.quickReplies.map((r) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                            width: 280, // biar rasa "full" seperti A/B; ubah ke double.infinity kalau mau
                            height: 40,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF5D86FF), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                              ),
                              onPressed: m.repliesEnabled
                                  ? () {
                                      _disableRepliesAt(i);
                                      r.onTap();
                                    }
                                  : null,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(r.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
