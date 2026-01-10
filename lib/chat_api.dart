import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ChatApi {
  final String endpoint; // contoh: https://xxxx.app.n8n.cloud/webhook/chatbot

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

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return ChatResponse.fromJson(decoded);
  }
}
