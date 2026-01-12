import 'package:flutter/material.dart';
import 'chat_common.dart';

enum NeedType { nonLomba, lomba }

class ModeVariasiB extends StatefulWidget {
  const ModeVariasiB({super.key});

  @override
  State<ModeVariasiB> createState() => _ModeVariasiBState();
}

class _ModeVariasiBState extends State<ModeVariasiB> {
  final List<ChatMsg> _messages = [];
  final ScrollController _scroll = ScrollController();

  NeedType? _need;

  int _infoIndex = 0;
  int _stepIndex = 0;

  static const _linkNonLomba = "https://s.ub.ac.id/surataktiffilkom";
  static const _linkLomba = "https://s.ub.ac.id/surataktiflomba";

  static const List<String> _infoCards = [
    "Informasi penting 1/3:\nSurat diproses ± 3 hari kerja setelah form tersubmit/diterima.\n(Sabtu, Minggu, dan tanggal merah tidak dihitung karena libur.)",
    "Informasi penting 2/3:\nFAQ: 081132257272 (WA Center Akademik FILKOM)\ndan halofilkom.ub.ac.id",
    "Informasi penting 3/3:\nSilahkan periksa inbox atau spam email untuk file surat yang kami kirim.",
  ];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  void _boot() {
    _messages.clear();
    _need = null;
    _infoIndex = 0;
    _stepIndex = 0;

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
    _askWantImportantInfo();
  }

  void _askWantImportantInfo() {
    _pushBot(
      "Oke. Sebelum ke caranya, apakah kamu mau tau informasi penting?",
      replies: [
        QuickReply(id: "yes_info", label: "Ya", onTap: _showInfoCard),
        QuickReply(id: "skip_info", label: "Tidak, langsung cara", onTap: _skipToSteps),
      ],
    );
  }

  void _showInfoCard() {
    _pushUser("Ya");
    _infoIndex = 0;
    _pushInfoCard();
  }

  void _pushInfoCard() {
    _pushBot(
      "${_infoCards[_infoIndex]}\n\nLanjut?",
      replies: [
        QuickReply(id: "info_next", label: "Lanjut", onTap: _nextInfo),
        QuickReply(id: "info_skip", label: "Tidak, langsung cara", onTap: _skipToSteps),
      ],
    );
  }

  void _nextInfo() {
    _pushUser("Lanjut");
    if (_infoIndex + 1 < _infoCards.length) {
      _infoIndex++;
      _pushInfoCard();
    } else {
      _startProgressiveSteps();
    }
  }

  void _skipToSteps() {
    _pushUser("Tidak, langsung cara");
    _startProgressiveSteps();
  }

  List<StepLine> _stepsNonLomba() => const [
        StepLine(prefix: "Langkah 1/3:", text: "Klik tautan berikut: ", linkLabel: "[Buat Surat]", linkUrl: _linkNonLomba),
        StepLine(prefix: "Langkah 2/3:", text: "Isi data diri dengan teliti dan cermati setiap instruksi yang ada pada Google Form."),
        StepLine(prefix: "Langkah 3/3:", text: "Cek ulang data → jika sudah benar, klik Kirim."),
      ];

  List<StepLine> _stepsLomba() => const [
        StepLine(prefix: "Langkah 1/3:", text: "Klik tautan berikut: ", linkLabel: "[Buat Surat]", linkUrl: _linkLomba),
        StepLine(prefix: "Langkah 2/3:", text: "Jika berkelompok, isi Nama/NIM/Prodi tiap anggota tim. Email aktif cukup 1 email untuk pengiriman PDF."),
        StepLine(prefix: "Langkah 3/3:", text: "Pastikan semua benar → klik Kirim."),
      ];

  List<StepLine> _getSteps() => _need == NeedType.lomba ? _stepsLomba() : _stepsNonLomba();

  void _startProgressiveSteps() {
    if (_need == null) return;

    _stepIndex = 0;
    _pushBot("Berikut langkah-langkahnya:");
    _pushBotRich(BotSingleStepBubble(step: _getSteps()[_stepIndex]));
    _pushStepCTA();
  }

  void _pushStepCTA() {
    final steps = _getSteps();
    final isLast = _stepIndex >= steps.length - 1;

    if (!isLast) {
      // sesuai spesifikasi: hanya tombol klik untuk melanjutkan
      _pushBot(
        " ",
        replies: [
          QuickReply(id: "step_next", label: "Klik untuk melanjutkan", onTap: _nextStep),
        ],
      );
    } else {
      // last step: hanya tombol selesai
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

  // ===== helpers render =====
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
        title: const Text("Mode Variasi B"),
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
