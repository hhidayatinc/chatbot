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
  final String type;
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
