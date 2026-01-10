import 'package:uuid/uuid.dart';
import 'chat_api.dart';
import 'models.dart';

enum MessageRole { user, bot }

class Message {
  final MessageRole role;
  final String text;
  Message({required this.role, required this.text});
}

class ChatController {
  final ChatApi api;
  final String sessionId = const Uuid().v4();

  ClientState clientState = const ClientState(serviceId: null, sectionId: null, purpose: null);
  List<Message> messages = [];
  List<ChatButton> buttons = [];
  bool isLoading = false;

  ChatController({required this.api});

  Future<void> start() async {
    // kirim salam awal / trigger menu
    await sendUserText("hi");
  }

  Future<void> sendUserText(String text) async {
    await _send(action: "USER_MESSAGE", userMessage: text, actionPayload: {});
  }

  Future<void> pressButton(ChatButton b) async {
    await _send(action: b.action, userMessage: "", actionPayload: b.payload);
  }

  Future<void> _send({
    required String action,
    required String userMessage,
    required Map<String, dynamic> actionPayload,
  }) async {
    isLoading = true;

    if (userMessage.trim().isNotEmpty) {
      messages.add(Message(role: MessageRole.user, text: userMessage.trim()));
    }

    final resp = await api.send(
      sessionId: sessionId,
      userMessage: userMessage,
      action: action,
      actionPayload: actionPayload,
      clientState: clientState,
    );

    // append bot bubbles
    for (final b in resp.bubbles) {
      if (b.text.trim().isNotEmpty) {
        messages.add(Message(role: MessageRole.bot, text: b.text.trim()));
      }
    }

    // update state + buttons
    clientState = resp.clientState;
    buttons = resp.buttons;

    isLoading = false;
  }
}
