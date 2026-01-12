import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum NeedType { nonLomba, lomba }

class QuickReply {
  final String id;
  final String label;
  final VoidCallback onTap;
  QuickReply({required this.id, required this.label, required this.onTap});
}

class ChatMsg {
  final bool fromBot;
  final Widget bubble;

  // Jika message dari bot punya tombol, taruh di sini (inline setelah bubble)
  final List<QuickReply> quickReplies;
  bool repliesEnabled;

  ChatMsg({
    required this.fromBot,
    required this.bubble,
    this.quickReplies = const [],
    this.repliesEnabled = true,
  });
}

enum InteractionVariant { A, B }

class ActiveStudyChatScreen extends StatefulWidget {
  final InteractionVariant variant;
  const ActiveStudyChatScreen({super.key, required this.variant});

  @override
  State<ActiveStudyChatScreen> createState() => _ActiveStudyChatScreenState();
}

class _ActiveStudyChatScreenState extends State<ActiveStudyChatScreen> {
  bool _stepsShown = false;
  final List<ChatMsg> _messages = [];
  final ScrollController _scroll = ScrollController();

  NeedType? _need;

  // ===== DATA =====
  static const _waAkademik = "081132257272";
  static const _haloFilkom = "https://halofilkom.ub.ac.id";

  static const _linkNonLomba = "https://s.ub.ac.id/surataktiffilkom";
  static const _linkLomba = "https://s.ub.ac.id/surataktiflomba";

  int _importantIndex = 0;
  int _stepIndex = 0;

  static const _importantInfo = <String>[
    "Informasi penting 1/3:\nSurat diproses ± 3 hari kerja setelah form tersubmit/diterima (Sabtu, Minggu, dan tanggal merah tidak dihitung).",
    "Informasi penting 2/3:\nFAQ: 081132257272 (WA Center Akademik FILKOM) dan halofilkom.ub.ac.id",
    "Informasi penting 3/3:\nSilahkan periksa inbox atau spam email untuk file surat yang kami kirim.",
  ];

  List<_StepLine> _getCurrentSteps() {
    if (_need == NeedType.lomba) return _stepsLomba();
    return _stepsNonLomba();
  }

  @override
  void initState() {
    super.initState();
    _boot();
  }

  void _boot() {
    _messages.clear();
    _need = null;
    _stepsShown = false;
    _importantIndex = 0;
    _need = null;

    _pushBot(
      text: "Buat Surat Keterangan Aktif Kuliah, untuk apa?",
      replies: [
        QuickReply(
          id: "need_non",
          label: "Non-Lomba",
          onTap: () => _chooseNeed(NeedType.nonLomba),
        ),
        QuickReply(
          id: "need_lomba",
          label: "Lomba",
          onTap: () => _chooseNeed(NeedType.lomba),
        ),
      ],
    );
  }

  void _askImportantGate() {
    _pushBot(
      text: "Oke. Sebelum ke caranya, apakah kamu mau tau informasi penting?",
      replies: [
        QuickReply(id: "imp_yes", label: "Ya", onTap: _showImportant1),
        QuickReply(
          id: "imp_skip",
          label: "Tidak, langsung cara",
          onTap: _skipToSteps,
        ),
      ],
    );
  }

  void _showImportant1() {
    _importantIndex = 0;
    _showImportantCard();
  }

  void _skipToSteps() {
    _pushUser("Tidak, langsung cara");
    _startProgressiveSteps(); // langsung ke langkah 1/3
  }

  void _showImportantCard() {
    final text = _importantInfo[_importantIndex];

    _pushBot(
      text: "$text\n\nLanjut?",
      replies: [
        QuickReply(id: "imp_next", label: "Lanjut", onTap: _nextImportant),
        QuickReply(
          id: "imp_skip",
          label: "Tidak, langsung cara",
          onTap: _skipToSteps,
        ),
      ],
    );
  }

  void _nextImportant() {
    _pushUser("Lanjut");

    if (_importantIndex + 1 < _importantInfo.length) {
      _importantIndex++;
      _showImportantCard();
    } else {
      _startProgressiveSteps(); // selesai info penting → masuk langkah
    }
  }

  void _chooseNeed(NeedType need) {
    _need = need;
    _pushUser(need == NeedType.nonLomba ? "Non-Lomba" : "Lomba");

    if (widget.variant == InteractionVariant.B) {
      _askImportantGate();
    } else {
      // Variant A (yang kemarin): langsung menu
      _pushBot(
        text:
            "Oke. Pilih salah satu tombol di bawah ini untuk mendapatkan penjelasan lebih.",
        replies: _menuReplies(includeChangeNeed: true, afterSteps: _stepsShown),
      );
    }
  }

  void _finishRun() {
    _pushUser("Selesai");
    _pushBot(
      text: "Baik, sesi ini sudah selesai. Terima kasih!",
      replies: [
        QuickReply(id: "finish_restart", label: "Mulai lagi", onTap: _boot),
      ],
    );

    // Nanti kalau sudah integrasi n8n:
    // - flush checkpoint buffer
    // - kirim final_submit
  }

  List<QuickReply> _menuReplies({
    required bool includeChangeNeed,
    required bool afterSteps,
  }) {
    final list = <QuickReply>[];

    // Sebelum steps ditampilkan: ada tombol Cara buat surat
    if (!afterSteps) {
      list.add(
        QuickReply(
          id: "menu_steps",
          label: "Cara buat surat",
          onTap: _showSteps,
        ),
      );
    }

    // Estimasi & Kontak selalu ada
    list.add(
      QuickReply(
        id: "menu_eta",
        label: "Berapa lama diproses?",
        onTap: _showEta,
      ),
    );
    list.add(
      QuickReply(
        id: "menu_wa",
        label: "Hubungi admin (WA)",
        onTap: _showContact,
      ),
    );

    // Setelah steps: tampilkan Selesai
    if (afterSteps) {
      list.add(
        QuickReply(id: "menu_finish", label: "Selesai", onTap: _finishRun),
      );
    }

    // Tombol ubah kebutuhan / kembali
    if (includeChangeNeed) {
      list.add(
        QuickReply(
          id: "menu_change",
          label: "Ubah Kebutuhan",
          onTap: _resetNeed,
        ),
      );
    } else {
      list.add(
        QuickReply(id: "menu_back", label: "Kembali", onTap: _showMenuOnly),
      );
    }

    return list;
  }

  void _showMenuOnly() {
    _pushUser("Kembali");
    _pushBot(
      text: "Silakan pilih info yang kamu butuhkan:",
      replies: _menuReplies(includeChangeNeed: true, afterSteps: _stepsShown),
    );
  }

  void _resetNeed() {
    _pushUser("Ubah Kebutuhan");
    _boot();
  }

  void _startProgressiveSteps() {
    if (_need == null) return;

    _stepsShown = true;
    _stepIndex = 0;

    final steps = _getCurrentSteps();

    _pushBot(text: "Berikut langkah-langkahnya:");
    _pushBotRich(_BotSingleStepBubble(step: steps[_stepIndex]));

    _pushBot(
      text: " ",
      replies: [
        QuickReply(
          id: "step_next",
          label: "Klik untuk melanjutkan",
          onTap: _nextStep,
        ),
        QuickReply(id: "finish", label: "Selesai", onTap: _finishRun),
      ],
    );
  }

  void _nextStep() {
    if (_need == null) return;

    _pushUser("Lanjut");

    final steps = _getCurrentSteps();

    if (_stepIndex + 1 < steps.length) {
      _stepIndex++;
      _pushBotRich(_BotSingleStepBubble(step: steps[_stepIndex]));

      _pushBot(
        text: " ",
        replies: [
          QuickReply(
            id: "step_next",
            label: "Klik untuk melanjutkan",
            onTap: _nextStep,
          ),
          QuickReply(id: "finish", label: "Selesai", onTap: _finishRun),
        ],
      );
    } else {
      _pushBot(
        text: "Selesai. Kamu butuh info lain?",
        replies: _menuReplies(includeChangeNeed: true, afterSteps: true),
      );
    }
  }

  void _showSteps() {
    if (_need == null) return;
    _pushUser("Cara buat surat");
    _startProgressiveSteps();
  }

  void _showEta() {
    _pushUser("Berapa lama diproses?");
    _pushBot(
      text:
          "Surat diproses kurang lebih 3 HARI KERJA setelah form tersubmit/diterima.\n"
          "Sabtu, Minggu, dan tanggal merah tidak dihitung.",
      replies: _menuReplies(includeChangeNeed: false, afterSteps: _stepsShown),
    );
  }

  void _showContact() {
    _pushUser("Hubungi admin (WA)");
    _pushBot(
      text:
          "WA Center Akademik FILKOM: $_waAkademik\n"
          "Atau buat tiket melalui: $_haloFilkom",
      replies: _menuReplies(includeChangeNeed: false, afterSteps: _stepsShown),
    );
  }

  // ===== Steps data (ringkas, sesuai teks kamu) =====
  List<_StepLine> _stepsNonLomba() => const [
    _StepLine(
      prefix: "1.",
      text: "Klik tautan berikut: ",
      linkLabel: "[Buat Surat]",
      linkUrl: _linkNonLomba,
    ),
    _StepLine(
      prefix: "2.",
      text: "Pada Google Form, pilih Bahasa dan Keperluan sesuai kebutuhan.",
    ),
    _StepLine(
      prefix: "3.",
      text: "Isi semua bagian dengan teliti sesuai instruksi di tiap bagian.",
    ),
    _StepLine(
      prefix: "4.",
      text: "Cek ulang data → jika sudah benar, klik Kirim.",
    ),
  ];

  List<_StepLine> _stepsLomba() => const [
    _StepLine(
      prefix: "1.",
      text: "Klik tautan berikut: ",
      linkLabel: "[Buat Surat]",
      linkUrl: _linkLomba,
    ),
    _StepLine(
      prefix: "2.",
      text: "Jika lomba berkelompok, isi Nama/NIM/Prodi tiap anggota tim.",
    ),
    _StepLine(
      prefix: "3.",
      text: "Email aktif: isi 1 email saja untuk pengiriman file PDF.",
    ),
    _StepLine(prefix: "4.", text: "Pastikan semua bagian benar → klik Kirim."),
  ];

  // ===== Message helpers =====
  void _pushUser(String text) {
    _messages.add(ChatMsg(fromBot: false, bubble: _UserPill(text: text)));
    _scrollToBottom();
  }

  void _pushBot({required String text, List<QuickReply> replies = const []}) {
    _messages.add(
      ChatMsg(
        fromBot: true,
        bubble: _BotBubble(text: text),
        quickReplies: replies,
        repliesEnabled: true,
      ),
    );
    _scrollToBottom();
  }

  void _pushBotRich(Widget bubble) {
    _messages.add(ChatMsg(fromBot: true, bubble: bubble));
    _scrollToBottom();
  }

  void _disableRepliesAt(int index) {
    if (index < 0 || index >= _messages.length) return;
    final msg = _messages[index];
    if (!msg.fromBot || msg.quickReplies.isEmpty) return;
    setState(() => msg.repliesEnabled = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 400,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF1B2C4B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        title: const Text("Help Me Bot"),
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
              alignment: m.fromBot
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Column(
                crossAxisAlignment: m.fromBot
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
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
                                side: const BorderSide(
                                  color: Color(0xFF5D86FF),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                              ),
                              onPressed: m.repliesEnabled
                                  ? () {
                                      // disable tombol di message ini
                                      _disableRepliesAt(i);
                                      // jalankan action
                                      r.onTap();
                                    }
                                  : null,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  r.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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

// ===== Widgets =====

class _BotBubble extends StatelessWidget {
  final String text;
  const _BotBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.35)),
    );
  }
}

class _UserPill extends StatelessWidget {
  final String text;
  const _UserPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF1B2C4B);
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StepLine {
  final String prefix;
  final String text;
  final String? linkLabel;
  final String? linkUrl;

  const _StepLine({
    required this.prefix,
    required this.text,
    this.linkLabel,
    this.linkUrl,
  });
}

class _BotSingleStepBubble extends StatelessWidget {
  final _StepLine step;
  const _BotSingleStepBubble({required this.step});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        children: [
          Text(
            "${step.prefix} ",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(step.text, style: const TextStyle(fontSize: 14, height: 1.35)),
          if (step.linkUrl != null && step.linkLabel != null)
            GestureDetector(
              onTap: () => _openUrl(step.linkUrl!),
              child: Text(
                step.linkLabel!,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotStepsBubble extends StatelessWidget {
  final List<_StepLine> steps;
  const _BotStepsBubble({required this.steps});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Berikut cara buat surat:",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...steps.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                children: [
                  Text(
                    "${s.prefix} ",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    s.text,
                    style: const TextStyle(fontSize: 14, height: 1.35),
                  ),
                  if (s.linkUrl != null && s.linkLabel != null)
                    GestureDetector(
                      onTap: () => _openUrl(s.linkUrl!),
                      child: Text(
                        s.linkLabel!,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
