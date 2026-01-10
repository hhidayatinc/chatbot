import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// =======================
/// Models
/// =======================

class ClientState {
  final String? serviceId;
  final String? sectionId;
  final String? purpose;

  const ClientState({this.serviceId, this.sectionId, this.purpose});

  factory ClientState.fromJson(Map<String, dynamic> json) => ClientState(
        serviceId: json['service_id'] as String?,
        sectionId: json['section_id'] as String?,
        purpose: json['purpose'] as String?,
      );

  Map<String, dynamic> toJson() => {
        "service_id": serviceId,
        "section_id": sectionId,
        "purpose": purpose,
      };
}

class ChatButton {
  final String label;
  final String action;
  final Map<String, dynamic> payload;

  ChatButton({required this.label, required this.action, required this.payload});

  factory ChatButton.fromJson(Map<String, dynamic> json) => ChatButton(
        label: (json['label'] ?? '') as String,
        action: (json['action'] ?? '') as String,
        payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      );
}

class ChatBubble {
  final String type; // "text"
  final String text;

  ChatBubble({required this.type, required this.text});

  factory ChatBubble.fromJson(Map<String, dynamic> json) => ChatBubble(
        type: (json['type'] ?? 'text') as String,
        text: (json['text'] ?? '') as String,
      );
}

class ChatResponse {
  final List<ChatBubble> bubbles;
  final List<ChatButton> buttons;
  final ClientState clientState;

  ChatResponse({required this.bubbles, required this.buttons, required this.clientState});

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
        bubbles: ((json['bubbles'] as List?) ?? [])
            .map((e) => ChatBubble.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        buttons: ((json['buttons'] as List?) ?? [])
            .map((e) => ChatButton.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        clientState: ClientState.fromJson((json['client_state'] as Map?)?.cast<String, dynamic>() ?? {}),
      );
}

/// =======================
/// API Client
/// =======================

class ChatApi {
  final String endpoint;
  ChatApi({required this.endpoint});

  Future<ChatResponse> send({
    required String sessionId,
    required String userMessage,
    required String action,
    required Map<String, dynamic> actionPayload,
    required ClientState clientState,
  }) async {
    final body = {
      "session_id": sessionId,
      "user_message": userMessage,
      "action": action,
      "action_payload": actionPayload,
      "client_state": clientState.toJson(),
    };

    final res = await http.post(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");


    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return ChatResponse.fromJson(decoded);
  }
}

/// =======================
/// UI
/// =======================

enum Role { user, bot }

class ChatMessage {
  final Role role;
  final String text;
  ChatMessage({required this.role, required this.text});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // TODO: ganti ke webhook produksi kamu (bukan webhook-test)
  static const String webhookEndpoint = "https://hidayatinc.app.n8n.cloud/webhook/chatbot";

  late final ChatApi api;
  final String sessionId = const Uuid().v4();

  ClientState clientState = const ClientState(serviceId: null, sectionId: null, purpose: null);
  final List<ChatMessage> messages = [];
  List<ChatButton> buttons = [];

  final input = TextEditingController();
  final scroll = ScrollController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    api = ChatApi(endpoint: webhookEndpoint);

    // mulai dengan memunculkan menu layanan dari backend
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _send(action: "OPEN_MENU", userMessage: "hi", actionPayload: {}, showUserBubble: false);
  }

  Future<void> _send({
    required String action,
    required String userMessage,
    required Map<String, dynamic> actionPayload,
    bool showUserBubble = true,
  }) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    if (showUserBubble && userMessage.trim().isNotEmpty) {
      messages.add(ChatMessage(role: Role.user, text: userMessage.trim()));
    }

    try {
      final resp = await api.send(
        sessionId: sessionId,
        userMessage: userMessage,
        action: action,
        actionPayload: actionPayload,
        clientState: clientState,
      );

      // Tambahkan bubble bot
      for (final b in resp.bubbles) {
        if (b.text.trim().isNotEmpty) {
          messages.add(ChatMessage(role: Role.bot, text: b.text.trim()));
        }
      }

      // Update state & tombol
      clientState = resp.clientState;
      buttons = resp.buttons;
    } catch (e) {
      messages.add(ChatMessage(role: Role.bot, text: "Maaf, ada kendala. Coba lagi."));
    } finally {
      setState(() => isLoading = false);
      _scrollDown();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;
      scroll.animateTo(
        scroll.position.maxScrollExtent + 240,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendText() async {
    final text = input.text;
    if (text.trim().isEmpty) return;
    input.clear();
    await _send(action: "USER_MESSAGE", userMessage: text, actionPayload: {});
  }

  Future<void> _pressButton(ChatButton b) async {
    // untuk desain kamu: setelah klik tombol, kita bisa tampilkan "seolah user memilih"
    messages.add(ChatMessage(role: Role.user, text: b.label));
    setState(() {});
    await _send(action: b.action, userMessage: "", actionPayload: b.payload);
  }

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white;
    final botBubble = Colors.grey.shade200;
    final userBubble = const Color(0xFF1E2F57); // biru tua mirip mockup

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Bot Layanan Fakultas"),
        backgroundColor: bg,
        elevation: 0,
      ),
      body: Column(
        children: [
          // CHAT LIST
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final m = messages[i];
                final isUser = m.role == Role.user;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        // ikon bot kecil (opsional)
                        Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 2),
                          child: Icon(Icons.smart_toy_outlined, size: 18, color: Colors.grey.shade600),
                        ),
                      ],
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? userBubble : botBubble,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            m.text,
                            style: TextStyle(
                              fontSize: 15.5,
                              height: 1.35,
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // QUICK REPLIES (TOMBOL VERTIKAL BESAR)
          if (buttons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final b in buttons) ...[
                    OutlinedButton(
                      onPressed: isLoading ? null : () => _pressButton(b),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.blue.shade200),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        b.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),

          // INPUT BAR
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      enabled: !isLoading,
                      onSubmitted: (_) => _sendText(),
                      decoration: InputDecoration(
                        hintText: "Ketik pertanyaanmu",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _sendText,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: userBubble,
                        padding: EdgeInsets.zero,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
