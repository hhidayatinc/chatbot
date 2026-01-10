import 'package:flutter/material.dart';
import 'chat_api.dart';
import 'chat_controller.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot Layanan',
      theme: ThemeData(useMaterial3: true),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController c;
  final input = TextEditingController();
  final scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    // GANTI dengan webhook produksi kamu (bukan webhook-test)
    final api = ChatApi(endpoint: "https://YOUR-N8N-DOMAIN/webhook/chatbot");
    c = ChatController(api: api);

    _boot();
  }

  Future<void> _boot() async {
    setState(() {});
    try {
      await c.start();
    } catch (e) {
      c.messages.add(Message(role: MessageRole.bot, text: "Gagal terhubung. Coba lagi."));
    }
    setState(() {});
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;
      scroll.animateTo(
        scroll.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendText() async {
    final text = input.text;
    if (text.trim().isEmpty || c.isLoading) return;

    input.clear();
    setState(() {});
    try {
      await c.sendUserText(text);
    } catch (e) {
      c.messages.add(Message(role: MessageRole.bot, text: "Terjadi error. Coba ulangi."));
    }
    setState(() {});
    _scrollDown();
  }

  Future<void> _press(ChatButton b) async {
    if (c.isLoading) return;
    setState(() {});
    try {
      await c.pressButton(b);
    } catch (e) {
      c.messages.add(Message(role: MessageRole.bot, text: "Terjadi error. Coba ulangi."));
    }
    setState(() {});
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final msgs = c.messages;

    return Scaffold(
      appBar: AppBar(title: const Text("Bot Layanan Fakultas")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.all(12),
              itemCount: msgs.length,
              itemBuilder: (_, i) {
                final m = msgs[i];
                final isUser = m.role == MessageRole.user;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 520),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal.shade200 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      m.text,
                      style: const TextStyle(fontSize: 16, height: 1.35),
                    ),
                  ),
                );
              },
            ),
          ),

          // Buttons area (quick replies)
          if (c.buttons.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: c.buttons.map((b) {
                  return ElevatedButton(
                    onPressed: c.isLoading ? null : () => _press(b),
                    child: Text(b.label),
                  );
                }).toList(),
              ),
            ),

          // Input
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendText(),
                      decoration: const InputDecoration(
                        hintText: "Ketik pesan…",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: c.isLoading ? null : _sendText,
                    child: c.isLoading ? const Text("...") : const Text("Kirim"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
