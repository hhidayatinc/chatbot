import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickReply {
  final String id;
  final String label;
  final VoidCallback onTap;
  QuickReply({required this.id, required this.label, required this.onTap});
}

class ChatMsg {
  final bool fromBot;
  final Widget bubble;
  final List<QuickReply> quickReplies;
  bool repliesEnabled;

  ChatMsg({
    required this.fromBot,
    required this.bubble,
    this.quickReplies = const [],
    this.repliesEnabled = true,
  });
}

class StepLine {
  final String prefix;
  final String text;
  final String? linkLabel;
  final String? linkUrl;

  const StepLine({
    required this.prefix,
    required this.text,
    this.linkLabel,
    this.linkUrl,
  });
}

class UserPill extends StatelessWidget {
  final String text;
  const UserPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1B2C4B);
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class BotBubble extends StatelessWidget {
  final String text;
  const BotBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.35)),
    );
  }
}

class BotStepsBubble extends StatelessWidget {
  final String title;
  final List<StepLine> steps;
  const BotStepsBubble({super.key, required this.title, required this.steps});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...steps.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                children: [
                  Text("${s.prefix} ", style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(s.text, style: const TextStyle(fontSize: 14, height: 1.35)),
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

class BotSingleStepBubble extends StatelessWidget {
  final StepLine step;
  const BotSingleStepBubble({super.key, required this.step});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        children: [
          Text("${step.prefix} ", style: const TextStyle(fontWeight: FontWeight.w800)),
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
