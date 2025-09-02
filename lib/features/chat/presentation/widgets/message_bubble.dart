import 'package:flutter/material.dart';
import 'package:test_task_oncom/features/chat/domain/entities/message.dart';

abstract class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: getAlignment(),
      children: [
        Container(
          margin: getMargin(),
          padding: getPadding(),
          decoration: getDecoration(context),
          child: SelectionArea(
            child: Text(
              message.content,
              style: getTextStyle(context),
            ),
          ),
        ),
      ],
    );
  }

  CrossAxisAlignment getAlignment();
  EdgeInsets getMargin();
  EdgeInsets getPadding();
  BoxDecoration getDecoration(BuildContext context);
  TextStyle getTextStyle(BuildContext context);
}

class SentMessageBubble extends MessageBubble {
  const SentMessageBubble({required super.message, super.key});

  @override
  CrossAxisAlignment getAlignment() => CrossAxisAlignment.end;

  @override
  EdgeInsets getMargin() => const EdgeInsets.symmetric(
    vertical: 6,
    horizontal: 8,
  );

  @override
  EdgeInsets getPadding() => const EdgeInsets.symmetric(
    vertical: 10,
    horizontal: 12,
  );

  @override
  BoxDecoration getDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(14),
    );
  }

  @override
  TextStyle getTextStyle(BuildContext context) {
    return const TextStyle(color: Colors.white, fontSize: 16);
  }
}

class ReceivedMessageBubble extends MessageBubble {
  const ReceivedMessageBubble({required super.message, super.key});

  @override
  CrossAxisAlignment getAlignment() => CrossAxisAlignment.start;

  @override
  EdgeInsets getMargin() => const EdgeInsets.symmetric(
    vertical: 6,
    horizontal: 8,
  );

  @override
  EdgeInsets getPadding() => const EdgeInsets.symmetric(
    vertical: 10,
    horizontal: 12,
  );

  @override
  BoxDecoration getDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(14),
    );
  }

  @override
  TextStyle getTextStyle(BuildContext context) {
    return const TextStyle(color: Colors.black87, fontSize: 16);
  }
}

class MessageBubbleFactory {
  static MessageBubble create(Message message) {
    switch (message.role) {
      case MessageRole.user:
        return SentMessageBubble(message: message);
      case MessageRole.assistant:
        return ReceivedMessageBubble(message: message);
    }
  }
}
