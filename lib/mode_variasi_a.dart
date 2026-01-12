import 'package:flutter/material.dart';
import 'chat_common.dart';

enum NeedType { nonLomba, lomba }

class ModeVariasiA extends StatefulWidget {
  const ModeVariasiA({super.key});

  @override
  State<ModeVariasiA> createState() => _ModeVariasiAState();
}

class _ModeVariasiAState extends State<ModeVariasiA> {
  final List<ChatMsg> _messages = [];
  final ScrollController _scroll = ScrollController();

  NeedType? _need;

  static const _waAkademik = "081132257272";
  static const _haloFilkom = "https://halofilkom.ub.ac.id";
  static const _linkNonLomba = "https://s.ub.ac.id/surataktiffilkom";
  static const _linkLomba = "https://s.ub.ac.id/surataktiflomba";

  @override
  void initState() {
    super.initState();
    _boot();
  }

  void _boot() {
    _messages.clear();
    _need = null;

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

    _pushBot(
      "Oke. Pilih salah satu tombol di bawah ini:",
      replies: _menuReplies(),
    );
  }

  List<QuickReply> _menuReplies() {
    return [
      QuickReply(id: "steps", label: "Langkah-langkah", onTap: _showStepsAll),
      QuickReply(id: "eta", label: "Estimasi waktu tunggu", onTap: _showEta),
      QuickReply(id: "wa", label: "Kontak WA", onTap: _showContact),
      QuickReply(id: "change", label: "Ubah kebutuhan", onTap: _boot),
      QuickReply(id: "back", label: "Kembali", onTap: _backToMenu),
      QuickReply(id: "finish", label: "Selesai", onTap: _finish),
    ];
  }

  void _backToMenu() {
    _pushUser("Kembali");
    _pushBot("Silakan pilih tombol yang kamu butuhkan:", replies: _menuReplies());
  }

  void _finish() {
    _pushUser("Selesai");
    _pushBot("Oke. Terima kasih!", replies: [
      QuickReply(id: "restart", label: "Mulai lagi", onTap: _boot),
    ]);
  }

  List<StepLine> _stepsNonLomba() => const [
        StepLine(prefix: "1.", text: "Klik tautan berikut: ", linkLabel: "[Buat Surat]", linkUrl: _linkNonLomba),
        StepLine(prefix: "2.", text: "Pada Google Form, pilih Bahasa dan Keperluan sesuai kebutuhan."),
        StepLine(prefix: "3.", text: "Isi semua bagian dengan teliti sesuai instruksi di tiap bagian."),
        StepLine(prefix: "4.", text: "Cek ulang data → jika sudah benar, klik Kirim."),
      ];

  List<StepLine> _stepsLomba() => const [
        StepLine(prefix: "1.", text: "Klik tautan berikut: ", linkLabel: "[Buat Surat]", linkUrl: _linkLomba),
        StepLine(prefix: "2.", text: "Jika lomba berkelompok, isi Nama/NIM/Prodi tiap anggota tim."),
        StepLine(prefix: "3.", text: "Email aktif: isi 1 email saja untuk pengiriman file PDF."),
        StepLine(prefix: "4.", text: "Pastikan semua bagian benar → klik Kirim."),
      ];

  void _showStepsAll() {
    if (_need == null) return;
    _pushUser("Langkah-langkah");

    final needLabel = _need == NeedType.nonLomba ? "Non-Lomba" : "Lomba";
    _pushBot("Kebutuhan: Surat Keterangan Aktif Kuliah $needLabel");

    final steps = _need == NeedType.nonLomba ? _stepsNonLomba() : _stepsLomba();
    _pushBotRich(BotStepsBubble(title: "Berikut langkah-langkahnya:", steps: steps));

    _pushBot("Butuh info lain?", replies: _menuReplies());
  }

  void _showEta() {
    _pushUser("Estimasi waktu tunggu");
    _pushBot(
      "Surat diproses kurang lebih 3 HARI KERJA setelah form tersubmit/diterima.\nSabtu, Minggu, dan tanggal merah tidak dihitung.",
      replies: _menuReplies(),
    );
  }

  void _showContact() {
    _pushUser("Kontak WA");
    _pushBot(
      "WA Center Akademik FILKOM: $_waAkademik\nAtau buat tiket melalui: $_haloFilkom",
      replies: _menuReplies(),
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
        title: const Text("Mode Variasi A"),
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
